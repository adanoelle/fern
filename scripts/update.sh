#!/usr/bin/env bash
# Update and maintenance script for NixOS configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
print_header() {
    echo
    echo -e "${CYAN}═══ $1 ═══${NC}"
}

print_status() {
    echo -e "${BLUE}→${NC} $1"
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

# Check git status
check_git_status() {
    if [[ -n $(git status --porcelain) ]]; then
        print_warning "You have uncommitted changes"
        echo "It's recommended to commit or stash changes before updating."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Update flake inputs
update_flake() {
    print_header "Updating Flake Inputs"
    
    # Show current inputs
    print_status "Current flake inputs:"
    nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]' | sed 's/^/  - /'
    
    echo
    print_status "Choose update strategy:"
    echo "  1) Update all inputs"
    echo "  2) Update specific input"
    echo "  3) Show outdated inputs only"
    echo "  4) Skip flake update"
    
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            print_status "Updating all inputs..."
            if nix flake update; then
                print_success "All inputs updated"
                git diff flake.lock
            else
                print_error "Update failed"
                return 1
            fi
            ;;
        2)
            read -p "Enter input name to update: " input_name
            print_status "Updating $input_name..."
            if nix flake update "$input_name"; then
                print_success "$input_name updated"
                git diff flake.lock
            else
                print_error "Failed to update $input_name"
                return 1
            fi
            ;;
        3)
            print_status "Checking for outdated inputs..."
            nix flake update --dry-run 2>&1 | grep "Updated" || echo "All inputs are up to date"
            ;;
        4)
            print_status "Skipping flake update"
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}

# Clean old generations
clean_generations() {
    print_header "System Cleanup"
    
    # Show current disk usage
    print_status "Current /nix/store usage:"
    df -h /nix/store | tail -1
    
    # List generations
    print_status "Current system generations:"
    sudo nix-env --list-generations -p /nix/var/nix/profiles/system | tail -5
    
    echo
    print_status "Cleanup options:"
    echo "  1) Keep last 5 generations"
    echo "  2) Keep generations from last 7 days"
    echo "  3) Keep generations from last 30 days"
    echo "  4) Custom cleanup"
    echo "  5) Skip cleanup"
    
    read -p "Choice [1-5]: " choice
    
    case $choice in
        1)
            print_status "Keeping last 5 generations..."
            sudo nix-env --delete-generations +5 -p /nix/var/nix/profiles/system
            ;;
        2)
            print_status "Keeping last 7 days..."
            sudo nix-collect-garbage --delete-older-than 7d
            ;;
        3)
            print_status "Keeping last 30 days..."
            sudo nix-collect-garbage --delete-older-than 30d
            ;;
        4)
            read -p "Enter time period (e.g., 14d, 2w): " period
            sudo nix-collect-garbage --delete-older-than "$period"
            ;;
        5)
            print_status "Skipping cleanup"
            return 0
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
    
    # Run garbage collection
    print_status "Running garbage collection..."
    sudo nix-collect-garbage
    
    # Show new disk usage
    print_success "Cleanup complete. New disk usage:"
    df -h /nix/store | tail -1
}

# Update system packages
update_system() {
    print_header "System Package Updates"
    
    print_status "Checking for system updates..."
    
    # Check if rebuild would change anything
    if sudo nixos-rebuild dry-build --flake .#fern 2>&1 | grep -q "these derivations will be built"; then
        print_warning "System updates available"
        read -p "Test new configuration? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_status "Testing configuration..."
            if sudo nixos-rebuild test --flake .#fern; then
                print_success "Test successful"
                read -p "Switch to new configuration? (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sudo nixos-rebuild switch --flake .#fern
                    print_success "System updated and switched"
                fi
            else
                print_error "Test failed"
                return 1
            fi
        fi
    else
        print_success "System is up to date"
    fi
}

# Check for security updates
check_security() {
    print_header "Security Check"
    
    print_status "Checking for security advisories..."
    
    # Check if vulnix is available
    if command -v vulnix >/dev/null 2>&1; then
        print_status "Running vulnerability scan..."
        vulnix --system || true
    else
        print_warning "vulnix not installed - skipping vulnerability scan"
        echo "Install with: nix-env -iA nixpkgs.vulnix"
    fi
}

# Optimize nix store
optimize_store() {
    print_header "Store Optimization"
    
    print_status "Optimizing nix store (this may take a while)..."
    sudo nix-store --optimise
    print_success "Store optimization complete"
}

# Create update report
create_report() {
    local report_file="update-report-$(date +%Y%m%d-%H%M%S).md"
    
    print_header "Creating Update Report"
    
    cat > "$report_file" << EOF
# Update Report - $(date)

## Flake Inputs
\`\`\`
$(nix flake metadata)
\`\`\`

## System Generation
\`\`\`
$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system | tail -1)
\`\`\`

## Disk Usage
\`\`\`
$(df -h /nix/store)
\`\`\`

## Git Status
\`\`\`
$(git status --short)
\`\`\`

---
Generated by update.sh
EOF
    
    print_success "Report saved to: $report_file"
}

# Main menu
show_menu() {
    echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║   NixOS Update & Maintenance Tool    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
    echo
    echo "1) Full update (all steps)"
    echo "2) Update flake inputs only"
    echo "3) Clean old generations"
    echo "4) Update system packages"
    echo "5) Security check"
    echo "6) Optimize store"
    echo "7) Create update report"
    echo "8) Exit"
    echo
}

# Parse arguments for non-interactive mode
if [[ $# -gt 0 ]]; then
    case $1 in
        --all)
            check_git_status
            update_flake
            update_system
            clean_generations
            optimize_store
            create_report
            exit 0
            ;;
        --flake)
            check_git_status
            update_flake
            exit 0
            ;;
        --clean)
            clean_generations
            exit 0
            ;;
        --help)
            cat << EOF
Usage: $0 [option]

Options:
    --all       Run full update process
    --flake     Update flake inputs only
    --clean     Clean old generations only
    --help      Show this help message
    
Without options, runs in interactive mode.

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
fi

# Interactive mode
while true; do
    show_menu
    read -p "Select option [1-8]: " choice
    
    case $choice in
        1)
            check_git_status
            update_flake
            update_system
            clean_generations
            check_security
            optimize_store
            create_report
            ;;
        2)
            check_git_status
            update_flake
            ;;
        3)
            clean_generations
            ;;
        4)
            update_system
            ;;
        5)
            check_security
            ;;
        6)
            optimize_store
            ;;
        7)
            create_report
            ;;
        8)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
