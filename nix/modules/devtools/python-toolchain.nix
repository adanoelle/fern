{ pkgs, ... }:

let  python = pkgs.python312;  # one reproducible interpreter
in
{
  environment.systemPackages = with pkgs; [
    python                # /usr/bin/python3
    uv                    # ultra-fast installer/venv manager (Rust)
  ];
}

