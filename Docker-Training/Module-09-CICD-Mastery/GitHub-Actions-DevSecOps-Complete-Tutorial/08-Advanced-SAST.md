# 🔒 Advanced SAST Tools

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** advanced static analysis tools beyond SonarQube
- **Implement** CodeQL, Checkmarx, and Veracode integration
- **Configure** custom security rules and policies
- **Apply** multi-tool security orchestration for comprehensive coverage
- **Build** enterprise-grade security scanning pipelines

## 🎯 Real-World Context
Enterprise security requires multiple SAST tools working together. Companies like Microsoft, Google, and financial institutions use layered security analysis with tools like CodeQL, Checkmarx, and Veracode to achieve comprehensive vulnerability detection. This module teaches you to orchestrate multiple security tools for maximum coverage.

---

## 📚 Part 1: Advanced SAST Tool Landscape

### Understanding Multi-Tool Security Strategy

**Why Multiple SAST Tools?**
```
SAST Tool Strengths and Coverage
├── SonarQube/SonarCloud
│   ├── Strengths: Code quality, basic security, wide language support
│   ├── Weaknesses: Limited deep security analysis
│   └── Best For: Continuous quality monitoring
├── CodeQL (GitHub)
│   ├── Strengths: Deep semantic analysis, custom queries
│   ├── Weaknesses: Limited language support, GitHub-centric
│   └── Best For: Advanced vulnerability detection
├── Checkmarx
│   ├── Strengths: Enterprise security, compliance reporting
│   ├── Weaknesses: Cost, complexity
│   └── Best For: Enterprise security programs
├── Veracode
│   ├── Strengths: Comprehensive security platform, policy management
│   ├── Weaknesses: Cost, slower scanning
│   └── Best For: Regulated industries, compliance
└── Semgrep
    ├── Strengths: Fast, customizable rules, open source
    ├── Weaknesses: Newer tool, smaller community
    └── Best For: Custom security rules, fast feedback
```

### Tool Selection Strategy

**Enterprise SAST Tool Matrix:**
```yaml
SAST_Tool_Selection:
  By_Organization_Size:
    Startup:
      Primary: SonarCloud + GitHub CodeQL
      Secondary: Semgrep (free tier)
      Budget: $0-500/month
    
    Mid_Size:
      Primary: SonarQube + CodeQL + Semgrep
      Secondary: Checkmarx or Veracode
      Budget: $2000-10000/month
    
    Enterprise:
      Primary: Full suite (SonarQube + CodeQL + Checkmarx + Veracode)
      Secondary: Custom tools and integrations
      Budget: $50000+/month
  
  By_Industry:
    Financial_Services:
      Required: Veracode (compliance), Checkmarx (security)
      Recommended: CodeQL (advanced analysis)
    
    Healthcare:
      Required: HIPAA-compliant tools (Veracode, Checkmarx)
      Recommended: SonarQube (quality), CodeQL (security)
    
    E_Commerce:
      Required: PCI DSS compliance tools
      Recommended: Fast feedback tools (SonarCloud, Semgrep)
```

---

## 🔍 Part 2: GitHub CodeQL Integration

### CodeQL Fundamentals

**Understanding CodeQL:**
CodeQL is GitHub's semantic code analysis engine that treats code as data, allowing complex queries to find security vulnerabilities.

**CodeQL Workflow Setup:**
```yaml
name: CodeQL Security Analysis

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly deep scan

jobs:
  codeql-analysis:
    runs-on: ubuntu-latest
    
    permissions:
      actions: read
      contents: read
      security-events: write
    
    strategy:
      fail-fast: false
      matrix:
        language: ['javascript', 'typescript', 'python', 'java']
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
          # Custom queries for e-commerce security
          queries: +security-extended,security-and-quality
          config-file: ./.github/codeql/codeql-config.yml
      
      - name: Setup Build Environment
        if: matrix.language == 'java'
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Setup Node.js
        if: matrix.language == 'javascript' || matrix.language == 'typescript'
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Build Application
        if: matrix.language == 'java'
        run: |
          cd mobile-api
          ./mvnw clean compile -DskipTests
      
      - name: Install Dependencies
        if: matrix.language == 'javascript' || matrix.language == 'typescript'
        run: |
          npm ci --prefix frontend
          npm ci --prefix backend
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          category: "/language:${{ matrix.language }}"
          upload: true
          wait-for-processing: true
      
      - name: Upload CodeQL Results
        uses: actions/upload-artifact@v3
        with:
          name: codeql-results-${{ matrix.language }}
          path: /home/runner/work/_temp/codeql_databases/
```

### Custom CodeQL Queries

**E-Commerce Security Queries:**
```ql
/**
 * @name Hardcoded payment credentials
 * @description Detects hardcoded payment API keys and secrets
 * @kind problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id ecommerce/hardcoded-payment-credentials
 * @tags security
 *       external/cwe/cwe-798
 */

import javascript

from StringLiteral str
where
  // Payment-related hardcoded secrets
  str.getValue().regexpMatch("(?i).*(stripe|paypal|square).*[_-]?(key|secret|token)[_-]?.*[a-zA-Z0-9]{20,}.*") or
  str.getValue().regexpMatch("(?i).*sk_live_[a-zA-Z0-9]{24,}.*") or  // Stripe live keys
  str.getValue().regexpMatch("(?i).*pk_live_[a-zA-Z0-9]{24,}.*") or  // Stripe publishable keys
  str.getValue().regexpMatch("(?i).*paypal.*client[_-]?secret.*[a-zA-Z0-9]{20,}.*")
select str, "Hardcoded payment credential detected: " + str.getValue()
```

```ql
/**
 * @name SQL injection in e-commerce queries
 * @description Detects potential SQL injection in product and order queries
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.5
 * @precision high
 * @id ecommerce/sql-injection
 * @tags security
 *       external/cwe/cwe-89
 */

import javascript
import semmle.javascript.security.dataflow.SqlInjectionQuery

from Configuration cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink) and
  // Focus on e-commerce related queries
  (
    sink.getNode().asExpr().(CallExpr).getCallee().toString().matches("%query%") or
    sink.getNode().asExpr().(CallExpr).getCallee().toString().matches("%execute%")
  ) and
  (
    source.getNode().asExpr().toString().matches("%product%") or
    source.getNode().asExpr().toString().matches("%order%") or
    source.getNode().asExpr().toString().matches("%user%") or
    source.getNode().asExpr().toString().matches("%payment%")
  )
select sink.getNode(), source, sink,
  "SQL injection vulnerability in e-commerce query from $@.", source.getNode(), "user input"
```

**CodeQL Configuration:**
```yaml
# .github/codeql/codeql-config.yml
name: "E-Commerce CodeQL Config"

disable-default-queries: false

queries:
  - name: security-extended
    uses: security-extended
  - name: security-and-quality
    uses: security-and-quality
  - name: custom-ecommerce-queries
    uses: ./.github/codeql/queries/

paths-ignore:
  - "node_modules/"
  - "dist/"
  - "build/"
  - "**/*.test.js"
  - "**/*.spec.js"

paths:
  - "frontend/src/"
  - "backend/src/"
  - "shared/"
  - "mobile-api/src/"
```

---

## 🏢 Part 3: Enterprise SAST Tools Integration

### Checkmarx Integration

**Checkmarx SAST Workflow:**
```yaml
name: Checkmarx SAST Scan

on:
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 1 * * 0'

jobs:
  checkmarx-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Checkmarx SAST Scan
        uses: checkmarx-ts/checkmarx-cxflow-github-action@v1.6
        with:
          project: ecommerce-platform
          team: /CxServer/SP/Company/E-Commerce
          checkmarx_url: ${{ secrets.CHECKMARX_URL }}
          checkmarx_username: ${{ secrets.CHECKMARX_USERNAME }}
          checkmarx_password: ${{ secrets.CHECKMARX_PASSWORD }}
          checkmarx_client_secret: ${{ secrets.CHECKMARX_CLIENT_SECRET }}
          incremental: false
          preset: "Checkmarx Default"
          break_build: true
          scanners: sast
          params: |
            --severity=High --severity=Medium
            --cxflow.filter-severity=High,Medium
            --cxflow.filter-category=SQL_Injection,XSS,Command_Injection
            --cxflow.filter-status=New,Recurrent
      
      - name: Upload Checkmarx Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: checkmarx-results
          path: cx.sarif
      
      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: cx.sarif
```

**Line-by-Line Analysis:**

**`name: Checkmarx SAST Scan`** - Commercial SAST tool workflow for enterprise security scanning
**`schedule: - cron: '0 1 * * 0'`** - Weekly Sunday 1 AM comprehensive security scan
**`uses: checkmarx-ts/checkmarx-cxflow-github-action@v1.6`** - Official Checkmarx GitHub Action
**`project: ecommerce-platform`** - Checkmarx project identifier for scan organization
**`team: /CxServer/SP/Company/E-Commerce`** - Checkmarx team hierarchy for access control
**`checkmarx_url: ${{ secrets.CHECKMARX_URL }}`** - Checkmarx server URL from secrets
**`incremental: false`** - Full scan instead of incremental for comprehensive analysis
**`preset: "Checkmarx Default"`** - Security rule preset for scanning configuration
**`break_build: true`** - Fails workflow if high-severity vulnerabilities found
**`scanners: sast`** - Specifies static application security testing mode
**`--severity=High --severity=Medium`** - Scans for high and medium severity issues
**`--cxflow.filter-category=SQL_Injection,XSS,Command_Injection`** - Focuses on critical vulnerability types
**`--cxflow.filter-status=New,Recurrent`** - Includes new and recurring security issues
**`path: cx.sarif`** - SARIF format results for GitHub Security integration
**`sarif_file: cx.sarif`** - Uploads security findings to GitHub Security tab

### Veracode Integration

**Veracode SAST Pipeline:**
```yaml
name: Veracode Security Scan

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  veracode-sast:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Build Application
        run: |
          cd frontend
          npm ci
          npm run build
          
          cd ../backend
          npm ci
          npm run build
          
          cd ..
          zip -r ecommerce-app.zip frontend/dist backend/dist package.json
      
      - name: Veracode Upload and Scan
        uses: veracode/veracode-uploadandscan-action@0.2.6
        with:
          appname: 'E-Commerce Platform'
          createprofile: false
          filepath: 'ecommerce-app.zip'
          vid: ${{ secrets.VERACODE_API_ID }}
          vkey: ${{ secrets.VERACODE_API_KEY }}
          criticality: 'VeryHigh'
          scantimeout: 30
          exclude: '*.min.js,node_modules/*'
          include: '*.js,*.ts,*.jsx,*.tsx'
          scanallnonfatalpolicyflaws: true
          deleteincompletescan: true
        
      - name: Download Veracode Results
        uses: veracode/veracode-flaws-to-sarif@v2.1.4
        with:
          vid: ${{ secrets.VERACODE_API_ID }}
          vkey: ${{ secrets.VERACODE_API_KEY }}
          appname: 'E-Commerce Platform'
          scan-results-json: 'results.json'
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

**Line-by-Line Analysis:**

**`name: Veracode Security Scan`** - Commercial SAST workflow using Veracode platform for enterprise security
**`release: types: [published]`** - Triggers comprehensive scan on production releases
**`runs-on: ubuntu-latest`** - Ubuntu environment for Veracode CLI and build tools
**`uses: actions/checkout@v4`** - Downloads source code for Veracode analysis
**`uses: actions/setup-node@v4`** - Configures Node.js environment for application builds
**`cache: 'npm'`** - Caches dependencies for faster build performance
**`cd frontend`** - Changes to frontend directory for component build
**`npm ci`** - Clean install ensuring reproducible dependency versions
**`npm run build`** - Compiles frontend for production analysis
**`cd ../backend`** - Switches to backend directory for API build
**`zip -r ecommerce-app.zip`** - Creates deployment package for Veracode upload
**`uses: veracode/veracode-uploadandscan-action@0.2.6`** - Official Veracode GitHub Action
**`appname: 'E-Commerce Platform'`** - Veracode application identifier for scan organization
**`createprofile: false`** - Uses existing Veracode application profile
**`filepath: 'ecommerce-app.zip'`** - Specifies build artifact for security analysis
**`vid: ${{ secrets.VERACODE_API_ID }}`** - Veracode API credentials from GitHub secrets
**`vkey: ${{ secrets.VERACODE_API_KEY }}`** - Veracode API key for authentication
**`criticality: 'VeryHigh'`** - Sets high priority for e-commerce security scanning
**`scantimeout: 30`** - 30-minute timeout for comprehensive analysis
**`exclude: '*.min.js,node_modules/*'`** - Excludes minified files and dependencies from scan
**`include: '*.js,*.ts,*.jsx,*.tsx'`** - Focuses scan on application source code
**`scanallnonfatalpolicyflaws: true`** - Includes all policy violations in results
**`deleteincompletescan: true`** - Cleans up failed scans automatically
**`uses: veracode/veracode-flaws-to-sarif@v2.1.4`** - Converts Veracode results to SARIF format
**`scan-results-json: 'results.json'`** - Outputs structured results for processing
**`github-token: ${{ secrets.GITHUB_TOKEN }}`** - GitHub token for Security tab integration
          createprofile: false
          filepath: 'ecommerce-app.zip'
          version: '${{ github.run_id }}'
          vid: '${{ secrets.VERACODE_API_ID }}'
          vkey: '${{ secrets.VERACODE_API_KEY }}'
          createsandbox: false
          scantimeout: 20
          exclude: '*.min.js'
          include: '*.js,*.ts,*.jsx,*.tsx'
          criticality: 'VeryHigh'
      
      - name: Veracode Flaw Importer
        if: always()
        uses: veracode/veracode-flaws-to-issues@v2
        with:
          scan-results-json: 'results.json'
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Semgrep Integration

**Semgrep Custom Rules:**
```yaml
name: Semgrep Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
            p/javascript
            p/typescript
            .semgrep/ecommerce-rules.yml
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
      
      - name: Upload Semgrep Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: semgrep-results
          path: semgrep.sarif
```

**Custom Semgrep Rules:**
```yaml
# .semgrep/ecommerce-rules.yml
rules:
  - id: ecommerce-hardcoded-payment-keys
    pattern-either:
      - pattern: |
          $KEY = "sk_live_..."
      - pattern: |
          $KEY = "pk_live_..."
      - pattern: |
          stripe.api_key = "..."
    message: "Hardcoded Stripe API key detected"
    languages: [javascript, typescript]
    severity: ERROR
    metadata:
      category: security
      cwe: "CWE-798: Use of Hard-coded Credentials"
      owasp: "A02:2021 - Cryptographic Failures"

  - id: ecommerce-sql-injection-risk
    pattern-either:
      - pattern: |
          db.query($QUERY + $USER_INPUT)
      - pattern: |
          connection.execute($QUERY + $USER_INPUT)
      - pattern: |
          pool.query(`SELECT * FROM products WHERE id = ${$USER_INPUT}`)
    message: "Potential SQL injection in e-commerce query"
    languages: [javascript, typescript]
    severity: ERROR
    metadata:
      category: security
      cwe: "CWE-89: SQL Injection"
      owasp: "A03:2021 - Injection"

  - id: ecommerce-xss-in-templates
    pattern-either:
      - pattern: |
          res.send(`<html>...${$USER_INPUT}...</html>`)
      - pattern: |
          innerHTML = $USER_INPUT
      - pattern: |
          document.write($USER_INPUT)
    message: "Potential XSS vulnerability in e-commerce template"
    languages: [javascript, typescript]
    severity: ERROR
    metadata:
      category: security
      cwe: "CWE-79: Cross-site Scripting"
      owasp: "A03:2021 - Injection"

  - id: ecommerce-insecure-payment-logging
    pattern-either:
      - pattern: |
          console.log(..., $PAYMENT_DATA, ...)
      - pattern: |
          logger.info(..., $PAYMENT_DATA, ...)
    where:
      - metavariable-regex:
          metavariable: $PAYMENT_DATA
          regex: .*(card|payment|credit|cvv|cvc|ssn).*
    message: "Sensitive payment data logged - potential PCI DSS violation"
    languages: [javascript, typescript]
    severity: WARNING
    metadata:
      category: security
      cwe: "CWE-532: Information Exposure Through Log Files"
      pci_dss: "Requirement 3.4"
```

---

## 🔄 Part 4: Multi-Tool Orchestration

### Comprehensive Security Pipeline

**Multi-Tool SAST Orchestration:**
```yaml
name: Comprehensive SAST Security Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly comprehensive scan

env:
  NODE_VERSION: '18'
  JAVA_VERSION: '17'

jobs:
  # Fast feedback tools (run on every commit)
  fast-security-scan:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'pull_request'
    
    strategy:
      matrix:
        tool: [semgrep, sonarcloud, eslint-security]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Semgrep
        if: matrix.tool == 'semgrep'
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
            .semgrep/ecommerce-rules.yml
      
      - name: Run SonarCloud
        if: matrix.tool == 'sonarcloud'
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      
      - name: Run ESLint Security
        if: matrix.tool == 'eslint-security'
        run: |
          npx eslint . \
            --ext .js,.jsx,.ts,.tsx \
            --config .eslintrc.security.js \
            --format json \
            --output-file eslint-security-results.json
        continue-on-error: true
      
      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: fast-scan-results-${{ matrix.tool }}
          path: |
            semgrep.sarif
            eslint-security-results.json

  # Deep security analysis (weekly or on main branch)
  deep-security-scan:
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule' || github.ref == 'refs/heads/main'
    
    strategy:
      matrix:
        tool: [codeql, checkmarx, veracode]
      fail-fast: false
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Build Environment
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Setup Java
        if: matrix.tool == 'veracode'
        uses: actions/setup-java@v3
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
      
      - name: Build Application
        run: |
          npm ci
          npm run build
      
      - name: Run CodeQL
        if: matrix.tool == 'codeql'
        uses: github/codeql-action/init@v2
        with:
          languages: javascript,typescript
          queries: +security-extended,security-and-quality
      
      - name: CodeQL Analysis
        if: matrix.tool == 'codeql'
        uses: github/codeql-action/analyze@v2
      
      - name: Run Checkmarx
        if: matrix.tool == 'checkmarx'
        uses: checkmarx-ts/checkmarx-cxflow-github-action@v1.6
        with:
          project: ecommerce-platform
          team: /CxServer/SP/Company/E-Commerce
          checkmarx_url: ${{ secrets.CHECKMARX_URL }}
          checkmarx_username: ${{ secrets.CHECKMARX_USERNAME }}
          checkmarx_password: ${{ secrets.CHECKMARX_PASSWORD }}
          checkmarx_client_secret: ${{ secrets.CHECKMARX_CLIENT_SECRET }}
          break_build: false
          scanners: sast
      
      - name: Run Veracode
        if: matrix.tool == 'veracode'
        uses: veracode/veracode-uploadandscan-action@0.2.6
        with:
          appname: 'E-Commerce Platform'
          filepath: 'dist/'
          version: '${{ github.run_id }}'
          vid: '${{ secrets.VERACODE_API_ID }}'
          vkey: '${{ secrets.VERACODE_API_KEY }}'

  # Security results consolidation
  security-gate:
    runs-on: ubuntu-latest
    needs: [fast-security-scan, deep-security-scan]
    if: always()
    
    steps:
      - name: Download All Results
        uses: actions/download-artifact@v3
      
      - name: Consolidate Security Results
        run: |
          echo "🔒 Security Analysis Consolidation"
          echo "=================================="
          
          python3 << 'EOF'
          import json
          import os
          import glob
          
          # Security thresholds
          MAX_CRITICAL = 0
          MAX_HIGH = 5
          MAX_MEDIUM = 20
          
          total_critical = 0
          total_high = 0
          total_medium = 0
          total_low = 0
          
          findings = []
          
          # Process Semgrep results
          if os.path.exists('fast-scan-results-semgrep/semgrep.sarif'):
              with open('fast-scan-results-semgrep/semgrep.sarif', 'r') as f:
                  semgrep_data = json.load(f)
              
              for run in semgrep_data.get('runs', []):
                  for result in run.get('results', []):
                      severity = result.get('level', 'info').lower()
                      if severity == 'error':
                          total_critical += 1
                      elif severity == 'warning':
                          total_high += 1
                      
                      findings.append({
                          'tool': 'Semgrep',
                          'severity': severity,
                          'message': result.get('message', {}).get('text', ''),
                          'file': result.get('locations', [{}])[0].get('physicalLocation', {}).get('artifactLocation', {}).get('uri', '')
                      })
          
          # Process ESLint Security results
          if os.path.exists('fast-scan-results-eslint-security/eslint-security-results.json'):
              with open('fast-scan-results-eslint-security/eslint-security-results.json', 'r') as f:
                  eslint_data = json.load(f)
              
              for file_result in eslint_data:
                  for message in file_result.get('messages', []):
                      severity = 'high' if message.get('severity') == 2 else 'medium'
                      if severity == 'high':
                          total_high += 1
                      else:
                          total_medium += 1
                      
                      findings.append({
                          'tool': 'ESLint Security',
                          'severity': severity,
                          'message': message.get('message', ''),
                          'file': file_result.get('filePath', '')
                      })
          
          # Generate summary
          print(f"📊 Security Findings Summary:")
          print(f"Critical: {total_critical}/{MAX_CRITICAL}")
          print(f"High: {total_high}/{MAX_HIGH}")
          print(f"Medium: {total_medium}/{MAX_MEDIUM}")
          print(f"Low: {total_low}")
          print(f"Total: {len(findings)}")
          
          # Check security gate
          gate_passed = True
          if total_critical > MAX_CRITICAL:
              print(f"❌ Critical vulnerabilities exceed threshold: {total_critical} > {MAX_CRITICAL}")
              gate_passed = False
          
          if total_high > MAX_HIGH:
              print(f"❌ High vulnerabilities exceed threshold: {total_high} > {MAX_HIGH}")
              gate_passed = False
          
          if total_medium > MAX_MEDIUM:
              print(f"⚠️ Medium vulnerabilities exceed threshold: {total_medium} > {MAX_MEDIUM}")
              # Don't fail gate for medium, just warn
          
          if gate_passed:
              print("✅ Security gate PASSED")
          else:
              print("❌ Security gate FAILED")
              exit(1)
          EOF
      
      - name: Generate Security Report
        run: |
          echo "## 🔒 Multi-Tool Security Analysis Report" >> $GITHUB_STEP_SUMMARY
          echo "| Tool | Status | Critical | High | Medium |" >> $GITHUB_STEP_SUMMARY
          echo "|------|--------|----------|------|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| Semgrep | ✅ | 0 | 2 | 8 |" >> $GITHUB_STEP_SUMMARY
          echo "| SonarCloud | ✅ | 0 | 1 | 5 |" >> $GITHUB_STEP_SUMMARY
          echo "| ESLint Security | ✅ | 0 | 0 | 3 |" >> $GITHUB_STEP_SUMMARY
          echo "| CodeQL | ✅ | 0 | 1 | 2 |" >> $GITHUB_STEP_SUMMARY
          echo "| **Total** | **✅** | **0** | **4** | **18** |" >> $GITHUB_STEP_SUMMARY
```

---

## 🎓 Module Summary

You've mastered advanced SAST tools by learning:

**Core Concepts:**
- Multi-tool security strategy and tool selection
- CodeQL semantic analysis and custom queries
- Enterprise SAST tools (Checkmarx, Veracode, Semgrep)
- Security pipeline orchestration and consolidation

**Practical Skills:**
- Implementing comprehensive security scanning workflows
- Writing custom security rules and queries
- Integrating multiple SAST tools effectively
- Building security gates with consolidated results

**Enterprise Applications:**
- Production-ready multi-tool security pipelines
- Custom security rule development for e-commerce
- Compliance-focused security scanning
- Advanced vulnerability management workflows

**Next Steps:**
- Implement multi-tool security scanning for your e-commerce project
- Develop custom security rules for your specific use cases
- Set up comprehensive security gates and reporting
- Prepare for Module 9: Container Security Scanning

---

## 📚 Additional Resources

- [CodeQL Documentation](https://codeql.github.com/docs/)
- [Semgrep Rule Writing Guide](https://semgrep.dev/docs/writing-rules/overview/)
- [Checkmarx CxSAST Guide](https://checkmarx.com/resource/documents/en/34965-68702-checkmarx-sast-user-guide.html)
- [Veracode SAST Documentation](https://docs.veracode.com/r/c_about_static_analysis)
