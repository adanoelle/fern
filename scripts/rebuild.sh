#!/usr/bin/env bash
# Safe NixOS rebuild script with validation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
FLAKE_NAME="fern"
FLAKE_PATH="."

# Helper functions
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running as root when needed
check_root() {
    if [[ "$1" == "switch" || "$1" == "boot" || "$1" == "test" ]] && [[ $EUID -ne 0 ]]; then
        print_error "This operation requires root privileges"
        echo "Please run with: sudo $0 $@"
        exit 1
    fi
}

# Pre-flight checks
preflight_checks() {
    print_status "Running pre-flight checks..."
    
    # Check for uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        print_warning "You have uncommitted changes:"
        git status --short
        echo
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Aborted by user"
            exit 1
        fi
    fi
    
    # Check flake
    print_status "Validating flake configuration..."
    if nix flake check "${FLAKE_PATH}"; then
        print_success "Flake validation passed"
    else
        print_error "Flake validation failed"
        exit 1
    fi
    
    # Format check
    print_status "Checking code formatting..."
    if nixpkgs-fmt --check . >/dev/null 2>&1; then
        print_success "Code formatting is correct"
    else
        print_warning "Code is not formatted. Run: nixpkgs-fmt ."
    fi
}

# Main rebuild function
rebuild() {
    local action="${1:-test}"
    local extra_args="${@:2}"
    
    case "$action" in
        test|switch|boot|build|dry-build)
            ;;
        *)
            print_error "Invalid action: $action"
            echo "Valid actions: test, switch, boot, build, dry-build"
            exit 1
            ;;
    esac
    
    check_root "$action"
    
    if [[ "$action" != "dry-build" ]]; then
        preflight_checks
    fi
    
    print_status "Running nixos-rebuild ${action}..."
    
    # Build command
    local cmd="nixos-rebuild ${action} --flake ${FLAKE_PATH}#${FLAKE_NAME}"
    
    # Add extra arguments if provided
    if [[ -n "$extra_args" ]]; then
        cmd="$cmd $extra_args"
    fi
    
    # Show command
    echo "Command: $cmd"
    echo
    
    # Execute
    if $cmd; then
        print_success "Rebuild ${action} completed successfully!"
        
        # Post-rebuild actions
        if [[ "$action" == "switch" ]]; then
            print_status "New generation activated"
            echo "Current generation: $(nixos-rebuild list-generations | head -n1)"
        fi
    else
        print_error "Rebuild ${action} failed"
        echo
        echo "Debug hints:"
        echo "  - Run with --show-trace for detailed error"
        echo "  - Check journalctl -xe for system logs"
        echo "  - Try 'test' before 'switch'"
        exit 1
    fi
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [action] [options]

Actions:
    test        Test the configuration without switching (default)
    switch      Build and switch to the new configuration
    boot        Build and set as boot default (switch on reboot)
    build       Build only, don't activate
    dry-build   Show what would be built

Options:
    --show-trace    Show detailed error traces
    --fast          Skip pre-flight checks
    --rollback      Rollback to previous generation
    --help          Show this help message

Examples:
    $0              # Test configuration
    $0 switch       # Switch to new configuration
    $0 test --show-trace  # Test with detailed errors

EOF
}

# Parse arguments
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    usage
    exit 0
fi

if [[ "$1" == "--rollback" ]]; then
    print_status "Rolling back to previous generation..."
    if sudo nixos-rebuild --rollback switch; then
        print_success "Rollback completed"
    else
        print_error "Rollback failed"
        exit 1
    fi
    exit 0
fi

# Main execution
rebuild "$@"
