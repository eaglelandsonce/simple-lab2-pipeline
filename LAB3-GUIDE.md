# Lab 3 Guide: Advanced CI/CD Pipeline

## 📋 Overview

This Lab 3 project demonstrates advanced CI/CD concepts including optimized workflows, error handling strategies, performance monitoring, and comprehensive testing. It builds upon the basic pipeline from Lab 2 by adding production-ready features.

## 🏗️ What Was Built

### 1. **Enhanced Express Application** (`src/app.js`)

The application now includes production-ready monitoring endpoints:

- **`GET /health`** - Returns application health status
  ```json
  {
    "status": "ok",
    "env": "development",
    "version": "1.0.0"
  }
  ```

- **`GET /build-info`** - Returns build metadata (when available)
  ```json
  {
    "buildTime": "2025-12-30T02:22:42.409Z",
    "buildNumber": "123",
    "gitCommit": "abc123",
    "gitBranch": "main",
    "environment": "production",
    "nodeVersion": "v18.x.x"
  }
  ```

- **`GET /performance`** - Returns runtime performance metrics
  ```json
  {
    "uptimeSeconds": 45.123,
    "memory": {
      "rss": 50331648,
      "heapTotal": 20971520,
      "heapUsed": 10485760
    }
  }
  ```

- **404 Handler** - All unknown routes return JSON error responses

### 2. **Build System** (`scripts/build.js`)

Automated build script that:
- Creates `dist/` directory with compiled code
- Generates `build-info.json` with build metadata
- Captures CI/CD environment variables (GitHub Actions)
- Ensures reproducible builds

### 3. **Comprehensive Testing** (`tests/app.test.js`)

Full test suite covering:
- ✅ Health endpoint validation
- ✅ Performance metrics verification
- ✅ Build info endpoint (graceful degradation)
- ✅ 404 error handling
- ✅ Response format validation
- ✅ Legacy endpoint compatibility

**7 test suites** with complete coverage of all endpoints and error scenarios.

### 4. **Optimized CI Workflow** (`.github/workflows/optimized-ci.yml`)

Production-ready pipeline featuring:

#### Key Features:
- **Environment Detection**
  - `main` branch → Production
  - `develop` branch → Staging
  - Other branches → Development

- **Docs-Only Detection**
  - Skips build/test for markdown-only changes
  - Saves CI resources and time

- **Parallel Quality Checks**
  - Lint and tests run simultaneously via matrix strategy
  - Faster feedback loop

- **Build Optimization**
  - Node.js setup with npm caching
  - Artifact upload with 7-day retention
  - Build artifacts available for deployment

- **Conditional Deployment**
  - Only deploys to production when:
    - Branch is `main` (prod environment)
    - Changes are not docs-only
    - All quality checks pass

#### Workflow Jobs:
1. **Setup** - Determine environment and detect docs-only changes
2. **Quality** - Run lint and tests in parallel (matrix)
3. **Build** - Build application and upload artifacts
4. **Deploy** - Deploy to production (conditional)

### 5. **Error Handling Workflow** (`.github/workflows/error-handling.yml`)

Interactive demonstration workflow showcasing error recovery patterns:

#### Error Scenarios:
- **Dependency Failure** - npm install fails
- **Test Failure** - Unit tests fail
- **Build Failure** - Build process fails
- **No Error** - Happy path for comparison

#### Recovery Strategies:

**1. Fail Fast** ⚡
- Stops immediately when an error occurs
- Best for: Critical failures that should halt pipeline
- Implementation: `fail-fast: true` in matrix

**2. Continue on Error** 🔄
- Allows workflow to proceed despite failures
- Best for: Non-critical checks, gathering complete results
- Implementation: `continue-on-error: true`

**3. Retry** 🔁
- Automatically retries failed steps (2-3 attempts)
- Best for: Flaky tests, network issues, transient failures
- Implementation: `nick-fields/retry@v3` action

#### Features:
- Manual trigger via `workflow_dispatch`
- Configurable inputs (error type + recovery strategy)
- Comprehensive summary report
- Educational comments explaining each pattern

### 6. **Performance Monitoring Script** (`performance-check.sh`)

Automated health and quality check script that:
- ✅ Runs linting checks
- ✅ Executes test suite
- ✅ Verifies build process
- ✅ Tests all API endpoints
- ✅ Collects performance metrics
- ✅ Generates summary report

## 🚀 How to Run

### Local Development

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Run Tests**
   ```bash
   npm test
   ```

3. **Run Linting**
   ```bash
   npm run lint
   ```

4. **Build Application**
   ```bash
   npm run build
   ```

5. **Start Server**
   ```bash
   npm start
   ```

6. **Run Performance Checks**
   ```bash
   chmod +x performance-check.sh
   ./performance-check.sh
   ```

### Test Endpoints

Once the server is running:

```bash
# Health check
curl http://localhost:3000/health

# Performance metrics
curl http://localhost:3000/performance

# Build info
curl http://localhost:3000/build-info

# Test 404 handling
curl http://localhost:3000/nonexistent
```

## 🧪 Verification Steps

### 1. Verify Local Functionality

```bash
# Run all checks
./performance-check.sh
```

Expected output:
- ✅ Linting passes
- ✅ All 7 tests pass
- ✅ Build succeeds
- ✅ Server responds to health checks
- ✅ Performance metrics available

### 2. Verify GitHub Actions

#### Test Optimized CI Workflow:

1. **Trigger on Push**
   ```bash
   git add .
   git commit -m "Test optimized CI"
   git push origin main
   ```
   - ✅ Workflow runs automatically
   - ✅ Environment detected as "prod"
   - ✅ Quality checks run in parallel
   - ✅ Build artifacts uploaded
   - ✅ Deploy job evaluates conditions

2. **Test Docs-Only Detection**
   ```bash
   echo "# Update" >> README.md
   git add README.md
   git commit -m "Update docs"
   git push origin main
   ```
   - ✅ Docs-only changes detected
   - ✅ Quality checks skipped
   - ✅ Build skipped (resource optimization)

3. **Test Branch Environments**
   ```bash
   git checkout -b develop
   git push origin develop
   ```
   - ✅ Environment detected as "staging"
   - ✅ Deploy job skipped (not production)

#### Test Error Handling Workflow:

1. Go to **Actions** tab in GitHub
2. Select **Error Handling Demonstration**
3. Click **Run workflow**
4. Choose combinations:
   - Error: `test` + Strategy: `fail-fast`
   - Error: `build` + Strategy: `continue-on-error`
   - Error: `dependency` + Strategy: `retry`
   - Error: `none` + Strategy: `fail-fast` (happy path)
5. Review summary report in workflow output

### 3. Verify Build Artifacts

```bash
# Check dist contents
ls -la dist/

# Verify build-info.json
cat dist/build-info.json | jq .
```

Expected contents:
- `dist/app.js` - Compiled application
- `dist/build-info.json` - Build metadata

### 4. Verify Test Coverage

```bash
npm test
```

Expected results:
- Simple App Tests (2 tests)
- Health Endpoint Tests (1 test)
- Performance Endpoint Tests (1 test)
- Build Info Endpoint Tests (1 test)
- 404 Handling Tests (2 tests)

**Total: 7 tests passing**

## 📊 CI/CD Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Push to GitHub                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Setup Job                                                   │
│  • Detect environment (main=prod, develop=staging, etc)     │
│  • Check for docs-only changes                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
              ┌─────────┴─────────┐
              │                   │
              ▼                   ▼
    ┌─────────────────┐ ┌─────────────────┐
    │   Lint Check    │ │   Test Suite    │  (Parallel)
    │   (Matrix)      │ │   (Matrix)      │
    └────────┬────────┘ └────────┬────────┘
              │                   │
              └─────────┬─────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Build Job                                                   │
│  • Run npm build                                            │
│  • Generate build-info.json                                 │
│  • Upload artifacts                                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Deploy Job (Conditional)                                    │
│  IF: env=prod AND !docs-only AND build=success             │
│  • Download artifacts                                       │
│  • Deploy to production                                     │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Key Learning Objectives

1. **Environment Management**
   - Dynamic environment detection based on branch
   - Environment-specific configurations
   - Conditional deployment logic

2. **Performance Optimization**
   - npm caching for faster installs
   - Parallel job execution (matrix strategy)
   - Docs-only change detection
   - Resource-efficient workflows

3. **Error Handling**
   - Fail-fast vs continue-on-error patterns
   - Retry logic for transient failures
   - Graceful degradation in applications
   - Comprehensive error reporting

4. **Build Optimization**
   - Automated build process
   - Build metadata capture
   - Artifact management and retention
   - Reproducible builds with version tracking

5. **Monitoring & Observability**
   - Health check endpoints
   - Performance metrics collection
   - Runtime monitoring
   - Build information tracking

## 🔧 Troubleshooting

### Tests Failing

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
npm test
```

### Build Not Creating dist/

```bash
# Run build script directly
node scripts/build.js
ls -la dist/
```

### Server Won't Start

```bash
# Check port availability
lsof -i :3000
# Use different port
PORT=3001 npm start
```

### Performance Script Fails

```bash
# Make executable
chmod +x performance-check.sh

# Install jq for JSON parsing (optional)
sudo apt-get install jq

# Run with debug
bash -x ./performance-check.sh
```

### GitHub Actions Not Triggering

- Verify workflow files in `.github/workflows/`
- Check branch protection rules
- Ensure Actions are enabled in repository settings
- Review GitHub Actions permissions

## 📝 Best Practices Demonstrated

1. **Testing**: Comprehensive test coverage with 7 test cases
2. **Documentation**: Inline comments and comprehensive guides
3. **Error Handling**: Graceful degradation and proper error responses
4. **Monitoring**: Multiple health check endpoints
5. **CI/CD**: Optimized workflows with caching and parallelization
6. **Security**: Environment-based configurations, no hardcoded secrets
7. **Maintainability**: Clear code structure and modular design

## 🎓 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Express.js Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)
- [CI/CD Best Practices](https://docs.github.com/en/actions/guides/about-continuous-integration)

## 📈 Next Steps

To extend this lab:
1. Add code coverage reporting (Istanbul/nyc)
2. Implement actual deployment to cloud provider
3. Add database integration with health checks
4. Set up monitoring dashboards (Grafana/Prometheus)
5. Implement semantic versioning automation
6. Add security scanning (Dependabot, Snyk)
7. Create staging environment workflow
8. Add performance benchmarking tests

---

**Lab Completed Successfully! 🎉**

For questions or issues, refer to the troubleshooting section or review the inline code comments.

## Verification Test

Testing docs-only detection.
