#!/usr/bin/env bash

# Bore Documentation Validation Script
# Validate documentation files and ensure they meet project standards

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_header() {
    echo -e "${BLUE}[$1]${NC} $2"
}

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validation functions
validate_file_existence() {
    log_header "CHECK" "Validating required files exist"
    
    local required_files=(
        "README.md"
        "fa/README.md"
        "CONTRIBUTING.md"
        ".markdownlintrc"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$file" ]; then
            missing_files+=("$file")
            log_error "❌ Required file not found: $file"
        else
            log_info "✅ Found: $file"
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        log_info "✅ All required files are present"
        return 0
    else
        log_error "❌ Missing files: ${missing_files[*]}"
        return 1
    fi
}

validate_markdown_syntax() {
    log_header "SYNTAX" "Validating Markdown syntax"
    
    if command -v markdown-validator >/dev/null 2>&1; then
        log_info "Running markdown-validator..."
        
        if markdown-validator README.md fa/README.md CONTRIBUTING.md; then
            log_info "✅ All markdown files have valid syntax"
            return 0
        else
            log_error "❌ Markdown syntax validation failed"
            return 1
        fi
    else
        log_warning "markdown-validator not available, skipping syntax validation"
        return 0
    fi
}

validate_documentation_completeness() {
    log_header "COMPLETENESS" "Validating documentation completeness"
    
    # Check for required sections in main README
    if ! grep -q "# 🎯 Project Overview" "$PROJECT_ROOT/README.md"; then
        log_error "❌ Main README missing project overview section"
        return 1
    fi
    
    if ! grep -q "# 📋 Table of Contents" "$PROJECT_ROOT/README.md"; then
        log_error "❌ Main README missing table of contents"
        return 1
    fi
    
    if ! grep -q "## 🚀 Quick Start" "$PROJECT_ROOT/README.md"; then
        log_error "❌ Main README missing quick start section"
        return 1
    fi
    
    # Check Persian README completeness
    if ! grep -q "# 🎯 هدف پروژه" "$PROJECT_ROOT/fa/README.md"; then
        log_error "❌ Persian README missing project overview section"
        return 1
    fi
    
    if ! grep -q "# 📋 فهرست مطالب" "$PROJECT_ROOT/fa/README.md"; then
        log_error "❌ Persian README missing table of contents"
        return 1
    fi
    
    log_info "✅ Documentation completeness check passed"
    return 0
}

validate_contributing_guide() {
    log_header "CONTRIBUTING" "Validating contributing guide"
    
    if [ ! -f "$PROJECT_ROOT/CONTRIBUTING.md" ]; then
        log_error "❌ CONTRIBUTING.md not found"
        return 1
    fi
    
    # Check for essential sections
    local required_sections=(
        "How to Contribute"
        "Pull Request Process"
        "Code of Conduct"
        "Getting Help"
        "Common Mistakes"
    )
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$PROJECT_ROOT/CONTRIBUTING.md"; then
            log_warning "⚠️  Missing section in CONTRIBUTING.md: $section"
        fi
    done
    
    log_info "✅ Contributing guide validation completed"
    return 0
}

validate_security_compliance() {
    log_header "SECURITY" "Checking security compliance"
    
    # Check for sensitive information in documentation
    local sensitive_patterns=(
        "password:\s*[^\s]"
        "secret:\s*[^\s]"
        "api[_-]?key:\s*[^\s]"
        "token:\s*[^\s]"
        "aws[_-]?access[_-]?key"
    )
    
    local issues_found=0
    
    for pattern in "${sensitive_patterns[@]}"; do
        if grep -r "$pattern" "$PROJECT_ROOT" --exclude-dir=".git" --exclude="*.sh" 2>/dev/null; then
            log_warning "⚠️  Potential sensitive information found matching pattern: $pattern"
            ((issues_found++))
        fi
    done
    
    if [ $issues_found -eq 0 ]; then
        log_info "✅ No obvious security issues found"
    else
        log_warning "⚠️  Found $issues_found potential security issues. Manual review recommended."
    fi
    
    log_info "✅ Security compliance check completed"
    return 0
}

validate_readme_quality() {
    log_header "QUALITY" "Validating README.md quality"
    
    # Check README length
    local readme_length=$(wc -w < "$PROJECT_ROOT/README.md")
    
    if [ $readme_length -lt 1000 ]; then
        log_warning "⚠️  README.md seems quite short ($readme_length words). Consider adding more content."
    else
        log_info "✅ README.md has substantial content (${readme_length} words)"
    fi
    
    # Check for code examples
    local code_examples=$(grep -c "```" "$PROJECT_ROOT/README.md")
    log_info "Found $code_examples code blocks in README.md"
    
    # Check for tables
    local tables=$(grep -c "|" "$PROJECT_ROOT/README.md")
    if [ $tables -gt 0 ]; then
        log_info "Found $tables potential tables in README.md"
    fi
    
    log_info "✅ README.md quality check completed"
    return 0
}

validate_fa_readme_quality() {
    log_header "QUALITY" "Validating Persian README.md quality"
    
    # Check Persian README length
    local fa_readme_length=$(wc -w < "$PROJECT_ROOT/fa/README.md")
    
    if [ $fa_readme_length -lt 1000 ]; then
        log_warning "⚠️  Persian README.md seems quite short ($fa_readme_length words). Consider adding more content."
    else
        log_info "✅ Persian README.md has substantial content (${fa_readme_length} words)"
    fi
    
    # Check for Persian content
    local farsi_characters=$(grep -o '[\u0600-\u06FF]' "$PROJECT_ROOT/fa/README.md" | wc -l)
    if [ $farsi_characters -gt 0 ]; then
        log_info "✅ Persian README contains $farsi_characters Persian characters"
    else
        log_warning "⚠️  Persian README.md may not contain sufficient Persian content"
    fi
    
    log_info "✅ Persian README.md quality check completed"
    return 0
}

validate_git_repository() {
    log_header "GIT" "Validating git repository"
    
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        log_error "❌ Not a git repository"
        return 1
    fi
    
    # Check if there are any staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        log_info "📝 There are staged changes"
    fi
    
    # Get repository info
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local commits=$(git log --oneline --count 5 2>/dev/null | wc -l)
    
    log_info "✅ Git repository found"
    log_info "   Branch: $branch"
    log_info "   Recent commits: $commits"
    
    log_info "✅ Git repository validation completed"
    return 0
}

main() {
    log_header "START" "Starting documentation validation for Bore Secure Server Documentation"
    
    # Parse command line arguments
    local validate_only=false
    local skip_git=false
    
    for arg in "$@"; do
        case $arg in
            --validate-only)
                validate_only=true
                ;;
            --skip-git)
                skip_git=true
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --validate-only   Validate only, don't check git status"
                echo "  --skip-git       Skip git repository validation"
                echo "  --help           Show this help message"
                exit 0
                ;;
        esac
    done
    
    # Run validation steps
    local validation_errors=0
    
    # File existence validation
    if ! validate_file_existence; then
        ((validation_errors++))
    fi
    
    # Markdown syntax validation
    if ! validate_markdown_syntax; then
        ((validation_errors++))
    fi
    
    # Documentation completeness validation
    if ! validate_documentation_completeness; then
        ((validation_errors++))
    fi
    
    # Contributing guide validation
    if ! validate_contributing_guide; then
        ((validation_errors++))
    fi
    
    # Security compliance validation
    if ! validate_security_compliance; then
        ((validation_errors++))
    fi
    
    # README quality validation
    if ! validate_readme_quality; then
        ((validation_errors++))
    fi
    
    # Persian README quality validation
    if ! validate_fa_readme_quality; then
        ((validation_errors++))
    fi
    
    # Git repository validation (unless skipped)
    if [ "$skip_git" = false ]; then
        if ! validate_git_repository; then
            ((validation_errors++))
        fi
    fi
    
    # Summary
    log_header "SUMMARY" "Validation completed"
    
    if [ $validation_errors -eq 0 ]; then
        log_info "🎉 All validations passed! Documentation is ready."
        exit 0
    else
        log_error "❌ $validation_errors validation errors found. Please review the issues above."
        exit 1
    fi
}

# Run main function
main "$@"
