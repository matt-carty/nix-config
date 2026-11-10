# ai-apps distrobox (medina): setup log

Branch: `ai-apps-distrobox`. Historical log of the 2026-11-10 setup; the "Launchers" section at the end is the current state.

## Phase 1 — Survey (2026-11-10)

- **Repo layout:** flake.nix → `nixosConfigurations.medina` = `systems/medina/configuration.nix`
  (+ sops-nix, nvf). Host-only modules live in `systems/medina/`; shared opt-in modules in
  `systems/common/optional/`.
- **Home Manager:** standalone (`homeConfigurations."matt@medina"` → `home/matt/medina.nix`),
  applied with `home-manager switch --flake .#matt@medina`. Opt-in features in
  `home/matt/common/features/` are enabled by importing them per host. `systemd.user.startServices = "sd-switch"`.
- **Desktop:** `GNOME wayland`.
- **Secret Service:** present — `org.freedesktop.secrets` owned by gnome-keyring (pid 1368).
  → NOT adding `services.gnome.gnome-keyring.enable`.
- **Docker:** enabled on medina via `systems/common/optional/server/docker.nix`.
  → NOT setting `podman.dockerCompat`. Distrobox auto-detect prefers podman; also pinning
  `container_manager="podman"` in `~/.config/distrobox/distrobox.conf` to be explicit.
- **GPU:** lspci says `NVIDIA GM107GL [Quadro K2200]` (brief said 940MX; same GM107 die).
  Proprietary driver active: `hardware.nvidia` legacy_580, `videoDrivers = ["nvidia"]`,
  `nvidia`/`nvidia_drm` modules loaded. → `nvidia=true` in the box.
- **allowUnfree:** already true (`systems/common/global/nix-settings.nix`, HM global).
- **distrobox / podman:** not installed. nixpkgs distrobox = 1.8.2.5.
- **Already present (pre-existing, left alone):** native Claude Desktop via
  `home/matt/common/features/claude-desktop.nix` (aaddrick `claude-desktop-fhs`), with
  `~/.local/share/applications/com.anthropic.Claude.desktop`. `xdg-mime query default
  x-scheme-handler/claude` → empty. This competes with the boxed app for the `claude://` handler.

## Phase 2 — Host config

- `systems/medina/configuration.nix`: `virtualisation.podman.enable = true`, `distrobox` in
  systemPackages. No dockerCompat (docker enabled), no gnome-keyring (already running).
- New HM feature `home/matt/common/features/ai-apps-distrobox.nix` (imported only by
  `home/matt/medina.nix`, so other hosts are unchanged):
  - `~/.config/distrobox/ai-apps.ini` ← `home/matt/common/features/ai-apps.ini` (nvidia=true)
  - `~/.config/distrobox/distrobox.conf`: `container_manager="podman"`
  - `ai-apps-update.service` (oneshot, distrobox by store path, PATH set to
    /run/wrappers/bin + system profile for podman/newuidmap) + `ai-apps-update.timer`
    (weekly, Persistent=true).
- `nixos-rebuild build --flake .#medina` → OK
  (`nixos-system-medina-26.11.20261027.31ecbac`). `home-manager build --flake .#matt@medina` → OK.
- Removed the stale `result` symlink in the repo root (untracked build-output GC root) while
  cleaning up build outputs.
- Commits: `e1654ec` (NixOS: podman + distrobox), `77db818` (HM feature + timer).
- `sudo -n true` → "a password is required". **HARD STOP: waiting for Matt to run
  `sudo nixos-rebuild switch --flake .#medina`.** (Matt ran it.) HM switch deliberately not applied yet (the
  timer's service needs podman from the system switch); will run it after.

## Phase 3 — Box + apps

- `home-manager switch` applied; timer armed (next: Mon 2026-11-16 00:00).
- `distrobox assemble create --file ~/.config/distrobox/ai-apps.ini` → OK (podman 6.1.4, Debian 12.15).
- **Claude Desktop:** repo URL / key path / package in the brief match the official doc
  (code.claude.com/docs/en/desktop-linux). Key fingerprint verified =
  `31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE`. Installed `claude-desktop 4.23118.1` with
  recommends (`qemu-system-x86`, `ovmf`; no `virtiofsd` candidate in bookworm).
  Side effect: `gpg --show-keys` created `~/.gnupg/pubring.kbx` in the shared home (empty keybox).
- **Grok Bot:** link worked → redirected to
  `downloads.cursor.com/grokbot/stable/.../grok-bot_0.79.3_amd64.deb` (vendor "SpaceXAI <hi@cursor.com>").
  postinst registers `/etc/apt/sources.list.d/grok-bot.sources`
  (`https://downloads.cursor.com/aptrepo`, suite `grok-bot`, key `/usr/share/keyrings/grok-bot.gpg`);
  `apt-cache policy` tracks it. → **Dropped `update-grok-bot`** from the timer (commit `04a40f0`);
  no `/usr/local/bin/update-grok-bot` created.

## Phase 4 — Export (imperative, outside repo)

- `~/.local/share/applications/ai-apps-com.anthropic.Claude.desktop` (export by `--app claude-desktop`;
  `--app com.anthropic.Claude` finds nothing). Also `ai-apps-grok-bot.desktop`; distrobox also wrote
  `ai-apps.desktop` (box launcher). Pre-edit copies in the scratchpad.
- MimeType lines present in both (claude, mcpb, skill / grokbot, sand).
- **Exec edits** (all lines): `distrobox-enter -n ai-apps -- env -u LD_LIBRARY_PATH /usr/bin/<app> --ozone-platform=wayland ...`
  - `/usr/bin/...` absolute path is REQUIRED: distrobox passes host PATH and `/nix/store` is visible
    in the box, so bare `claude-desktop` resolved to the host's native Nix build (4.29.0).
  - `env -u LD_LIBRARY_PATH`: host has `LD_LIBRARY_PATH=<nix alsa-lib>`, which needs glibc 2.38 and
    breaks Debian binaries. (Host GIO modules from /nix also leak; only "failed to load module" noise.)
- xdg-mime defaults set: `x-scheme-handler/claude` → `ai-apps-com.anthropic.Claude.desktop`
  (was native `com.anthropic.Claude.desktop`), `grokbot` → `ai-apps-grok-bot.desktop`; `sand` already pointed there.
- `update-desktop-database` isn't on the host PATH; ran it via `nix shell nixpkgs#desktop-file-utils`.

## Phase 5 — Smoke test

- **No sandbox / user-namespace / keyring errors** for either app → rootless box kept, no `--root`.
- **Grok Bot:** runs; GPU process up on `/dev/dri/renderD128`. Noise only: missing
  `/run/dbus/system_bus_socket`, vaInitialize failed, login1 Inhibit failed.
- **Claude Desktop (Debian build):** NOT conclusively verified. With a throwaway `--user-data-dir`,
  the main process sat >3 min in `jbd2_log_wait_commit` (fsync of config.json) without spawning
  GPU/renderer. Host I/O pressure was 70–94% "some" during the test, from unrelated load (Brave, Firefox,
  supabase postgres walwriters, dm-crypt kworkers). The first two Claude test runs were really the host's Nix
  build (PATH leak above) — that one ran fine in software GL. Killed only my own test instances.
- Nvidia: `nvidia=true` didn't bring nvidia libs into the box (NixOS keeps them under
  /run/opengl-driver, which distrobox's integration doesn't find). Grok's GPU process still came up via the render node.
- `systemctl --user start ai-apps-update.service` → Result=success, both repos hit, 0 upgraded.

## Unresolved

1. **Profile clash:** native Claude (HM `claude-desktop.nix`, 4.29.0, currently running) and the boxed one both
   use `~/.config/Claude` (box shares $HOME). Same lock → the boxed one just hands off to whichever's
   running, and two app versions writing one profile risk corrupting it. Options: drop
   `./common/features/claude-desktop.nix` from medina.nix, or recreate the box with a separate `home=`.
2. Re-run the Claude smoke test when disk I/O is quiet.
3. Does Grok Bot self-update outside apt? Is the download token account-specific? (Link redirected to a
   public CDN path, so probably not.)

## Follow-up — native Claude removed (2026-11-10)

- Matt approved: removed `./common/features/claude-desktop.nix` from `home/matt/medina.nix` (alien still imports it,
  so the flake input stays). HM switched; `claude-desktop` gone from host PATH. Commit below.
- CLI concern: host `claude-code` (common/global, all hosts) is visible inside the box through the leaked
  PATH and /nix/store, as is host qemu. Rather than remove the CLI from the host, the exported launchers now
  set a clean Debian PATH: `env -u LD_LIBRARY_PATH PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin /usr/bin/<app>`.
  Inside that env: no `claude` on PATH (Desktop uses its bundled Claude Code), qemu → Debian's /usr/bin.
- Both apps still share `~/.claude` with the host CLI (same $HOME), as on any normal install.

## Correction (2026-11-10)

- Matt had never used the native Claude Desktop. The "native 4.29.0 currently running" seen during
  Phase 5 was my own first smoke-test instance (launched via the PATH leak, outlived `timeout`).
  `~/.config/Claude` was created by that test at 11:05 today, so the "profile clash" was self-inflicted.
  The native package is still removed (no user value).
- Moved that test-made profile to `~/.config/Claude.nix-smoketest-20261110` so the boxed official build
  starts with a clean profile. Safe to delete.

## Fonts (2026-11-10)

- Grok showed no Japanese: box had 6 fonts, 0 with lang=ja. Installed fonts-noto-cjk, fonts-ipafont
  (matches host IPA fonts), fonts-noto-color-emoji; 36 ja fonts now. Added to ai-apps.ini additional_packages.
- Fonts still showed as boxes after restart. Root cause: the Electron apps ship their own bundled fontconfig
  (cache-11 for Grok, cache-12 for Claude), separate from Debian's 2.14 (cache-8). They kept using stale
  caches in the shared `~/.cache/fontconfig`, written by the first smoke tests (11:06–11:07) before the fonts
  were installed, so `/usr/share/fonts` only listed dejavu. Confirmed with CDP (`CSS.getPlatformFontsForNode`
  → DejaVu Sans for "IPAGothic") and strace (no IPA/Noto opens).
- Fix: deleted the 6 cache-11/12 files covering box-only paths (/usr/share/fonts, /usr/share/fonts/truetype,
  .../dejavu, /usr/local/share/fonts — none exist on the NixOS host). After relaunch: IPAGothic used, kanji render.
- **If fonts are ever added to the box again:** delete `~/.cache/fontconfig/*.cache-1[0-9]` entries for
  /usr paths (or all cache-11/12 files; the host regenerates its own) and restart the apps.

## Launchers now declarative (2026-11-10)

- `xdg.desktopEntries` in `home/matt/common/features/ai-apps-distrobox.nix` generates
  `ai-apps-com.anthropic.Claude.desktop` and `ai-apps-grok-bot.desktop` (same IDs, so the xdg-mime defaults
  still apply), with the clean-PATH / no-LD_LIBRARY_PATH Exec lines. Supersedes the Phase 4 hand edits.
- The old distrobox-export copies were moved to `~/.local/share/applications-ai-apps-backup/`. **Don't re-run
  `distrobox-export --app`**: files in `~/.local/share/applications` override the Nix ones.
- Still imperative: the box itself, the icons in `~/.local/share/icons/hicolor` (from distrobox-export),
  `ai-apps.desktop` (box terminal launcher), and the xdg-mime defaults in `~/.config/mimeapps.list`.
- Rebuild from scratch: `distrobox assemble create --file ~/.config/distrobox/ai-apps.ini`, add the Claude apt
  repo + install the grok-bot .deb (Phase 3), `distrobox-export --app claude-desktop` / `--app grok-bot` for icons
  only, then delete the exported .desktop files, and set the xdg-mime defaults.
