# 🌪️ Chaos Engineering: Resilience Testing Automation

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** chaos engineering principles and practices
- **Implement** automated resilience testing in CI/CD
- **Configure** failure injection and recovery validation
- **Build** production chaos experiments safely
- **Monitor** system behavior under failure conditions

## 🎯 Real-World Context
Chaos engineering is critical for e-commerce resilience. Netflix pioneered chaos engineering to handle millions of users, while companies like Amazon and Shopify use it to ensure their platforms remain available during Black Friday traffic spikes and infrastructure failures.

---

## 🏗️ Chaos Engineering Fundamentals

### **Chaos Engineering Principles**

| Principle | Description | E-commerce Impact |
|-----------|-------------|-------------------|
| **Hypothesis** | Define expected system behavior | "Payment service should failover in <30s" |
| **Blast Radius** | Limit experiment scope | "Test on 1% of staging traffic" |
| **Rollback** | Quick experiment termination | "Stop if error rate >5%" |
| **Monitoring** | Observe system behavior | "Track checkout success rate" |

### **Basic Chaos Workflow**

```yaml
name: Chaos Engineering Pipeline

on:
  schedule:
    - cron: '0 10 * * 2'  # Tuesday 10 AM
  workflow_dispatch:
    inputs:
      experiment-type:
        description: 'Chaos experiment type'
        required: true
        type: choice
        options:
          - network-latency
          - pod-failure
          - cpu-stress
          - memory-stress
          - disk-failure
      blast-radius:
        description: 'Experiment scope (percentage)'
        required: false
        default: '10'

jobs:
  chaos-experiment:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Chaos Tools
        run: |
          # Install Chaos Mesh CLI
          curl -sSL https://mirrors.chaos-mesh.org/latest/install.sh | bash
          
          # Install kubectl
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          chmod +x kubectl && sudo mv kubectl /usr/local/bin/
          
      - name: Pre-experiment Baseline
        run: |
          # Collect baseline metrics
          ./scripts/collect-baseline-metrics.sh
          
          # Verify system health
          ./scripts/health-check.sh staging
          
      - name: Run Chaos Experiment
        env:
          EXPERIMENT_TYPE: ${{ github.event.inputs.experiment-type || 'network-latency' }}
          BLAST_RADIUS: ${{ github.event.inputs.blast-radius || '10' }}
        run: |
          # Apply chaos experiment
          envsubst < chaos-experiments/$EXPERIMENT_TYPE.yml | kubectl apply -f -
          
          # Monitor experiment
          ./scripts/monitor-chaos-experiment.sh $EXPERIMENT_TYPE
          
      - name: Collect Results
        if: always()
        run: |
          # Collect experiment results
          ./scripts/collect-experiment-results.sh
          
          # Cleanup chaos resources
          kubectl delete chaosexperiment --all -n chaos-testing
          
      - name: Generate Report
        if: always()
        run: |
          # Generate chaos experiment report
          ./scripts/generate-chaos-report.sh
```

---

## 🔧 Automated Failure Injection

### **Network Chaos Experiments**

```yaml
# chaos-experiments/network-latency.yml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: ecommerce-network-latency
  namespace: chaos-testing
spec:
  action: delay
  mode: one
  selector:
    namespaces:
      - ecommerce-staging
    labelSelectors:
      app: order-service
  delay:
    latency: "100ms"
    correlation: "100"
    jitter: "0ms"
  duration: "5m"
  scheduler:
    cron: "@every 10m"
```

### **Pod Failure Experiments**

```yaml
# chaos-experiments/pod-failure.yml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: ecommerce-pod-failure
  namespace: chaos-testing
spec:
  action: pod-failure
  mode: fixed-percent
  value: "25"
  selector:
    namespaces:
      - ecommerce-staging
    labelSelectors:
      app: payment-service
  duration: "2m"
  scheduler:
    cron: "@every 15m"
```

### **Comprehensive Chaos Pipeline**

```yaml
name: E-commerce Chaos Engineering

on:
  schedule:
    - cron: '0 14 * * 1-5'  # Weekdays 2 PM
  workflow_dispatch:
    inputs:
      target-service:
        description: 'Target service for chaos'
        required: true
        type: choice
        options:
          - user-service
          - product-service
          - order-service
          - payment-service
          - inventory-service
      experiment-duration:
        description: 'Experiment duration (minutes)'
        required: false
        default: '5'

jobs:
  pre-chaos-validation:
    runs-on: ubuntu-latest
    outputs:
      system-healthy: ${{ steps.health.outputs.healthy }}
      baseline-metrics: ${{ steps.baseline.outputs.metrics }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: System Health Check
        id: health
        run: |
          # Check all critical services
          SERVICES=("user-service" "product-service" "order-service" "payment-service")
          HEALTHY=true
          
          for service in "${SERVICES[@]}"; do
            if ! curl -f "https://staging.ecommerce.com/api/$service/health"; then
              echo "❌ $service is unhealthy"
              HEALTHY=false
            else
              echo "✅ $service is healthy"
            fi
          done
          
          echo "healthy=$HEALTHY" >> $GITHUB_OUTPUT
          
      - name: Collect Baseline Metrics
        id: baseline
        run: |
          # Collect performance baselines
          python3 << 'EOF'
          import requests
          import json
          import time
          
          metrics = {
            'response_times': {},
            'error_rates': {},
            'throughput': {}
          }
          
          services = ['user', 'product', 'order', 'payment']
          
          for service in services:
            # Measure response time
            start_time = time.time()
            response = requests.get(f'https://staging.ecommerce.com/api/{service}/health')
            response_time = (time.time() - start_time) * 1000
            
            metrics['response_times'][service] = response_time
            metrics['error_rates'][service] = 0 if response.status_code == 200 else 1
          
          # Save baseline
          with open('baseline-metrics.json', 'w') as f:
            json.dump(metrics, f)
          
          print(f"Baseline metrics collected: {json.dumps(metrics, indent=2)}")
          EOF
          
          echo "metrics=$(cat baseline-metrics.json)" >> $GITHUB_OUTPUT

  chaos-experiments:
    needs: pre-chaos-validation
    if: needs.pre-chaos-validation.outputs.system-healthy == 'true'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        experiment:
          - name: "network-latency"
            type: "NetworkChaos"
            duration: "3m"
          - name: "pod-failure"
            type: "PodChaos" 
            duration: "2m"
          - name: "cpu-stress"
            type: "StressChaos"
            duration: "4m"
      max-parallel: 1
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Chaos Environment
        run: |
          # Configure kubectl
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config
          
          # Install Chaos Mesh
          kubectl apply -f https://raw.githubusercontent.com/chaos-mesh/chaos-mesh/master/manifests/crd.yaml
          
      - name: Run ${{ matrix.experiment.name }} Experiment
        env:
          TARGET_SERVICE: ${{ github.event.inputs.target-service || 'order-service' }}
          EXPERIMENT_DURATION: ${{ github.event.inputs.experiment-duration || matrix.experiment.duration }}
        run: |
          echo "🌪️ Starting ${{ matrix.experiment.name }} chaos experiment"
          
          # Create experiment configuration
          cat > chaos-experiment.yml << EOF
          apiVersion: chaos-mesh.org/v1alpha1
          kind: ${{ matrix.experiment.type }}
          metadata:
            name: ecommerce-${{ matrix.experiment.name }}-$(date +%s)
            namespace: chaos-testing
          spec:
            selector:
              namespaces:
                - ecommerce-staging
              labelSelectors:
                app: $TARGET_SERVICE
            duration: "${EXPERIMENT_DURATION}m"
          EOF
          
          # Add experiment-specific configuration
          case "${{ matrix.experiment.name }}" in
            "network-latency")
              cat >> chaos-experiment.yml << EOF
            action: delay
            mode: one
            delay:
              latency: "200ms"
              correlation: "100"
          EOF
              ;;
            "pod-failure")
              cat >> chaos-experiment.yml << EOF
            action: pod-failure
            mode: fixed-percent
            value: "50"
          EOF
              ;;
            "cpu-stress")
              cat >> chaos-experiment.yml << EOF
            action: stress-cpu
            mode: one
            stressors:
              cpu:
                workers: 2
                load: 80
          EOF
              ;;
          esac
          
          # Apply chaos experiment
          kubectl apply -f chaos-experiment.yml
          
      - name: Monitor Experiment Impact
        env:
          EXPERIMENT_NAME: ${{ matrix.experiment.name }}
          TARGET_SERVICE: ${{ github.event.inputs.target-service || 'order-service' }}
        run: |
          # Monitor system during chaos
          python3 << 'EOF'
          import requests
          import time
          import json
          import os
          
          experiment_name = os.environ['EXPERIMENT_NAME']
          target_service = os.environ['TARGET_SERVICE']
          
          print(f"📊 Monitoring {experiment_name} impact on {target_service}")
          
          metrics = {
            'timestamps': [],
            'response_times': [],
            'error_rates': [],
            'success_rates': []
          }
          
          # Monitor for experiment duration + buffer
          duration_minutes = int("${{ github.event.inputs.experiment-duration || '3' }}")
          total_checks = (duration_minutes + 2) * 6  # Check every 10 seconds
          
          for i in range(total_checks):
            timestamp = time.time()
            
            try:
              start_time = time.time()
              response = requests.get(
                f'https://staging.ecommerce.com/api/{target_service.replace("-service", "")}/health',
                timeout=5
              )
              response_time = (time.time() - start_time) * 1000
              
              metrics['timestamps'].append(timestamp)
              metrics['response_times'].append(response_time)
              metrics['error_rates'].append(0 if response.status_code == 200 else 1)
              metrics['success_rates'].append(1 if response.status_code == 200 else 0)
              
              print(f"Check {i+1}/{total_checks}: {response_time:.2f}ms, Status: {response.status_code}")
              
            except Exception as e:
              metrics['timestamps'].append(timestamp)
              metrics['response_times'].append(5000)  # Timeout
              metrics['error_rates'].append(1)
              metrics['success_rates'].append(0)
              
              print(f"Check {i+1}/{total_checks}: ERROR - {str(e)}")
            
            time.sleep(10)
          
          # Save monitoring results
          with open(f'{experiment_name}-monitoring.json', 'w') as f:
            json.dump(metrics, f)
          
          # Calculate impact metrics
          avg_response_time = sum(metrics['response_times']) / len(metrics['response_times'])
          error_rate = sum(metrics['error_rates']) / len(metrics['error_rates']) * 100
          success_rate = sum(metrics['success_rates']) / len(metrics['success_rates']) * 100
          
          print(f"\n📈 Experiment Results:")
          print(f"Average Response Time: {avg_response_time:.2f}ms")
          print(f"Error Rate: {error_rate:.2f}%")
          print(f"Success Rate: {success_rate:.2f}%")
          
          # Determine experiment outcome
          if success_rate >= 95 and avg_response_time < 2000:
            print("✅ System showed good resilience")
          elif success_rate >= 90:
            print("⚠️ System showed moderate resilience")
          else:
            print("❌ System showed poor resilience")
          EOF
          
      - name: Cleanup Experiment
        if: always()
        run: |
          # Remove chaos experiment
          kubectl delete chaosexperiment --all -n chaos-testing --ignore-not-found=true
          
          # Wait for system recovery
          sleep 30
          
      - name: Upload Experiment Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: chaos-results-${{ matrix.experiment.name }}
          path: "*-monitoring.json"

  post-chaos-analysis:
    needs: chaos-experiments
    if: always()
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download All Results
        uses: actions/download-artifact@v4
        with:
          pattern: chaos-results-*
          merge-multiple: true
          
      - name: Generate Chaos Report
        run: |
          python3 << 'EOF'
          import json
          import glob
          import os
          from datetime import datetime
          
          print("🔍 Analyzing chaos experiment results...")
          
          # Load baseline metrics
          baseline = json.loads('${{ needs.pre-chaos-validation.outputs.baseline-metrics }}')
          
          # Process experiment results
          experiment_files = glob.glob("*-monitoring.json")
          
          report = {
            'timestamp': datetime.now().isoformat(),
            'baseline': baseline,
            'experiments': {},
            'summary': {
              'total_experiments': len(experiment_files),
              'resilient_experiments': 0,
              'concerning_experiments': 0
            }
          }
          
          for file in experiment_files:
            experiment_name = file.replace('-monitoring.json', '')
            
            with open(file) as f:
              data = json.load(f)
            
            # Calculate metrics
            avg_response_time = sum(data['response_times']) / len(data['response_times'])
            error_rate = sum(data['error_rates']) / len(data['error_rates']) * 100
            success_rate = sum(data['success_rates']) / len(data['success_rates']) * 100
            
            experiment_result = {
              'avg_response_time': avg_response_time,
              'error_rate': error_rate,
              'success_rate': success_rate,
              'resilience_score': 'good' if success_rate >= 95 else 'moderate' if success_rate >= 90 else 'poor'
            }
            
            report['experiments'][experiment_name] = experiment_result
            
            if experiment_result['resilience_score'] == 'good':
              report['summary']['resilient_experiments'] += 1
            else:
              report['summary']['concerning_experiments'] += 1
          
          # Generate markdown report
          with open('chaos-engineering-report.md', 'w') as f:
            f.write("# Chaos Engineering Report\n\n")
            f.write(f"**Generated**: {report['timestamp']}\n")
            f.write(f"**Target Environment**: Staging\n\n")
            
            f.write("## Summary\n")
            f.write(f"- **Total Experiments**: {report['summary']['total_experiments']}\n")
            f.write(f"- **Resilient Systems**: {report['summary']['resilient_experiments']}\n")
            f.write(f"- **Concerning Results**: {report['summary']['concerning_experiments']}\n\n")
            
            f.write("## Experiment Results\n\n")
            for exp_name, result in report['experiments'].items():
              status_emoji = "✅" if result['resilience_score'] == 'good' else "⚠️" if result['resilience_score'] == 'moderate' else "❌"
              f.write(f"### {status_emoji} {exp_name.title()}\n")
              f.write(f"- **Success Rate**: {result['success_rate']:.2f}%\n")
              f.write(f"- **Average Response Time**: {result['avg_response_time']:.2f}ms\n")
              f.write(f"- **Error Rate**: {result['error_rate']:.2f}%\n")
              f.write(f"- **Resilience Score**: {result['resilience_score']}\n\n")
            
            f.write("## Recommendations\n")
            if report['summary']['concerning_experiments'] > 0:
              f.write("- Review and improve system resilience for concerning experiments\n")
              f.write("- Implement circuit breakers and retry mechanisms\n")
              f.write("- Consider increasing resource limits or replicas\n")
            else:
              f.write("- System shows good resilience across all experiments\n")
              f.write("- Continue regular chaos testing\n")
              f.write("- Consider expanding experiment scope\n")
          
          print("📊 Chaos engineering report generated")
          EOF
          
      - name: Upload Chaos Report
        uses: actions/upload-artifact@v4
        with:
          name: chaos-engineering-report
          path: chaos-engineering-report.md
          
      - name: Post Results to Slack
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: "🌪️ Chaos Engineering Results",
              attachments: [{
                color: "${{ needs.chaos-experiments.result == 'success' && 'good' || 'danger' }}",
                fields: [{
                  title: "Environment",
                  value: "Staging",
                  short: true
                }, {
                  title: "Experiments Run",
                  value: "${{ strategy.job-total }}",
                  short: true
                }]
              }]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_CHAOS }}
```

---

## 🎯 Hands-On Lab: Chaos Engineering Implementation

### **Lab Objective**
Implement automated chaos engineering for an e-commerce platform to validate system resilience and recovery capabilities.

### **Lab Steps**

1. **Setup Chaos Engineering Environment**
```bash
# Install Chaos Mesh in staging
kubectl create namespace chaos-testing
kubectl apply -f https://raw.githubusercontent.com/chaos-mesh/chaos-mesh/master/manifests/crd.yaml

# Create chaos experiments
mkdir -p chaos-experiments
cp examples/network-latency.yml chaos-experiments/
cp examples/pod-failure.yml chaos-experiments/
```

2. **Implement Monitoring Scripts**
```bash
# Create monitoring utilities
mkdir -p scripts
cat > scripts/collect-baseline-metrics.sh << 'EOF'
#!/bin/bash
# Collect system baseline metrics
curl -s "https://staging.ecommerce.com/metrics" > baseline-metrics.json
EOF

chmod +x scripts/*.sh
```

3. **Deploy Chaos Pipeline**
```bash
# Create chaos workflow
cp examples/chaos-engineering.yml .github/workflows/

# Test chaos experiment
git add .
git commit -m "Add chaos engineering pipeline"
git push
```

4. **Run Chaos Experiments**
```bash
# Trigger chaos experiment
gh workflow run chaos-engineering.yml \
  --field experiment-type=network-latency \
  --field blast-radius=25

# Monitor results
gh run watch
```

### **Expected Results**
- Automated resilience testing implementation
- System behavior monitoring during failures
- Comprehensive chaos experiment reporting
- Validated system recovery capabilities

---

## 📚 Chaos Engineering Best Practices

### **Safety Guidelines**
- **Start small** with limited blast radius
- **Monitor continuously** during experiments
- **Have rollback plans** ready
- **Run in non-production** first
- **Gradual complexity increase**

### **E-commerce Considerations**
- **Avoid peak hours** for experiments
- **Protect payment flows** from chaos
- **Monitor customer impact** metrics
- **Test disaster recovery** procedures
- **Validate SLA compliance** under stress

---

## 🎯 Module Assessment

### **Knowledge Check**
1. What are the core principles of chaos engineering?
2. How do you safely implement failure injection in production systems?
3. What metrics should be monitored during chaos experiments?
4. How do you determine if a system passes resilience testing?

### **Practical Exercise**
Implement a chaos engineering pipeline that includes:
- Automated failure injection experiments
- System behavior monitoring and analysis
- Safety controls and rollback mechanisms
- Comprehensive resilience reporting

### **Success Criteria**
- [ ] Safe chaos experiment implementation
- [ ] Comprehensive system monitoring
- [ ] Automated resilience validation
- [ ] Clear reporting and recommendations
- [ ] Integration with existing CI/CD pipeline

---

**Next Module**: [Best Practices & Troubleshooting](./22-Best-Practices.md) - Learn production-ready patterns
