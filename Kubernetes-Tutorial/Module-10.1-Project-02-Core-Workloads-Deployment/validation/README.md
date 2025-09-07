# E-commerce Application Validation & Testing Suite

## 📋 Overview

This directory contains comprehensive validation and testing scripts for the e-commerce application deployed on Kubernetes. The testing suite ensures that all components are functioning correctly, performing within expected parameters, and meeting production readiness standards.

## 🧪 Test Scripts

### 1. `validate-monitoring-stack.sh`
**Purpose**: Validates the complete monitoring stack deployment and configuration.

**Features**:
- ✅ **Namespace validation** (ResourceQuota, LimitRange, labels)
- ✅ **Prometheus validation** (deployment, service, ConfigMap, PVC)
- ✅ **Grafana validation** (deployment, service, PVC)
- ✅ **AlertManager validation** (deployment, service, ConfigMap, PVC)
- ✅ **E-commerce application validation** (all deployments and services)
- ✅ **Monitoring integration validation** (target discovery, scraping)
- ✅ **Comprehensive error reporting** with colored output
- ✅ **Detailed status checks** for all components

**Usage**:
```bash
# Basic validation
./validate-monitoring-stack.sh

# Validate specific namespace
./validate-monitoring-stack.sh production

# Example output
[INFO] Starting monitoring stack validation for namespace: ecommerce
[SUCCESS] Prerequisites check passed
[SUCCESS] Prometheus deployment exists
[SUCCESS] Prometheus service is accessible on port 9090
[SUCCESS] All critical validations passed! Monitoring stack is ready.
```

### 2. `health-check.sh`
**Purpose**: Performs deep health checks on all application components.

**Features**:
- ✅ **Pod health validation** (status, readiness, restarts, resource usage)
- ✅ **Service health validation** (connectivity, endpoints, accessibility)
- ✅ **Deployment health validation** (replicas, availability, updates)
- ✅ **PVC health validation** (binding status, capacity)
- ✅ **Resource monitoring** (CPU, memory usage)
- ✅ **JSON output support** for integration with monitoring systems
- ✅ **Detailed health reporting** with component-specific checks

**Usage**:
```bash
# Basic health check
./health-check.sh

# Detailed health check with resource monitoring
./health-check.sh ecommerce --detailed

# JSON output for monitoring integration
./health-check.sh ecommerce --json

# Example output
[INFO] Checking health of pod: prometheus-deployment-xxx
[SUCCESS] Pod prometheus-deployment-xxx is healthy
[INFO] Checking health of service: prometheus-service
[SUCCESS] Service prometheus-service is accessible on port 9090
```

### 3. `performance-test.sh`
**Purpose**: Comprehensive performance testing and load validation.

**Features**:
- ✅ **Load testing** with configurable duration, concurrency, and rate
- ✅ **Stress testing** with gradually increasing load
- ✅ **Database performance testing** (query performance, indexing)
- ✅ **Monitoring stack performance testing** (Prometheus queries, Grafana access)
- ✅ **Resource monitoring** during tests
- ✅ **Performance metrics collection** (RPS, response times, error rates)
- ✅ **Multiple test types** (load, stress, database, monitoring, full)

**Usage**:
```bash
# Load test (default: 300s, 10 concurrent users, 100 RPS)
./performance-test.sh

# Custom load test
./performance-test.sh ecommerce --duration=60s --concurrent=20 --rate=200

# Stress test
./performance-test.sh ecommerce --type=stress

# Database performance test
./performance-test.sh ecommerce --type=database

# Full performance test suite
./performance-test.sh ecommerce --type=full

# Example output
[INFO] Running BackendAPI test on http://10.96.0.1:8000/
[SUCCESS] BackendAPI test completed
[INFO] Results: 1000 requests, 150.5 RPS, 45.2ms avg response time
```

### 4. `run-tests.sh`
**Purpose**: Master test runner that orchestrates all testing activities.

**Features**:
- ✅ **Test orchestration** (validation, health, performance)
- ✅ **Parallel execution** support for faster testing
- ✅ **Comprehensive reporting** (HTML and JSON formats)
- ✅ **Test result aggregation** with pass/fail statistics
- ✅ **Verbose logging** for detailed debugging
- ✅ **Configurable test types** (all, validation, health, performance)
- ✅ **Timestamped output** for test result tracking

**Usage**:
```bash
# Run all tests
./run-tests.sh

# Run specific test type
./run-tests.sh ecommerce --type=validation
./run-tests.sh ecommerce --type=health
./run-tests.sh ecommerce --type=performance

# Run with verbose output
./run-tests.sh ecommerce --verbose

# Run tests in parallel
./run-tests.sh ecommerce --parallel

# Custom output directory
./run-tests.sh ecommerce --output-dir=/tmp/test-results

# Example output
[HEADER] Starting comprehensive test suite for namespace: ecommerce
[INFO] Test type: all
[SUCCESS] NamespaceValidation test passed
[SUCCESS] HealthCheck test passed
[SUCCESS] LoadTest test passed
[SUCCESS] All tests passed! Application is ready for production.
```

## 📊 Test Results

### Output Files
All test scripts generate timestamped output files in the `test-results/` directory:

- **`{test_name}_{timestamp}.log`** - Detailed test execution logs
- **`test_report_{timestamp}.html`** - HTML test report with summary
- **`test_report_{timestamp}.json`** - JSON test report for integration
- **`resource-usage_{namespace}.csv`** - Resource usage data during tests

### HTML Report Features
- 📈 **Visual test summary** with pass/fail statistics
- 🔗 **Clickable log links** for detailed investigation
- 📋 **Test result table** with status and log file references
- 🎨 **Color-coded results** (green for pass, red for fail)
- ⏰ **Timestamped reports** for historical tracking

### JSON Report Features
- 🤖 **Machine-readable format** for automation integration
- 📊 **Structured test results** with metadata
- 🔢 **Quantitative metrics** (success rates, performance data)
- 🔄 **API-friendly format** for monitoring systems

## 🚀 Quick Start

### Prerequisites
```bash
# Ensure kubectl is installed and configured
kubectl version --client

# Ensure required tools are available
which curl jq bc

# Ensure namespace exists
kubectl get namespace ecommerce
```

### Basic Validation
```bash
# Navigate to validation directory
cd validation/

# Make scripts executable (if not already done)
chmod +x *.sh

# Run basic validation
./validate-monitoring-stack.sh

# Run health check
./health-check.sh

# Run performance test
./performance-test.sh

# Run complete test suite
./run-tests.sh
```

### Advanced Usage
```bash
# Run tests with custom parameters
./run-tests.sh production --type=performance --verbose --parallel

# Run specific performance test
./performance-test.sh production --type=load --duration=120s --concurrent=50 --rate=500

# Run health check with detailed resource monitoring
./health-check.sh production --detailed

# Run validation with JSON output
./health-check.sh production --json > health-status.json
```

## 🔧 Configuration

### Environment Variables
```bash
# Set default namespace
export DEFAULT_NAMESPACE=ecommerce

# Set test output directory
export TEST_OUTPUT_DIR=./test-results

# Set performance test parameters
export DEFAULT_DURATION=300s
export DEFAULT_CONCURRENT=10
export DEFAULT_RATE=100
```

### Test Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `namespace` | `ecommerce` | Kubernetes namespace to test |
| `duration` | `300s` | Test duration for performance tests |
| `concurrent` | `10` | Number of concurrent users |
| `rate` | `100` | Request rate per second |
| `type` | `all` | Test type (all, validation, health, performance) |

## 📈 Performance Thresholds

### Response Time Standards
- **< 200ms**: Excellent performance
- **200-500ms**: Good performance
- **500-1000ms**: Acceptable performance
- **> 1000ms**: Poor performance (investigation required)

### Error Rate Standards
- **< 1%**: Excellent reliability
- **1-5%**: Good reliability
- **5-10%**: Acceptable reliability
- **> 10%**: Poor reliability (investigation required)

### Resource Usage Standards
- **CPU < 70%**: Normal usage
- **CPU 70-90%**: High usage (monitor closely)
- **CPU > 90%**: Critical usage (investigation required)
- **Memory < 80%**: Normal usage
- **Memory 80-95%**: High usage (monitor closely)
- **Memory > 95%**: Critical usage (investigation required)

## 🛠️ Troubleshooting

### Common Issues

#### 1. "kubectl command not found"
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### 2. "Namespace not found"
```bash
# Create namespace
kubectl create namespace ecommerce

# Or check existing namespaces
kubectl get namespaces
```

#### 3. "Service not accessible"
```bash
# Check service status
kubectl get services -n ecommerce

# Check service endpoints
kubectl get endpoints -n ecommerce

# Check pod status
kubectl get pods -n ecommerce
```

#### 4. "Performance test failures"
```bash
# Check resource limits
kubectl describe nodes

# Check pod resource usage
kubectl top pods -n ecommerce

# Check for resource constraints
kubectl describe pods -n ecommerce
```

### Debug Mode
```bash
# Run with verbose output
./run-tests.sh ecommerce --verbose

# Check individual test logs
cat test-results/validation_20241201_120000.log

# Monitor resource usage during tests
kubectl top pods -n ecommerce --watch
```

## 📚 Integration

### CI/CD Pipeline Integration
```yaml
# Example GitHub Actions workflow
- name: Run E-commerce Tests
  run: |
    cd validation/
    ./run-tests.sh ${{ env.NAMESPACE }} --type=all --parallel
```

### Monitoring Integration
```bash
# Export health status to monitoring system
./health-check.sh ecommerce --json | jq '.overall_status'

# Export performance metrics
./performance-test.sh ecommerce --type=load | grep "RPS\|Response"
```

### Alerting Integration
```bash
# Check if tests pass for alerting
if ./run-tests.sh ecommerce --type=health > /dev/null 2>&1; then
    echo "Health checks passed"
else
    echo "Health checks failed" | mail -s "E-commerce Health Alert" admin@company.com
fi
```

## 🎯 Best Practices

### 1. Regular Testing
- Run validation tests after every deployment
- Run health checks every 15 minutes
- Run performance tests weekly
- Run full test suite before production releases

### 2. Test Environment
- Use dedicated test namespaces
- Isolate test environments from production
- Use realistic test data and load patterns
- Monitor resource usage during tests

### 3. Result Analysis
- Review test reports after each run
- Track performance trends over time
- Investigate failures immediately
- Document performance baselines

### 4. Automation
- Integrate tests into CI/CD pipelines
- Set up automated alerts for test failures
- Schedule regular performance tests
- Archive test results for historical analysis

## 📞 Support

For issues or questions regarding the testing suite:

- **Documentation**: Check this README and inline script comments
- **Logs**: Review test output files in `test-results/` directory
- **Debugging**: Use `--verbose` flag for detailed output
- **Issues**: Report bugs or feature requests through the project repository

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Platform Engineering Team
