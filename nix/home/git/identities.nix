# git/identities.nix - Multi-account Git management for Home Manager
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitIdentities;
  
  # Generate includeIf configurations for each workspace
  generateIncludeIfs = workspaceDirs:
    mapAttrs' (identity: dir: 
      nameValuePair "includeIf.\"gitdir:${dir}/\".path" 
        "~/.config/git/identity-${identity}"
    ) workspaceDirs;
  
  # Git identity switcher script
  gitIdentityScript = pkgs.writeShellScriptBin "git-identity" ''
    #!/usr/bin/env bash
    set -e

    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    # Identities configuration
    declare -A IDENTITIES
    ${concatStringsSep "\n" (mapAttrsToList (name: identity: ''
      IDENTITIES[${name}]="${identity.name}|${identity.email}|${identity.signingKey}|${optionalString (identity.githubUser != null) identity.githubUser}"
    '') cfg.identities)}

    show_current() {
      local current_name=$(git config --global user.name 2>/dev/null || echo "not set")
      local current_email=$(git config --global user.email 2>/dev/null || echo "not set")
      local current_key=$(git config --global user.signingkey 2>/dev/null || echo "none")
      
      echo -e "''${BLUE}Current Git Identity:''${NC}"
      echo -e "  Name:  ''${GREEN}$current_name''${NC}"
      echo -e "  Email: ''${GREEN}$current_email''${NC}"
      echo -e "  Key:   ''${GREEN}$current_key''${NC}"
      
      if git rev-parse --git-dir > /dev/null 2>&1; then
        local local_name=$(git config --local user.name 2>/dev/null)
        local local_email=$(git config --local user.email 2>/dev/null)
        if [ -n "$local_name" ] || [ -n "$local_email" ]; then
          echo -e "\n''${YELLOW}Local repository override:''${NC}"
          [ -n "$local_name" ] && echo -e "  Name:  ''${YELLOW}$local_name''${NC}"
          [ -n "$local_email" ] && echo -e "  Email: ''${YELLOW}$local_email''${NC}"
        fi
      fi
    }

    list_identities() {
      echo -e "''${BLUE}Available identities:''${NC}"
      for key in "''${!IDENTITIES[@]}"; do
        IFS='|' read -r name email signing_key github_user <<< "''${IDENTITIES[$key]}"
        echo -e "  ''${GREEN}$key''${NC}:"
        echo "    Name:  $name"
        echo "    Email: $email"
        echo "    Key:   $signing_key"
        [ -n "$github_user" ] && echo "    GitHub: $github_user"
      done
    }

    switch_identity() {
      local identity=$1
      local scope=$2
      
      if [ -z "$identity" ]; then
        echo -e "''${RED}Error: Identity name required''${NC}"
        return 1
      fi
      
      if [ -z "''${IDENTITIES[$identity]}" ]; then
        echo -e "''${RED}Error: Unknown identity '$identity'''${NC}"
        list_identities
        return 1
      fi
      
      IFS='|' read -r name email signing_key github_user <<< "''${IDENTITIES[$identity]}"
      
      local git_flag="--global"
      local scope_text="globally"
      
      if [ "$scope" = "--local" ]; then
        if ! git rev-parse --git-dir > /dev/null 2>&1; then
          echo -e "''${RED}Error: Not in a git repository''${NC}"
          return 1
        fi
        git_flag="--local"
        scope_text="for this repository"
      fi
      
      git config $git_flag user.name "$name"
      git config $git_flag user.email "$email"
      git config $git_flag user.signingkey "$signing_key"
      git config $git_flag commit.gpgsign true
      git config $git_flag gpg.format ssh
      
      echo -e "''${GREEN}✓ Switched to '$identity' identity $scope_text''${NC}"
      show_current
    }

    case "$1" in
      current|show)
        show_current
        ;;
      list|ls)
        list_identities
        ;;
      switch|set)
        shift
        switch_identity "$@"
        ;;
      help|--help|-h)
        echo "git-identity - Manage multiple Git identities"
        echo ""
        echo "Commands:"
        echo "  current       Show current identity"
        echo "  list          List all available identities"
        echo "  switch <name> [--local]  Switch to identity"
        echo "  help          Show this help message"
        ;;
      *)
        [ -n "$1" ] && echo -e "''${RED}Unknown command: $1''${NC}\n"
        show_current
        echo ""
        echo "Use 'git-identity help' for usage"
        ;;
    esac
  '';
in
{
  options.programs.gitIdentities = {
    enable = mkEnableOption "Git multi-account management";

    identities = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Full name for this identity";
          };
          email = mkOption {
            type = types.str;
            description = "Email address for this identity";
          };
          signingKey = mkOption {
            type = types.str;
            default = "~/.ssh/github";
            description = "SSH key path for signing commits";
          };
          githubUser = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "GitHub username for this identity";
          };
        };
      });
      default = {
        personal = {
          name = "adanoelle";
          email = "adanoelleyoung@gmail.com";
          signingKey = "~/.ssh/github";
          githubUser = "adanoelle";
        };
      };
      description = "Git identities to manage";
    };

    primary = mkOption {
      type = types.str;
      default = "personal";
      description = "Primary identity to use by default";
    };

    workspaceDirs = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        personal = "~/personal";
        work = "~/src/work";
      };
      description = "Directory mappings for automatic identity switching";
    };

    autoSwitch = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically switch identities based on directory";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ gitIdentityScript ];

    # Set up the primary identity
    programs.git = {
      userName = cfg.identities.${cfg.primary}.name;
      userEmail = cfg.identities.${cfg.primary}.email;
      
      extraConfig = generateIncludeIfs cfg.workspaceDirs;
    };

    # Create identity-specific config files
    home.file = mkMerge [
      # Identity configs
      (mapAttrs' (identity: id: 
        nameValuePair ".config/git/identity-${identity}" {
          text = ''
            [user]
              name = ${id.name}
              email = ${id.email}
              signingkey = ${id.signingKey}
            
            [commit]
              gpgsign = true
            
            [gpg]
              format = ssh
            
            ${optionalString (id.githubUser != null) ''
            [github]
              user = ${id.githubUser}
            ''}
          '';
        }
      ) cfg.identities)
      
      # SSH allowed signers file
      {
        ".config/git/allowed_signers" = {
          text = concatStringsSep "\n" (
            mapAttrsToList (identity: id: 
              "${id.email} namespaces=\"git\" $(cat ${id.signingKey}.pub 2>/dev/null || echo 'KEY_NOT_FOUND')"
            ) cfg.identities
          );
        };
      }
      
      # SSH config entries for multiple GitHub accounts
      {
        ".ssh/config.d/git-identities" = {
          text = concatStringsSep "\n\n" (
            mapAttrsToList (identity: id: 
              optionalString (id.githubUser != null) ''
                # ${identity} GitHub account
                Host github.com-${identity}
                  HostName github.com
                  User git
                  IdentityFile ${id.signingKey}
                  IdentitiesOnly yes
              ''
            ) cfg.identities
          );
        };
      }
    ];

    # Shell integration for auto-switching
    programs.bash.initExtra = mkIf cfg.autoSwitch ''
      # Auto-switch Git identity when entering directories
      __git_identity_check() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local current_dir=$(pwd)
          ${concatStringsSep "\n" (mapAttrsToList (identity: dir: ''
            if [[ "$current_dir" == ${dir}/* ]] || [[ "$current_dir" == ${dir} ]]; then
              local current_email=$(git config --local user.email 2>/dev/null)
              if [ "$current_email" != "${cfg.identities.${identity}.email}" ]; then
                echo "Switching to ${identity} identity for this repository"
                git-identity switch ${identity} --local
              fi
            fi
          '') cfg.workspaceDirs)}
        fi
      }
      
      # Hook into cd
      cd() {
        builtin cd "$@" || return
        __git_identity_check
      }
      
      # Check on shell start
      __git_identity_check
    '';
    
    programs.zsh.initExtra = mkIf cfg.autoSwitch ''
      # Auto-switch Git identity when entering directories
      __git_identity_check() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
          local current_dir=$(pwd)
          ${concatStringsSep "\n" (mapAttrsToList (identity: dir: ''
            if [[ "$current_dir" == ${dir}/* ]] || [[ "$current_dir" == ${dir} ]]; then
              local current_email=$(git config --local user.email 2>/dev/null)
              if [ "$current_email" != "${cfg.identities.${identity}.email}" ]; then
                echo "Switching to ${identity} identity for this repository"
                git-identity switch ${identity} --local
              fi
            fi
          '') cfg.workspaceDirs)}
        fi
      }
      
      # Hook into cd
      cd() {
        builtin cd "$@" || return
        __git_identity_check
      }
      
      # Check on shell start
      __git_identity_check
    '';

    # Shell aliases
    home.shellAliases = {
      gid = "git-identity";
      gid-list = "git-identity list";
      gid-current = "git-identity current";
    } // mapAttrs' (identity: _: 
      nameValuePair "git-${identity}" "git-identity switch ${identity}"
    ) cfg.identities;
  };
}
