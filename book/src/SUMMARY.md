# Summary

[Introduction](introduction.md)

# Part I: Understanding Fern

- [Design Philosophy](concepts/design-philosophy.md)
- [NixOS & Flakes](concepts/nixos-and-flakes.md)
- [Module System](concepts/module-system.md)
- [Home Manager](concepts/home-manager.md)
- [Aspects, Bundles & Topology](concepts/aspects-bundles-topology.md)

# Part II: The Desktop (Garden)

- [The Garden Design System](desktop/garden.md)
- [Niri](desktop/niri.md)
- [Browsers](desktop/browsers.md)
- [Hyprland (Legacy Fallback)](desktop/hyprland.md)
  - [Fern Shell (Retired)](desktop/fern-shell.md)
  - [Wallpaper (Hyprland)](desktop/wallpaper-and-theming.md)
  - [Idle & Lock (Hyprland)](desktop/idle-and-lock.md)

# Part III: Daily Life

- [Nushell](shells/nushell.md)
- [Starship & Zoxide](shells/starship-and-zoxide.md)
- [Ghostty](shells/ghostty.md)
- [Git: Design & Orchestrator](git/design-and-orchestrator.md)
  - [Core & Aliases](git/core-and-aliases.md)
  - [Identity Management](git/identity-management.md)
  - [Safety & Secrets](git/safety-and-secrets.md)
  - [GitHub & Tools](git/github-and-tools.md)
- [Rust](toolchains/rust.md)
- [C / C++](toolchains/c-cpp.md)
- [TypeScript & Node](toolchains/typescript-node.md)
- [Python](toolchains/python.md)
- [Ada](toolchains/ada.md)
- [C# / .NET](toolchains/csharp-dotnet.md)
- [Zig](toolchains/zig.md)
- [Game Dev: Stack Overview](gamedev/stack-overview.md)
  - [Debug Overlays](gamedev/debug-overlays.md)
  - [Profiling Tools](gamedev/profiling.md)
  - [GPU Debugging](gamedev/gpu-debugging.md)
  - [Tool Decision Matrix](gamedev/tool-matrix.md)

# Part IV: The Machine

- [Homelab (Tailscale & Radicale)](services/homelab.md)
- [Audio & PipeWire](services/audio.md)
- [Graphics & GPU](services/graphics.md)
- [Gaming (Steam & Gamescope)](services/gaming.md)
- [Docker & Containers](services/docker.md)
- [Cloud Platforms](services/cloud.md)
- [SOPS-nix](security/sops-nix.md)
- [Secret Guard](security/secret-guard.md)
- [Password Manager](security/password-manager.md)

# Part V: Architecture Internals

- [Repository Layout](architecture/repository-layout.md)
- [The Flake Entry Point](architecture/flake-entry-point.md)
- [Dendritic Bootstrap](architecture/dendritic-bootstrap.md)
- [Topology & Hosts](architecture/topology-and-hosts.md)
- [Aspect Patterns](architecture/aspect-patterns.md)
- [Bundle Composition](architecture/bundle-composition.md)
- [Defaults & Batteries](architecture/defaults-and-batteries.md)
- [Home Directory Taxonomy](architecture/home-directory-taxonomy.md)

# Part VI: Operations & Reference

- [Rebuilding & Testing](operations/rebuilding.md)
- [Garbage Collection & Maintenance](operations/maintenance.md)
- [Adding an Aspect](operations/adding-an-aspect.md)
- [Adding a Host](operations/adding-a-host.md)
- [Work Laptop (Ubuntu + Standalone Home)](operations/work-laptop.md)
- [Troubleshooting](operations/troubleshooting.md)
- [Aspect Index](reference/aspect-index.md)
- [Shell Aliases & Commands](reference/aliases.md)
- [Environment Variables](reference/environment-variables.md)

# Appendix: Migration (Historical)

- [Why Den](migration/why-den.md)
- [What Changed](migration/what-changed.md)
- [Before & After](migration/before-and-after.md)
