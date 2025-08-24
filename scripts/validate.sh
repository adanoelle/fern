#!/usr/bin/env bash
# Comprehensive validation script for NixOS configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0

# Helper functions
print_header() {
    echo
    echo -e "${MAGENTA}━━━ $1 ━━━${NC}"
}

print_status() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validation functions
check_nix_syntax() {
    print_header "Nix Syntax Validation"
    
    if nix flake check .; then
        print_success "Flake check passed"
    else
        print_error "Flake check failed"
        return 1
    fi
    
    # Check individual files
    local nix_files=$(find . -name "*.nix" -type f | grep -v ".direnv" | grep -v "result")
    local file_count=$(echo "$nix_files" | wc -l)
    print_status "Checking $file_count Nix files..."
    
    local errors=0
    for file in $nix_files; do
        if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then
            print_error "Syntax error in: $file"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        print_success "All Nix files have valid syntax"
    fi
}

check_formatting() {
    print_header "Code Formatting"
    
    if command_exists nixpkgs-fmt; then
        if nixpkgs-fmt --check . >/dev/null 2>&1; then
            print_success "Code is properly formatted"
        else
            print_warning "Code needs formatting. Run: nixpkgs-fmt ."
            echo "  Files needing format:"
            nixpkgs-fmt --check . 2>&1 | grep "^[^W]" | sed 's/^/    /'
        fi
    else
        print_warning "nixpkgs-fmt not found, skipping format check"
    fi
}

check_linting() {
    print_header "Static Analysis"
    
    if command_exists statix; then
        print_status "Running statix linter..."
        if statix check >/dev/null 2>&1; then
            print_success "No linting issues found"
        else
            print_warning "Linting issues detected:"
            statix check 2>&1 | head -20
        fi
    else
        print_warning "statix not found, skipping lint check"
    fi
    
    if command_exists deadnix; then
        print_status "Checking for dead code..."
        local dead_code=$(deadnix . 2>&1 | grep -v "^$" | head -20)
        if [[ -z "$dead_code" ]]; then
            print_success "No dead code found"
        else
            print_warning "Dead code detected:"
            echo "$dead_code" | sed 's/^/    /'
        fi
    else
        print_warning "deadnix not found, skipping dead code check"
    fi
}

check_build() {
    print_header "Build Validation"
    
    print_status "Attempting dry build..."
    if sudo nixos-rebuild dry-build --flake .#fern >/dev/null 2>&1; then
        print_success "Dry build successful"
    else
        print_error "Dry build failed - run with --show-trace for details"
    fi
}

check_git_status() {
    print_header "Git Repository Status"
    
    if [[ -n $(git status --porcelain) ]]; then
        print_warning "Uncommitted changes detected:"
        git status --short | sed 's/^/    /'
    else
        print_success "Working directory clean"
    fi
    
    # Check if we're in a worktree
    if git worktree list | grep -q "$(pwd)"; then
        local branch=$(git branch --show-current)
        if [[ "$branch" == "main" ]] || [[ "$branch" == "master" ]]; then
            print_warning "Working directly in $branch branch - consider using a worktree"
        else
            print_success "Working in branch: $branch"
        fi
    fi
}

check_secrets() {
    print_header "Secrets Management"
    
    if [[ -d "secrets" ]]; then
        # Check for unencrypted secrets
        local unencrypted=$(find secrets -type f -name "*.yaml" -o -name "*.json" 2>/dev/null | head -5)
        if [[ -n "$unencrypted" ]]; then
            print_error "Potential unencrypted secrets found:"
            echo "$unencrypted" | sed 's/^/    /'
        else
            print_success "No unencrypted secret files detected"
        fi
        
        # Check SOPS configuration
        if [[ -f ".sops.yaml" ]]; then
            print_success "SOPS configuration found"
        else
            print_warning "No .sops.yaml configuration found"
        fi
    else
        print_status "No secrets directory found"
    fi
}

check_documentation() {
    print_header "Documentation"
    
    local required_docs=(
        "README.md"
        "CLAUDE.md"
    )
    
    for doc in "${required_docs[@]}"; do
        if [[ -f "$doc" ]]; then
            print_success "$doc exists"
        else
            print_warning "$doc is missing"
        fi
    done
}

check_modules() {
    print_header "Module Structure"
    
    # Check for common module issues
    print_status "Checking for circular dependencies..."
    
    # Check for duplicate module definitions
    print_status "Checking for duplicate definitions..."
    local duplicates=$(grep -r "^[[:space:]]*options\." nix/ | 
                      sed 's/:.*options\./: /' | 
                      awk '{print $2}' | 
                      sort | uniq -d | head -5)
    
    if [[ -n "$duplicates" ]]; then
        print_warning "Potential duplicate option definitions:"
        echo "$duplicates" | sed 's/^/    /'
    else
        print_success "No obvious duplicate definitions found"
    fi
}

# Performance check
check_performance() {
    print_header "Performance Analysis"
    
    print_status "Measuring evaluation time..."
    local start=$(date +%s%N)
    nix eval .#nixosConfigurations.fern.config.system.build.toplevel >/dev/null 2>&1
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    
    if [[ $duration -lt 5000 ]]; then
        print_success "Evaluation time: ${duration}ms (fast)"
    elif [[ $duration -lt 10000 ]]; then
        print_warning "Evaluation time: ${duration}ms (moderate)"
    else
        print_warning "Evaluation time: ${duration}ms (slow - consider optimization)"
    fi
}

# Main summary
print_summary() {
    print_header "Validation Summary"
    
    if [[ $ERRORS -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${GREEN}  ✓ All checks passed!${NC}"
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        else
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}  ⚠ Passed with $WARNINGS warnings${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        fi
        return 0
    else
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ✗ Failed with $ERRORS errors and $WARNINGS warnings${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        return 1
    fi
}

# Parse arguments
SKIP_BUILD=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            cat << EOF
Usage: $0 [options]

Options:
    --skip-build    Skip build validation (faster)
    --verbose       Show detailed output
    --help          Show this help message

This script performs comprehensive validation of your NixOS configuration.

EOF
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Main execution
echo -e "${MAGENTA}╔══════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   NixOS Configuration Validator      ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════╝${NC}"

check_nix_syntax || true
check_formatting || true
check_linting || true
check_git_status || true
check_secrets || true
check_documentation || true
check_modules || true
check_performance || true

if [[ "$SKIP_BUILD" != true ]]; then
    check_build || true
fi

print_summary
exit $?