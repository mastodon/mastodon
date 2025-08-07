#!/bin/bash

# Security Implementation Verification Script
# This script verifies that all security enhancements have been properly implemented

echo "🔒 Mastodon Security Implementation Verification"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $description - File not found: $file"
        ((FAILED++))
        return 1
    fi
}

check_content() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $description - Pattern not found in $file"
        ((FAILED++))
        return 1
    fi
}

check_warning() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$file" ] && grep -q "$pattern" "$file"; then
        echo -e "${YELLOW}⚠${NC} $description"
        ((WARNINGS++))
        return 0
    else
        echo -e "${GREEN}✓${NC} $description (secure configuration)"
        ((PASSED++))
        return 1
    fi
}

echo "1. Session Security Configuration"
echo "--------------------------------"
check_content "config/initializers/session_store.rb" "secure: Rails.env.production?" "Session cookies secure flag configured"
check_content "config/initializers/session_store.rb" "httponly: true" "Session cookies httponly flag enabled"
check_content "config/initializers/devise.rb" "secure: Rails.env.production?" "Devise cookies secure flag configured"
echo ""

echo "2. CSRF Protection Enhancement"
echo "-----------------------------"
check_content "config/initializers/suppress_csrf_warnings.rb" "if Rails.env.test?" "CSRF warnings conditional suppression"
check_content "config/initializers/suppress_csrf_warnings.rb" "log_warning_on_csrf_failure = true" "CSRF warnings enabled in production"
echo ""

echo "3. Rate Limiting Configuration"
echo "-----------------------------"
check_content "config/initializers/rack_attack.rb" "throttle_admin_actions" "Admin actions rate limiting"
check_content "config/initializers/rack_attack.rb" "throttle_webhooks" "Webhooks rate limiting"
check_content "config/initializers/rack_attack.rb" "throttle_search" "Search rate limiting"
check_content "config/initializers/rack_attack.rb" "Rails.logger.warn.*Rate limit exceeded" "Rate limiting logging"
echo ""

echo "4. Security Headers"
echo "------------------"
check_file "config/initializers/security_headers.rb" "Security headers middleware"
check_content "config/initializers/security_headers.rb" "X-Frame-Options.*DENY" "X-Frame-Options header"
check_content "config/initializers/security_headers.rb" "X-Content-Type-Options.*nosniff" "X-Content-Type-Options header"
check_content "config/initializers/security_headers.rb" "Strict-Transport-Security" "HSTS header for production"
echo ""

echo "5. Content Security Policy"
echo "-------------------------"
check_content "config/initializers/content_security_policy.rb" "object_src.*:none" "CSP object-src restriction"
check_content "config/initializers/content_security_policy.rb" "plugin_types.*:none" "CSP plugin-types restriction"
check_warning "config/initializers/content_security_policy.rb" "wasm-unsafe-eval" "CSP unsafe-eval check"
echo ""

echo "6. Input Validation Enhancement"
echo "------------------------------"
check_file "config/initializers/security_validators.rb" "Security validators"
check_content "config/initializers/security_validators.rb" "validate_strong_password" "Strong password validation"
check_content "config/initializers/security_validators.rb" "validate_username_not_admin_like" "Admin username prevention"
check_content "config/initializers/security_validators.rb" "validate_email_not_suspicious" "Suspicious email detection"
echo ""

echo "7. Security Monitoring"
echo "---------------------"
check_file "config/initializers/security_monitoring.rb" "Security monitoring system"
check_content "config/initializers/security_monitoring.rb" "SecurityMonitor" "Security monitor class"
check_content "config/initializers/security_monitoring.rb" "ALERT_THRESHOLDS" "Alert thresholds configuration"
echo ""

echo "8. Security Tests"
echo "----------------"
check_file "spec/requests/security_spec.rb" "Security test suite"
check_content "spec/requests/security_spec.rb" "Session Cookie Security" "Session cookie tests"
check_content "spec/requests/security_spec.rb" "Security Headers" "Security headers tests"
check_content "spec/requests/security_spec.rb" "Rate Limiting" "Rate limiting tests"
echo ""

echo "9. Documentation"
echo "---------------"
check_file "SECURITY_ANALYSIS_GUIDE.md" "Security analysis guide"
check_content "SECURITY_ANALYSIS_GUIDE.md" "RESUELTO" "Implementation status documented"
echo ""

echo "=============================================="
echo "Summary:"
echo -e "${GREEN}✓ Passed: $PASSED${NC}"
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
fi
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}✗ Failed: $FAILED${NC}"
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All security implementations verified successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run the test suite: bundle exec rspec spec/requests/security_spec.rb"
    echo "2. Deploy to staging environment for testing"
    echo "3. Monitor security alerts and logs"
    echo "4. Schedule regular security audits"
    exit 0
else
    echo -e "${RED}❌ Some security implementations are missing or incomplete.${NC}"
    echo "Please review the failed checks above and ensure all security enhancements are properly implemented."
    exit 1
fi
