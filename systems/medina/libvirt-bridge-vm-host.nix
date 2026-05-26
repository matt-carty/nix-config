# Libvirtd host with LAN bridge — bridged QEMU guests (e.g. Ubuntu cloud images) get DHCP
# on the same L2 segment as physical Ethernet.
#
# One-time prep (adapt release / filenames):
#
# ```
# sudo install -d -m0711 /var/lib/libvirt/images
# cd /var/lib/libvirt/images
# sudo curl -LO https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
# sudo qemu-img create -f qcow2 -F qcow2 -b noble-server-cloudimg-amd64.img ubuntu-openclaw.qcow2
# sudo qemu-img resize ubuntu-openclaw.qcow2 40G
# mkdir -p /tmp/cidata-openclaw
# sudo cloud-localds ubuntu-openclaw-cidata.iso /tmp/cidata-openclaw/user-data /tmp/cidata-openclaw/meta-data
# sudo medina-vm-virt-install ubuntu-openclaw-cidata.iso
# ```
#
# Persist across reboots: `sudo virsh autostart ubuntu-openclaw`.
#
# VM RAM/vcpus are passed into medina-vm-virt-install (from guest.* below). After creation,
# they live in libvirt XML — change with `virsh edit` unless you redefine the VM.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.medinaLibvirtBridge;
  br = cfg.bridge.name;
  g = cfg.guest;

  staticBridge = !cfg.bridge.useDHCP;

  medinaVmVirtInstall = pkgs.writeShellScriptBin "medina-vm-virt-install" ''
    set -euo pipefail
    if [ "$(id -u)" -ne 0 ]; then
      echo 'run as root (e.g. sudo medina-vm-virt-install …)' >&2
      exit 1
    fi

    CIDATA_ISO="''${1:?path to CIDATA.iso}"

    if [ ! -f "$CIDATA_ISO" ]; then
      echo "CIDATA iso missing: $CIDATA_ISO" >&2
      exit 1
    fi

    DISK=${lib.escapeShellArg g.diskPath}
    if [ ! -f "$DISK" ]; then
      echo "VM disk overlay missing: create backing qcow2 first — see ./libvirt-bridge-vm-host.nix header." >&2
      exit 1
    fi

    exec virt-install \
      --name ${g.name} \
      --memory ${toString g.memoryMiB} \
      --vcpus ${toString g.vcpus} \
      --disk path="$DISK",format=qcow2,bus=virtio \
      --disk path="$CIDATA_ISO",device=cdrom \
      --os-variant ${g.osVariant} \
      --network bridge=${br},model=virtio \
      --import \
      --noautoconsole
  '';
in {
  options.medinaLibvirtBridge = {
    enable = mkEnableOption "Ethernet bridge plus libvirt for LAN-attached VMs on medina";

    bridge = {
      name = mkOption {
        type = types.str;
        default = "br0";
        description = "Bridged QEMU guests attach here (--network bridge=…).";
      };
      physicalInterfaces = mkOption {
        type = types.listOf types.str;
        default = ["eno1"];
        description = ''
          Interfaces enslaved under the bridge. The host reaches the LAN via `${br}`
          — use DHCP below or static ipv4 options.
        '';
      };
      useDHCP = mkOption {
        type = types.bool;
        default = true;
        description = "DHCP client on ${br}; set false to use ipv4Addresses instead.";
      };
      ipv4Addresses = mkOption {
        type = types.listOf (types.submodule {
          options = {
            address = mkOption {type = types.str;};
            prefixLength = mkOption {
              type = types.ints.between 0 32;
              example = 24;
            };
          };
        });
        default = [];
        description = ''
          Static IPv4 on ${br}; only applied when useDHCP = false.

          Example: `[ { address = \"192.168.1.10\"; prefixLength = 24; } ]`
        '';
      };
      ipv4Gateway = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Default route via this IPv4 gateway when bridge.useDHCP = false — recommended whenever
          you assign static ipv4Addresses.
        '';
      };
    };

    guest = {
      name = mkOption {
        type = types.str;
        default = "ubuntu-openclaw";
        description = ''
          libvirt domain name. If you change this, rename disk paths in guest.diskPath /
          CIDATA filenames (or overrides) to match.
        '';
      };
      memoryMiB = mkOption {
        type = types.ints.positive;
        default = 8192;
        description = ''
          Passed to virt-install inside medina-vm-virt-install. Does not retrofit an existing
          domain — use virsh edit after first install.
        '';
      };
      vcpus = mkOption {
        type = types.ints.positive;
        default = 4;
        description = "Like memoryMiB: install-time suggestion for virt-install.";
      };
      diskPath = mkOption {
        type = types.str;
        default = "/var/lib/libvirt/images/ubuntu-openclaw.qcow2";
        description = ''
          qcow2 overlay path (backing file + resize before first boot). Matches default
          guest.name; update both together if you rename the VM.
        '';
      };
      cidataIsoPath = mkOption {
        type = types.str;
        default = "/var/lib/libvirt/images/ubuntu-openclaw-cidata.iso";
        description = ''
          Typical cloud-localds output path (documentation helper only — pass any CIDATA iso
          path as the argument to medina-vm-virt-install).
        '';
      };
      osVariant = mkOption {
        type = types.str;
        default = "ubuntu24.04";
        description = "`virt-install --os-variant`.";
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.bridge.physicalInterfaces != [];
        message = "medinaLibvirtBridge.bridge.physicalInterfaces must not be empty.";
      }
      {
        assertion =
          cfg.bridge.useDHCP || cfg.bridge.ipv4Addresses != [];
        message =
          "medinaLibvirtBridge: with useDHCP = false set at least one bridge.ipv4Addresses entry.";
      }
      {
        assertion =
          cfg.bridge.useDHCP -> cfg.bridge.ipv4Addresses == [];
        message =
          "medinaLibvirtBridge: clear bridge.ipv4Addresses when bridge.useDHCP = true.";
      }
    ];

    networking.networkmanager.unmanaged =
      (map (i: "interface-name:${i}") cfg.bridge.physicalInterfaces)
      ++ ["interface-name:${br}"];

    networking.bridges.${br}.interfaces = cfg.bridge.physicalInterfaces;

    # If the physical port still gets DHCP/IPv4 while enslaved, you end up with the *same*
    # address on eno1 and ${br}. The kernel then prefers cheaper routes via eno1; neighbor
    # entries attach to `dev eno1`, not `dev ${br}` — VMs look unreachable from this host,
    # while off-box clients (another laptop) keep working.
    networking.interfaces = mkMerge [
      (genAttrs cfg.bridge.physicalInterfaces (_: {
        useDHCP = mkForce false;
        ipv4.addresses = mkForce [];
      }))
      {
        ${br} = mkMerge [
          {useDHCP = mkForce cfg.bridge.useDHCP;}
          (mkIf staticBridge {
            ipv4.addresses = cfg.bridge.ipv4Addresses;
          })
        ];
      }
    ];

    networking.defaultGateway = mkIf (staticBridge && cfg.bridge.ipv4Gateway != null) {
      address = cfg.bridge.ipv4Gateway;
      interface = br;
    };

    virtualisation.libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
      allowedBridges = [
        "virbr0"
        br
      ];
    };

    users.users.matt.extraGroups = mkAfter ["libvirtd" "kvm"];

    environment.systemPackages =
      (with pkgs; [
        virt-manager
        qemu-utils
        cloud-utils
        medinaVmVirtInstall
      ])
      ++ cfg.extraPackages;
  };
}
