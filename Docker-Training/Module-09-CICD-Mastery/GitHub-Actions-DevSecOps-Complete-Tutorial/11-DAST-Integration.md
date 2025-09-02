# 🔍 DAST Integration: Dynamic Application Security Testing

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** Dynamic Application Security Testing (DAST) principles
- **Implement** OWASP ZAP integration in GitHub Actions
- **Configure** automated runtime security scanning
- **Build** comprehensive DAST workflows for e-commerce applications
- **Master** vulnerability reporting and remediation workflows

## 🎯 Real-World Context
DAST testing identifies runtime vulnerabilities that static analysis cannot detect. Companies like PayPal and Shopify use DAST to find SQL injection, XSS, and authentication bypass vulnerabilities in running applications.

---

## 🔍 DAST Fundamentals

### **What is DAST?**
Dynamic Application Security Testing analyzes running applications to identify:
- **Runtime Vulnerabilities**: SQL injection, XSS, CSRF
- **Authentication Issues**: Broken access controls
- **Configuration Problems**: Insecure headers, exposed endpoints
- **Business Logic Flaws**: Workflow bypasses

### **DAST vs SAST Comparison**

| Aspect | SAST | DAST |
|--------|------|------|
| **Analysis Type** | Source code | Running application |
| **Detection** | Code vulnerabilities | Runtime vulnerabilities |
| **False Positives** | Higher | Lower |
| **Coverage** | 100% code | Accessible endpoints |
| **Performance** | Fast | Slower |

---

## 🛠️ OWASP ZAP Integration

### **Basic ZAP Workflow**

```yaml
name: DAST Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  dast-scan:
    runs-on: ubuntu-latest
    
    services:
      app:
        image: node:16
        ports:
          - 3000:3000
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Application
        run: |
          npm install
          npm run build
          npm start &
          sleep 30
          
      - name: OWASP ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.10.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
```

### **Advanced ZAP Configuration**

```yaml
name: Comprehensive DAST Scan

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM
  workflow_dispatch:

jobs:
  dast-full-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Start E-commerce Application
        run: |
          docker-compose -f docker-compose.test.yml up -d
          ./scripts/wait-for-app.sh
          
      - name: OWASP ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.8.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: |
            -a
            -x zap-report.xml
            -r zap-report.html
            -J zap-report.json
            
      - name: Upload ZAP Reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: zap-reports
          path: |
            zap-report.xml
            zap-report.html
            zap-report.json
```

---

## 🎯 E-commerce DAST Implementation

### **Complete E-commerce DAST Workflow**
```yaml
name: E-commerce DAST Security Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  APP_URL: http://localhost:3000
  ZAP_VERSION: stable

jobs:
  prepare-environment:
    runs-on: ubuntu-latest
    outputs:
      app-ready: ${{ steps.health-check.outputs.ready }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install Dependencies
        run: npm ci
        
      - name: Build Application
        run: npm run build
        
      - name: Start Application
        run: |
          npm start &
          echo "APP_PID=$!" >> $GITHUB_ENV
          
      - name: Health Check
        id: health-check
        run: |
          for i in {1..30}; do
            if curl -f $APP_URL/health; then
              echo "ready=true" >> $GITHUB_OUTPUT
              exit 0
            fi
            sleep 2
          done
          echo "ready=false" >> $GITHUB_OUTPUT
          exit 1

  dast-baseline:
    needs: prepare-environment
    if: needs.prepare-environment.outputs.app-ready == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.10.0
        with:
          target: ${{ env.APP_URL }}
          rules_file_name: '.zap/baseline-rules.tsv'
          cmd_options: |
            -a
            -x baseline-report.xml
            -r baseline-report.html
            
      - name: Process Results
        run: |
          python3 scripts/process-zap-results.py baseline-report.xml
```

**Line-by-Line Analysis:**

**`name: E-commerce DAST Security Pipeline`** - Dynamic Application Security Testing workflow
**`env: APP_URL: http://localhost:3000`** - Target application URL for security scanning
**`ZAP_VERSION: stable`** - OWASP ZAP version for consistent scanning results
**`outputs: app-ready: ${{ steps.health-check.outputs.ready }}`** - Job output for application readiness
**`npm start &`** - Starts application in background for DAST scanning
**`echo "APP_PID=$!" >> $GITHUB_ENV`** - Captures process ID for cleanup
**`for i in {1..30}; do`** - Health check loop with 30 attempts (60 seconds)
**`curl -f $APP_URL/health`** - HTTP health check with fail-fast option
**`echo "ready=true" >> $GITHUB_OUTPUT`** - Sets job output for dependent jobs
**`needs: prepare-environment`** - Waits for application to be ready
**`if: needs.prepare-environment.outputs.app-ready == 'true'`** - Conditional execution based on app readiness
**`uses: zaproxy/action-baseline@v0.10.0`** - Official OWASP ZAP baseline scan action
**`rules_file_name: '.zap/baseline-rules.tsv'`** - Custom ZAP scanning rules configuration
**`-a`** - Include the alpha passive scan rules in baseline scan
**`-x baseline-report.xml`** - Generate XML report for processing
**`-r baseline-report.html`** - Generate HTML report for human review
**`python3 scripts/process-zap-results.py`** - Custom script to process and analyze results
          
      - name: Upload Baseline Reports
        uses: actions/upload-artifact@v4
        with:
          name: dast-baseline-reports
          path: |
            baseline-report.*
            processed-results.json

  dast-api-scan:
    needs: prepare-environment
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: ZAP API Scan
        uses: zaproxy/action-api-scan@v0.5.0
        with:
          target: ${{ env.APP_URL }}
          format: openapi
          api_definition: './docs/api-spec.yaml'
          cmd_options: |
            -a
            -x api-report.xml
            -r api-report.html
            
      - name: Upload API Reports
        uses: actions/upload-artifact@v4
        with:
          name: dast-api-reports
          path: |
            api-report.*

  dast-authenticated:
    needs: prepare-environment
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Authentication
        run: |
          # Create test user and get auth token
          curl -X POST $APP_URL/api/auth/register \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","password":"TestPass123!"}'
          
          TOKEN=$(curl -X POST $APP_URL/api/auth/login \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","password":"TestPass123!"}' \
            | jq -r '.token')
          
          echo "AUTH_TOKEN=$TOKEN" >> $GITHUB_ENV
          
      - name: ZAP Authenticated Scan
        run: |
          docker run --rm \
            -v $(pwd):/zap/wrk/:rw \
            -t owasp/zap2docker-${{ env.ZAP_VERSION }} \
            zap-full-scan.py \
            -t ${{ env.APP_URL }} \
            -x auth-report.xml \
            -r auth-report.html \
            -z "-config replacer.full_list(0).description=auth1 \
                 -config replacer.full_list(0).enabled=true \
                 -config replacer.full_list(0).matchtype=REQ_HEADER \
                 -config replacer.full_list(0).matchstr=Authorization \
                 -config replacer.full_list(0).regex=false \
                 -config replacer.full_list(0).replacement=Bearer\ ${{ env.AUTH_TOKEN }}"
                 
      - name: Upload Auth Reports
        uses: actions/upload-artifact@v4
        with:
          name: dast-auth-reports
          path: |
            auth-report.*
```

---

## 🔧 Advanced DAST Configurations

### **Custom ZAP Rules Configuration**

Create `.zap/baseline-rules.tsv`:
```tsv
10021	WARN	(X-Content-Type-Options Header Missing)
10020	WARN	(X-Frame-Options Header Not Set)
10016	WARN	(Web Browser XSS Protection Not Enabled)
10017	WARN	(Cross-Domain JavaScript Source File Inclusion)
10019	WARN	(Content-Type Header Missing)
10015	WARN	(Incomplete or No Cache-control and Pragma HTTP Header Set)
10023	WARN	(Information Disclosure - Debug Error Messages)
10024	WARN	(Information Disclosure - Sensitive Information in URL)
10025	WARN	(Information Disclosure - Sensitive Information in HTTP Referrer Header)
10026	WARN	(HTTP Parameter Override)
10027	WARN	(Information Disclosure - Suspicious Comments)
10028	WARN	(Open Redirect)
10029	WARN	(Cookie No HttpOnly Flag)
10030	WARN	(Cookie No Secure Flag)
```

### **ZAP Context Configuration**

```yaml
- name: Configure ZAP Context
  run: |
    cat > zap-context.xml << 'EOF'
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <configuration>
      <context>
        <name>E-commerce App</name>
        <desc>E-commerce application security context</desc>
        <inscope>true</inscope>
        <incregexes>http://localhost:3000/.*</incregexes>
        <excregexes>
          <regex>http://localhost:3000/static/.*</regex>
          <regex>http://localhost:3000/assets/.*</regex>
          <regex>http://localhost:3000/logout</regex>
        </excregexes>
        <tech>
          <include>Db.MySQL</include>
          <include>Language.JavaScript</include>
          <include>OS.Linux</include>
          <include>SCM.Git</include>
          <include>WS.OpenAPI</include>
        </tech>
        <urlparser>
          <class>org.zaproxy.zap.model.StandardParameterParser</class>
          <config></config>
        </urlparser>
        <postparser>
          <class>org.zaproxy.zap.model.StandardParameterParser</class>
          <config></config>
        </postparser>
        <authentication>
          <type>2</type>
          <strategy>EACH_RESP</strategy>
          <pollurl></pollurl>
          <polldata></polldata>
          <pollheaders></pollheaders>
          <pollfreq>60</pollfreq>
          <pollunits>REQUESTS</pollunits>
          <method>
            <methodname>formBasedAuthentication</methodname>
            <loginurl>http://localhost:3000/api/auth/login</loginurl>
            <loginbody>email={%username%}&amp;password={%password%}</loginbody>
            <loginpageurl>http://localhost:3000/login</loginpageurl>
          </method>
        </authentication>
        <users>
          <user>1;true;test@example.com;TestPass123!</user>
        </users>
        <forceduser>1</forceduser>
        <session>
          <type>1</type>
          <method>
            <methodname>cookieBasedSessionManagement</methodname>
          </method>
        </session>
      </context>
    </configuration>
    EOF
```

---

## 📊 DAST Results Processing

### **Results Analysis Script**

Create `scripts/process-zap-results.py`:
```python
#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import json
import sys
from datetime import datetime

def process_zap_xml(xml_file):
    """Process ZAP XML report and extract key metrics"""
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    results = {
        'scan_info': {
            'timestamp': datetime.now().isoformat(),
            'target': root.get('host', 'Unknown'),
            'version': root.get('version', 'Unknown')
        },
        'summary': {
            'high': 0,
            'medium': 0,
            'low': 0,
            'informational': 0,
            'total': 0
        },
        'vulnerabilities': []
    }
    
    # Process alerts
    for site in root.findall('.//site'):
        for alert in site.findall('.//alertitem'):
            risk = alert.find('riskdesc').text if alert.find('riskdesc') is not None else 'Unknown'
            confidence = alert.find('confidence').text if alert.find('confidence') is not None else 'Unknown'
            
            vuln = {
                'name': alert.find('name').text if alert.find('name') is not None else 'Unknown',
                'risk': risk,
                'confidence': confidence,
                'description': alert.find('desc').text if alert.find('desc') is not None else '',
                'solution': alert.find('solution').text if alert.find('solution') is not None else '',
                'reference': alert.find('reference').text if alert.find('reference') is not None else '',
                'instances': []
            }
            
            # Count by risk level
            risk_level = risk.split(' ')[0].lower()
            if risk_level in results['summary']:
                results['summary'][risk_level] += 1
            results['summary']['total'] += 1
            
            # Process instances
            for instance in alert.findall('.//instance'):
                vuln['instances'].append({
                    'uri': instance.find('uri').text if instance.find('uri') is not None else '',
                    'method': instance.find('method').text if instance.find('method') is not None else '',
                    'param': instance.find('param').text if instance.find('param') is not None else '',
                    'evidence': instance.find('evidence').text if instance.find('evidence') is not None else ''
                })
            
            results['vulnerabilities'].append(vuln)
    
    return results

def generate_summary_report(results):
    """Generate human-readable summary"""
    summary = f"""
# DAST Scan Summary Report

## Scan Information
- **Target**: {results['scan_info']['target']}
- **Timestamp**: {results['scan_info']['timestamp']}
- **ZAP Version**: {results['scan_info']['version']}

## Vulnerability Summary
- **High Risk**: {results['summary']['high']}
- **Medium Risk**: {results['summary']['medium']}
- **Low Risk**: {results['summary']['low']}
- **Informational**: {results['summary']['informational']}
- **Total Issues**: {results['summary']['total']}

## Risk Assessment
"""
    
    if results['summary']['high'] > 0:
        summary += "🚨 **CRITICAL**: High-risk vulnerabilities found - immediate action required\n"
    elif results['summary']['medium'] > 0:
        summary += "⚠️ **WARNING**: Medium-risk vulnerabilities found - review and fix\n"
    elif results['summary']['low'] > 0:
        summary += "ℹ️ **INFO**: Low-risk issues found - consider addressing\n"
    else:
        summary += "✅ **PASS**: No significant vulnerabilities detected\n"
    
    return summary

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 process-zap-results.py <zap-report.xml>")
        sys.exit(1)
    
    xml_file = sys.argv[1]
    results = process_zap_xml(xml_file)
    
    # Save processed results
    with open('processed-results.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    # Generate summary
    summary = generate_summary_report(results)
    with open('dast-summary.md', 'w') as f:
        f.write(summary)
    
    print(f"Processed {results['summary']['total']} findings")
    print(f"High: {results['summary']['high']}, Medium: {results['summary']['medium']}, Low: {results['summary']['low']}")
    
    # Exit with error code if high-risk vulnerabilities found
    if results['summary']['high'] > 0:
        sys.exit(1)
```

---

## 🔄 Integration with Security Pipeline

### **Complete DevSecOps Integration**

```yaml
name: Complete Security Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  sast-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run SAST
        uses: github/codeql-action/analyze@v3
        
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Dependency Check
        run: npm audit --audit-level=moderate
        
  container-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Image
        run: docker build -t app:test .
      - name: Scan Container
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:test'
          
  dast-scan:
    needs: [sast-scan, dependency-scan, container-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Test Environment
        run: |
          docker-compose -f docker-compose.test.yml up -d
          ./scripts/wait-for-app.sh
          
      - name: Run DAST Scan
        uses: zaproxy/action-baseline@v0.10.0
        with:
          target: 'http://localhost:3000'
          
      - name: Security Gate
        run: |
          python3 scripts/security-gate.py \
            --sast-results sast-results.json \
            --dast-results baseline-report.xml \
            --container-results trivy-results.json \
            --dependency-results npm-audit.json
```

---

## 🎯 Hands-On Lab: E-commerce DAST Implementation

### **Lab Objective**
Implement comprehensive DAST scanning for an e-commerce application with authentication and API testing.

### **Lab Steps**

1. **Setup Test Application**
```bash
# Clone e-commerce app
git clone https://github.com/your-org/ecommerce-app
cd ecommerce-app

# Create DAST configuration
mkdir -p .zap scripts
```

2. **Configure ZAP Rules**
```bash
# Create baseline rules
cat > .zap/baseline-rules.tsv << 'EOF'
10021	WARN	(X-Content-Type-Options Header Missing)
10020	WARN	(X-Frame-Options Header Not Set)
10016	WARN	(Web Browser XSS Protection Not Enabled)
EOF
```

3. **Implement DAST Workflow**
```bash
# Create workflow file
cp examples/dast-workflow.yml .github/workflows/
```

4. **Test DAST Pipeline**
```bash
# Trigger workflow
git add .
git commit -m "Add DAST scanning"
git push origin feature/dast-implementation
```

### **Expected Results**
- DAST scan completes successfully
- Vulnerability reports generated
- Security gates enforced
- Results integrated with PR checks

---

## 📚 Additional Resources

### **DAST Tools Comparison**

| Tool | Type | Strengths | Use Case |
|------|------|-----------|----------|
| **OWASP ZAP** | Open Source | Free, extensible | CI/CD integration |
| **Burp Suite** | Commercial | Advanced features | Manual testing |
| **Netsparker** | Commercial | Low false positives | Enterprise scanning |
| **Acunetix** | Commercial | Fast scanning | Web applications |

### **Best Practices**
- **Regular Scanning**: Schedule weekly full scans
- **Baseline Scans**: Run on every PR
- **Authentication**: Test authenticated and unauthenticated paths
- **API Testing**: Include API-specific DAST tools
- **False Positive Management**: Maintain suppression rules

### **Common Issues**
- **Application Stability**: Ensure app is stable before scanning
- **Authentication Tokens**: Handle token expiration
- **Rate Limiting**: Configure scan speed appropriately
- **Network Timeouts**: Adjust timeout settings for slow applications

---

## 🎯 Module Assessment

### **Knowledge Check**
1. What types of vulnerabilities does DAST detect that SAST cannot?
2. How do you configure authenticated scanning in ZAP?
3. What are the key differences between baseline and full DAST scans?
4. How do you integrate DAST results with security gates?

### **Practical Exercise**
Implement a complete DAST pipeline for an e-commerce application that includes:
- Baseline scanning for PRs
- Full authenticated scanning for releases
- API-specific security testing
- Vulnerability reporting and tracking

### **Success Criteria**
- [ ] DAST workflow executes successfully
- [ ] Vulnerabilities are detected and reported
- [ ] Security gates prevent deployment of vulnerable code
- [ ] Results are properly processed and stored

---

**Next Module**: [Supply Chain Security](./12-Supply-Chain-Security.md) - Learn SLSA framework and artifact signing
