# C# / .NET

> .NET 8.0 SDK with ASP.NET, Mono for legacy projects, OmniSharp LSP, and
> DOTNET_ROOT configured for tooling.

## Overview

The C#/.NET toolchain supports modern .NET 8 development and legacy Mono
projects. It is provided as a single unified aspect
(`modules/devtools/csharp.nix`) covering the SDK and editor integration.

## SDK and runtimes

The aspect (`modules/devtools/csharp.nix`) installs:

| Package                             | Purpose                                   |
| ----------------------------------- | ----------------------------------------- |
| `dotnet-sdk_8_0` + `aspnetcore_8_0` | .NET 8 SDK with ASP.NET runtime           |
| `mono`                              | Open-source .NET Framework implementation |
| `msbuild`                           | Build tool for legacy .csproj projects    |

### Environment variables

```bash
DOTNET_ROOT="<nix-store>/dotnet-sdk-8.0"
```

`DOTNET_ROOT` is required by many .NET tools (omnisharp, dotnet-ef, etc.) to
locate the SDK installation.

## Editor integration

The aspect also includes:

| Package            | Purpose                           |
| ------------------ | --------------------------------- |
| `omnisharp-roslyn` | C# language server                |
| `dotnet-sdk_8`     | Also in home scope                |
| `nuget-to-nix`     | Convert NuGet dependencies to Nix |

### Helix LSP

```nix
programs.helix.languages.language-server.omnisharp = {
  command = "${pkgs.omnisharp-roslyn}/bin/omnisharp";
};
```

OmniSharp provides completions, diagnostics, refactoring, and go-to-definition
for C# files.

## Key files

| File                          | Purpose                                        |
| ----------------------------- | ---------------------------------------------- |
| `modules/devtools/csharp.nix` | .NET SDK, Mono, MSBuild, OmniSharp, nuget-to-nix |
