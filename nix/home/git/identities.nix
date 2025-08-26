# git/identities.nix - Multi-identity Git configuration (no scripts)
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gitIdentities;
  
  # Helper to create an identity configuration
  makeIdentityConfig = identity: {
    user.name = identity.name;
    user.email = identity.email;
  } // optionalAttrs (identity.signingKey != null) {
    user.signingkey = identity.signingKey;
    commit.gpgsign = true;
    gpg.format = "ssh";
  } // optionalAttrs (identity.sshCommand != null) {
    core.sshCommand = identity.sshCommand;
  } // identity.extraConfig;
  
  # Generate includeIf entries for each identity
  generateIncludes = mapAttrsToList (name: identity: {
    condition = "gitdir:${identity.directory}/";
    contents = makeIdentityConfig identity;
  }) cfg.identities;
  
in
{
  options.programs.gitIdentities = {
    enable = mkEnableOption "Git identity management";
    
    primary = mkOption {
      type = types.str;
      default = "personal";
      description = "Primary identity to use by default";
    };
    
    identities = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "User name for this identity";
          };
          
          email = mkOption {
            type = types.str;
            description = "Email address for this identity";
          };
          
          directory = mkOption {
            type = types.str;
            description = "Directory pattern where this identity applies (e.g., ~/work/)";
          };
          
          signingKey = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "SSH key path for signing commits";
          };
          
          sshCommand = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom SSH command for this identity";
            example = "ssh -i ~/.ssh/work-key -o IdentitiesOnly=yes";
          };
          
          extraConfig = mkOption {
            type = types.attrs;
            default = {};
            description = "Additional git config for this identity";
          };
        };
      });
      default = {
        personal = {
          name = "adanoelle";
          email = "adanoelleyoung@gmail.com";
          directory = "~/personal/";
          signingKey = "~/.ssh/github";
        };
        work = {
          name = "youngt0dd";
          email = "todd.young@pinnaclereliability.com";
          directory = "~/work/";
          signingKey = "~/.ssh/github-work";
          sshCommand = "ssh -i ~/.ssh/github-work -o IdentitiesOnly=yes";
        };
      };
      description = "Git identities configuration";
    };
  };
  
  config = mkIf cfg.enable {
    # Set up includeIf configurations for identity switching
    programs.git.includes = generateIncludes;
    
    # Set the default identity from the primary setting
    programs.git.extraConfig = mkIf (cfg.identities ? ${cfg.primary}) (
      let primaryIdentity = cfg.identities.${cfg.primary};
      in {
        user.name = mkDefault primaryIdentity.name;
        user.email = mkDefault primaryIdentity.email;
      } // optionalAttrs (primaryIdentity.signingKey != null) {
        user.signingkey = mkDefault primaryIdentity.signingKey;
      }
    );
    
    # Create allowed_signers file for SSH signature verification
    home.file.".config/git/allowed_signers" = {
      text = concatStringsSep "\n" (
        mapAttrsToList (name: identity:
          optionalString (identity.signingKey != null)
            "${identity.email} ${builtins.readFile identity.signingKey}"
        ) cfg.identities
      );
    };
    
    # Add helpful aliases for identity management
    programs.git.aliases = {
      # Check current identity
      id = "!echo \"Name: $(git config user.name), Email: $(git config user.email)\"";
      id-full = "config --get-regexp '^user\\.'";
      
      # List all configured identities (shows includes)
      id-list = "config --get-regexp '^includeif\\.'";
    };
    
    # Shell aliases for quick identity checking
    home.shellAliases = {
      git-id = "git id";
      git-who = "git config user.email";
    };
  };
}