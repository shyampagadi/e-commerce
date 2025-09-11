# Interactive Labs - Module 03

## Lab 1: RAID Performance Simulator
**Duration**: 60 minutes | **Hands-on Experience**

### Setup
```bash
# Install RAID simulator
git clone https://github.com/system-design-tutorial/raid-simulator.git
cd raid-simulator
docker-compose up -d
```

### Interactive Components
1. **RAID Level Comparison**: Test RAID 0, 1, 5, 6, 10 with different workloads
2. **Performance Analysis**: Measure IOPS, throughput, and latency
3. **Failure Simulation**: Inject disk failures and observe rebuild behavior
4. **Cost vs Performance**: Compare storage efficiency and protection levels

### Expected Outcomes
- Understand RAID performance characteristics through real testing
- Calculate parity overhead and rebuild impact
- Make informed RAID selection decisions

### Simulator Interface
```javascript
// RAID Performance Simulator
class RAIDSimulator {
    constructor(raidLevel, diskCount, diskSize) {
        this.raidLevel = raidLevel;
        this.diskCount = diskCount;
        this.diskSize = diskSize;
        this.calculateCapacity();
    }
    
    simulateWorkload(ioPattern, blockSize, queueDepth) {
        const results = {
            iops: this.calculateIOPS(ioPattern, blockSize),
            throughput: this.calculateThroughput(blockSize, queueDepth),
            latency: this.calculateLatency(ioPattern),
            efficiency: this.calculateEfficiency()
        };
        
        this.visualizeResults(results);
        return results;
    }
    
    simulateFailure(failedDisks) {
        const rebuildTime = this.calculateRebuildTime(failedDisks);
        const dataLossRisk = this.calculateDataLossRisk(failedDisks);
        
        return {
            canRecover: this.canRecoverFromFailure(failedDisks),
            rebuildTime: rebuildTime,
            performanceImpact: this.calculateRebuildImpact(),
            dataLossRisk: dataLossRisk
        };
    }
}
```

## Lab 2: Storage Durability Calculator
**Duration**: 45 minutes | **Mathematical Analysis**

### Interactive Tool
```html
<div class="durability-calculator">
    <div class="input-section">
        <label>Annual Failure Rate (AFR): <input type="number" id="afr" value="0.5">%</label>
        <label>Number of Drives: <input type="number" id="drives" value="1000"></label>
        <label>RAID Level: <select id="raid">
            <option value="0">RAID 0</option>
            <option value="1">RAID 1</option>
            <option value="5">RAID 5</option>
            <option value="6">RAID 6</option>
        </select></label>
        <label>Rebuild Time (hours): <input type="number" id="rebuild" value="24"></label>
    </div>
    
    <div class="results-section">
        <div id="mttdl">MTTDL: <span class="result"></span></div>
        <div id="durability">Durability: <span class="result"></span></div>
        <div id="annual-loss">Annual Data Loss Probability: <span class="result"></span></div>
    </div>
    
    <div class="visualization">
        <canvas id="durability-chart"></canvas>
    </div>
</div>
```

### Calculation Engine
```javascript
class DurabilityCalculator {
    calculateMTTDL(afr, drives, raidLevel, rebuildTime) {
        const mtbf = 8760 / (afr / 100); // Hours
        
        switch(raidLevel) {
            case 0: // RAID 0 - any drive failure causes data loss
                return mtbf / drives;
            
            case 1: // RAID 1 - need both drives to fail
                return Math.pow(mtbf, 2) / (2 * drives * rebuildTime);
            
            case 5: // RAID 5 - need 2 drives to fail during rebuild
                return Math.pow(mtbf, 2) / (drives * (drives - 1) * rebuildTime);
            
            case 6: // RAID 6 - need 3 drives to fail
                return Math.pow(mtbf, 3) / (drives * (drives - 1) * (drives - 2) * Math.pow(rebuildTime, 2));
        }
    }
    
    calculateDurability(mttdl) {
        const annualFailureProbability = 8760 / mttdl;
        const durability = 1 - annualFailureProbability;
        const nines = -Math.log10(annualFailureProbability);
        
        return {
            durability: durability,
            nines: nines,
            description: this.getDurabilityDescription(nines)
        };
    }
    
    getDurabilityDescription(nines) {
        if (nines >= 11) return "Eleven 9's (99.99999999999%)";
        if (nines >= 9) return "Nine 9's (99.9999999%)";
        if (nines >= 6) return "Six 9's (99.9999%)";
        if (nines >= 4) return "Four 9's (99.99%)";
        return "Less than Four 9's";
    }
}
```

## Lab 3: AWS Storage Cost Optimizer
**Duration**: 75 minutes | **Real-world Application**

### Interactive Cost Analysis Tool
```bash
# Setup AWS cost analysis environment
pip install boto3 pandas matplotlib
python storage-cost-analyzer.py
```

### Cost Optimization Scenarios
```python
class StorageCostOptimizer:
    def __init__(self):
        self.storage_classes = {
            's3_standard': {'cost_per_gb': 0.023, 'retrieval_cost': 0},
            's3_ia': {'cost_per_gb': 0.0125, 'retrieval_cost': 0.01},
            's3_glacier': {'cost_per_gb': 0.004, 'retrieval_cost': 0.03},
            's3_deep_archive': {'cost_per_gb': 0.00099, 'retrieval_cost': 0.05},
            'ebs_gp3': {'cost_per_gb': 0.08, 'iops_cost': 0.005},
            'ebs_io2': {'cost_per_gb': 0.125, 'iops_cost': 0.065}
        }
    
    def analyze_workload(self, data_size_gb, access_pattern, retention_years):
        recommendations = []
        
        for storage_class, pricing in self.storage_classes.items():
            total_cost = self.calculate_total_cost(
                data_size_gb, access_pattern, retention_years, pricing
            )
            
            recommendations.append({
                'storage_class': storage_class,
                'total_cost': total_cost,
                'monthly_cost': total_cost / (retention_years * 12),
                'suitability': self.assess_suitability(storage_class, access_pattern)
            })
        
        return sorted(recommendations, key=lambda x: x['total_cost'])
    
    def create_lifecycle_policy(self, access_pattern):
        if access_pattern['frequent_access_days'] <= 30:
            return {
                'transition_to_ia': 30,
                'transition_to_glacier': 90,
                'transition_to_deep_archive': 365,
                'estimated_savings': '60-80%'
            }
        else:
            return {
                'transition_to_ia': access_pattern['frequent_access_days'],
                'transition_to_glacier': access_pattern['frequent_access_days'] * 3,
                'transition_to_deep_archive': access_pattern['frequent_access_days'] * 12,
                'estimated_savings': '40-60%'
            }
```

### Real-world Cost Scenarios
```yaml
# E-commerce Platform Storage Analysis
scenario_1:
  name: "E-commerce Product Images"
  data_size: 10000  # GB
  access_pattern:
    frequent_access_days: 90
    monthly_requests: 1000000
    retrieval_frequency: "high"
  
  recommendations:
    - storage_class: "S3 Standard"
      monthly_cost: "$230"
      use_case: "Active product catalog"
    
    - storage_class: "S3 IA + Lifecycle"
      monthly_cost: "$145"
      savings: "37%"
      use_case: "Seasonal products"

# Data Analytics Platform
scenario_2:
  name: "Log Data Analytics"
  data_size: 50000  # GB
  access_pattern:
    frequent_access_days: 7
    monthly_requests: 10000
    retrieval_frequency: "low"
  
  recommendations:
    - storage_class: "S3 Glacier"
      monthly_cost: "$200"
      use_case: "Compliance and analytics"
    
    - storage_class: "S3 Intelligent Tiering"
      monthly_cost: "$180"
      savings: "10%"
      use_case: "Unknown access patterns"
```

## Lab 4: I/O Pattern Analyzer
**Duration**: 50 minutes | **Performance Optimization**

### Setup and Configuration
```bash
# Install I/O analysis tools
sudo apt-get install fio iotop iostat
git clone https://github.com/system-design-tutorial/io-analyzer.git
cd io-analyzer
```

### Interactive I/O Testing
```bash
# Test different I/O patterns
./run-io-tests.sh --workload database
./run-io-tests.sh --workload web-server
./run-io-tests.sh --workload analytics
```

### I/O Pattern Visualization
```javascript
class IOPatternAnalyzer {
    constructor(storageType) {
        this.storageType = storageType;
        this.testResults = [];
    }
    
    runIOTest(pattern, blockSize, queueDepth) {
        const testConfig = {
            pattern: pattern,        // sequential, random, mixed
            blockSize: blockSize,    // 4K, 64K, 1M
            queueDepth: queueDepth,  // 1, 8, 32
            duration: 60             // seconds
        };
        
        const results = this.executeTest(testConfig);
        this.testResults.push(results);
        
        return {
            iops: results.iops,
            throughput: results.throughput,
            latency: results.latency,
            recommendation: this.getOptimizationRecommendation(results)
        };
    }
    
    getOptimizationRecommendation(results) {
        if (results.pattern === 'random' && results.iops < 1000) {
            return "Consider SSD storage or increase queue depth";
        }
        
        if (results.pattern === 'sequential' && results.throughput < 100) {
            return "Increase block size or use multiple streams";
        }
        
        if (results.latency > 10) {
            return "Check storage alignment and reduce queue depth";
        }
        
        return "Performance is optimal for this workload";
    }
    
    visualizeResults() {
        // Create interactive charts showing:
        // - IOPS vs Block Size
        // - Throughput vs Queue Depth  
        // - Latency distribution
        // - Optimization recommendations
    }
}
```

### AWS EBS Optimization Lab
```bash
# Test EBS volume performance
aws ec2 create-volume --size 100 --volume-type gp3 --iops 3000 --throughput 125

# Attach and mount volume
aws ec2 attach-volume --volume-id vol-12345678 --instance-id i-12345678 --device /dev/sdf

# Run performance tests
fio --name=random-read --ioengine=libaio --rw=randread --bs=4k --numjobs=4 --iodepth=32 --runtime=60 --filename=/dev/nvme1n1

# Analyze results and optimize
./analyze-ebs-performance.py --volume-id vol-12345678 --workload-type database
```

## Lab 5: Data Lifecycle Management Simulator
**Duration**: 55 minutes | **Automated Tiering**

### Lifecycle Policy Designer
```html
<div class="lifecycle-designer">
    <div class="data-classification">
        <h3>Data Classification</h3>
        <div class="data-type">
            <label>Data Type: <select id="dataType">
                <option value="documents">Documents</option>
                <option value="images">Images</option>
                <option value="logs">Log Files</option>
                <option value="backups">Backups</option>
            </select></label>
        </div>
        
        <div class="access-pattern">
            <label>Access Frequency: <input type="range" id="accessFreq" min="1" max="365" value="30"></label>
            <span id="accessFreqValue">30 days</span>
        </div>
    </div>
    
    <div class="lifecycle-rules">
        <h3>Lifecycle Rules</h3>
        <div class="rule">
            <label>Transition to IA after: <input type="number" id="iaTransition" value="30"> days</label>
        </div>
        <div class="rule">
            <label>Transition to Glacier after: <input type="number" id="glacierTransition" value="90"> days</label>
        </div>
        <div class="rule">
            <label>Delete after: <input type="number" id="deleteAfter" value="2555"> days (7 years)</label>
        </div>
    </div>
    
    <div class="cost-projection">
        <canvas id="costChart"></canvas>
        <div id="savingsCalculation"></div>
    </div>
</div>
```

### Lifecycle Simulation Engine
```python
class LifecycleSimulator:
    def __init__(self):
        self.storage_costs = {
            'standard': 0.023,
            'ia': 0.0125,
            'glacier': 0.004,
            'deep_archive': 0.00099
        }
        
        self.retrieval_costs = {
            'standard': 0,
            'ia': 0.01,
            'glacier': 0.03,
            'deep_archive': 0.05
        }
    
    def simulate_lifecycle(self, data_size_gb, access_pattern, lifecycle_policy):
        timeline = []
        current_cost = 0
        
        for day in range(1, 2556):  # 7 years
            storage_class = self.get_storage_class(day, lifecycle_policy)
            daily_storage_cost = (data_size_gb * self.storage_costs[storage_class]) / 30
            
            # Simulate access requests
            if self.should_access_data(day, access_pattern):
                retrieval_cost = data_size_gb * self.retrieval_costs[storage_class]
                daily_cost = daily_storage_cost + retrieval_cost
            else:
                daily_cost = daily_storage_cost
            
            current_cost += daily_cost
            
            timeline.append({
                'day': day,
                'storage_class': storage_class,
                'daily_cost': daily_cost,
                'cumulative_cost': current_cost
            })
        
        return timeline
    
    def compare_strategies(self, data_size_gb, access_pattern):
        strategies = {
            'no_lifecycle': {'ia_days': None, 'glacier_days': None},
            'aggressive': {'ia_days': 30, 'glacier_days': 90},
            'moderate': {'ia_days': 90, 'glacier_days': 365},
            'conservative': {'ia_days': 365, 'glacier_days': 1095}
        }
        
        results = {}
        for name, policy in strategies.items():
            timeline = self.simulate_lifecycle(data_size_gb, access_pattern, policy)
            total_cost = timeline[-1]['cumulative_cost']
            results[name] = {
                'total_cost': total_cost,
                'timeline': timeline,
                'savings_vs_no_lifecycle': 0 if name == 'no_lifecycle' else 
                    (results.get('no_lifecycle', {}).get('total_cost', total_cost) - total_cost)
            }
        
        return results
```

## Assessment Integration

### Lab Performance Metrics
```python
class LabAssessment:
    def __init__(self):
        self.scoring_criteria = {
            'raid_simulator': {
                'performance_analysis': 25,
                'failure_scenarios': 20,
                'optimization_recommendations': 15
            },
            'durability_calculator': {
                'mathematical_accuracy': 30,
                'scenario_analysis': 20,
                'trade_off_understanding': 10
            },
            'cost_optimizer': {
                'workload_analysis': 25,
                'lifecycle_design': 20,
                'savings_calculation': 15
            },
            'io_analyzer': {
                'pattern_identification': 20,
                'optimization_implementation': 25,
                'performance_validation': 15
            }
        }
    
    def evaluate_lab_completion(self, student_id, lab_name, results):
        criteria = self.scoring_criteria[lab_name]
        score = 0
        
        for criterion, max_points in criteria.items():
            student_score = self.evaluate_criterion(results, criterion)
            score += min(student_score, max_points)
        
        return {
            'lab': lab_name,
            'score': score,
            'max_score': sum(criteria.values()),
            'percentage': (score / sum(criteria.values())) * 100,
            'feedback': self.generate_feedback(results, criteria)
        }
```

### Interactive Progress Tracking
- **Real-time Performance Metrics**: Track lab completion and understanding
- **Adaptive Difficulty**: Adjust complexity based on student performance
- **Peer Comparison**: Anonymous benchmarking against cohort performance
- **Skill Gap Analysis**: Identify areas needing additional practice
