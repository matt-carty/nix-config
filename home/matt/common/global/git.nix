{
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    #    package = pkgs.gitAndTools.gitFull;
    signing.format = "openpgp";
    settings = {
      aliases = {
        st = "status";
        co = "checkout";
        sw = "switch";
        br = "branch";
        ci = "commit";
        cm = "commit -m";
        aa = "add --all";
        df = "diff";
        dfs = "diff --staged";
        lg = "log --oneline --graph --decorate -20";
        lga = "log --oneline --graph --decorate --all";
        last = "log -1 HEAD --stat";
        unstage = "reset HEAD --";
        p = "pull --ff-only";
        ff = "merge --ff-only";
      };
      user.name = "Matt Cartwright";
      user.email = lib.mkDefault "matt@cartycodes.com";
      extraConfig = {
        init.defaultBranch = "main";
        #     user.signing.key = "CE707A2C17FAAC97907FF8EF2E54EA7BFE630916";
        #     commit.gpgSign = lib.mkDefault true;
        #     gpg.program = "${config.programs.gpg.package}/bin/gpg2";

        merge.conflictStyle = "zdiff3";
        commit.verbose = true;
        diff.algorithm = "histogram";
        log.date = "iso";
        column.ui = "auto";
        branch.sort = "committerdate";
        # Automatically track remote branch
        push.autoSetupRemote = true;
        # Reuse merge conflict fixes when rebasing
        rerere.enabled = true;
      };
    };
  };
}
