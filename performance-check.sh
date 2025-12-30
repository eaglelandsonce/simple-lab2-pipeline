#!/bin/bash

# Performance and Health Check Script
# This script runs comprehensive checks on the application including
# lint, tests, build verification, and health metrics

set -e  # Exit on error

echo "========================================"
echo "🔍 Performance & Health Check"
echo "========================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track results
LINT_STATUS="PENDING"
TEST_STATUS="PENDING"
BUILD_STATUS="PENDING"
HEALTH_STATUS="PENDING"

# Function to print section headers
print_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Check Node.js and npm versions
print_section "Environment Information"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Working directory: $(pwd)"
echo "Date: $(date)"

# 2. Run linting
print_section "Running Lint Checks"
if npm run lint > /tmp/lint.log 2>&1; then
    LINT_STATUS="PASSED"
    print_success "Linting passed"
    cat /tmp/lint.log
else
    LINT_STATUS="FAILED"
    print_error "Linting failed"
    cat /tmp/lint.log
fi

# 3. Run tests
print_section "Running Tests"
if npm test > /tmp/test.log 2>&1; then
    TEST_STATUS="PASSED"
    print_success "All tests passed"
    cat /tmp/test.log | tail -20
else
    TEST_STATUS="FAILED"
    print_error "Tests failed"
    cat /tmp/test.log | tail -20
fi

# 4. Build verification
print_section "Build Verification"
if npm run build > /tmp/build.log 2>&1; then
    BUILD_STATUS="PASSED"
    print_success "Build completed successfully"
    
    # Check if build artifacts exist
    if [ -d "dist" ]; then
        echo "Build artifacts found in dist/:"
        ls -lh dist/
        
        # Check build-info.json
        if [ -f "dist/build-info.json" ]; then
            print_success "build-info.json found"
            echo "Build information:"
            cat dist/build-info.json | jq . 2>/dev/null || cat dist/build-info.json
        else
            print_warning "build-info.json not found"
        fi
    else
        print_warning "dist/ directory not found"
    fi
else
    BUILD_STATUS="FAILED"
    print_error "Build failed"
    cat /tmp/build.log
fi

# 5. Health check (if server is running)
print_section "Health & Performance Metrics"

# Start server in background for testing
echo "Starting server for health checks..."
PORT=3001 npm start > /tmp/server.log 2>&1 &
SERVER_PID=$!
sleep 2

# Check if server is running
if ps -p $SERVER_PID > /dev/null; then
    print_success "Server started (PID: $SERVER_PID)"
    
    # Test /health endpoint
    if curl -s http://localhost:3001/health > /tmp/health.json; then
        HEALTH_STATUS="PASSED"
        print_success "Health endpoint responding"
        echo "Health data:"
        cat /tmp/health.json | jq . 2>/dev/null || cat /tmp/health.json
    else
        HEALTH_STATUS="FAILED"
        print_error "Health endpoint not responding"
    fi
    
    # Test /performance endpoint
    echo ""
    if curl -s http://localhost:3001/performance > /tmp/performance.json; then
        print_success "Performance endpoint responding"
        echo "Performance metrics:"
        cat /tmp/performance.json | jq . 2>/dev/null || cat /tmp/performance.json
    else
        print_warning "Performance endpoint not responding"
    fi
    
    # Test /build-info endpoint
    echo ""
    if curl -s http://localhost:3001/build-info > /tmp/buildinfo.json; then
        print_success "Build-info endpoint responding"
        echo "Build info:"
        cat /tmp/buildinfo.json | jq . 2>/dev/null || cat /tmp/buildinfo.json
    else
        print_warning "Build-info endpoint not responding"
    fi
    
    # Stop the server
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
    print_success "Server stopped"
else
    HEALTH_STATUS="FAILED"
    print_error "Server failed to start"
    cat /tmp/server.log
fi

# 6. Code quality metrics
print_section "Code Quality Metrics"
echo "Lines of code in src/:"
find src -name "*.js" -exec wc -l {} + | tail -1
echo ""
echo "Number of test files:"
find tests -name "*.test.js" | wc -l
echo ""
echo "Total test count:"
grep -r "test\\|it(" tests/ | wc -l || echo "0"

# 7. Dependency check
print_section "Dependency Information"
echo "Production dependencies:"
cat package.json | jq '.dependencies' 2>/dev/null || grep -A 10 '"dependencies"' package.json
echo ""
echo "Dev dependencies:"
cat package.json | jq '.devDependencies' 2>/dev/null || grep -A 10 '"devDependencies"' package.json

# 8. Generate summary
print_section "Summary Report"
echo ""
echo "Check Results:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to print status with color
print_status() {
    local name=$1
    local status=$2
    
    if [ "$status" = "PASSED" ]; then
        echo -e "  $name: ${GREEN}✅ PASSED${NC}"
    elif [ "$status" = "FAILED" ]; then
        echo -e "  $name: ${RED}❌ FAILED${NC}"
    else
        echo -e "  $name: ${YELLOW}⚠️  PENDING${NC}"
    fi
}

print_status "Lint" "$LINT_STATUS"
print_status "Tests" "$TEST_STATUS"
print_status "Build" "$BUILD_STATUS"
print_status "Health" "$HEALTH_STATUS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Calculate overall status
if [ "$LINT_STATUS" = "PASSED" ] && [ "$TEST_STATUS" = "PASSED" ] && [ "$BUILD_STATUS" = "PASSED" ] && [ "$HEALTH_STATUS" = "PASSED" ]; then
    print_success "All checks passed! 🎉"
    echo ""
    exit 0
elif [ "$LINT_STATUS" = "FAILED" ] || [ "$TEST_STATUS" = "FAILED" ]; then
    print_error "Critical checks failed"
    echo ""
    exit 1
else
    print_warning "Some checks did not pass"
    echo ""
    exit 1
fi
