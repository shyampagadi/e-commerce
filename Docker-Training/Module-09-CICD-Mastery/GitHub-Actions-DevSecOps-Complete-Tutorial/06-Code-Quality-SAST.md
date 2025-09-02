# 🔍 Code Quality & SAST Fundamentals

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** static analysis principles and code quality metrics
- **Master** ESLint, TSLint, and language-specific quality tools
- **Implement** basic security vulnerability detection
- **Configure** automated code quality workflows
- **Apply** quality gates and threshold management for e-commerce applications

## 🎯 Real-World Context
Code quality directly impacts maintainability, security, and business outcomes. Companies like Airbnb and Netflix have strict code quality standards that prevent bugs from reaching production. This module teaches you foundational static analysis techniques that prepare you for advanced security tools.

---

## 📚 Part 1: Static Analysis Fundamentals

### Understanding Static Analysis

**What is Static Analysis?**
Static analysis examines source code without executing it to identify potential issues, security vulnerabilities, and quality problems.

**Static Analysis Categories:**
```
Static Analysis Types
├── Syntax Analysis
│   ├── Parse errors and syntax issues
│   ├── Language rule violations
│   ├── Compilation errors
│   └── Basic structural problems
├── Semantic Analysis
│   ├── Type checking and inference
│   ├── Variable usage analysis
│   ├── Control flow analysis
│   └── Data flow analysis
├── Style Analysis
│   ├── Coding standard compliance
│   ├── Formatting consistency
│   ├── Naming conventions
│   └── Documentation requirements
├── Quality Analysis
│   ├── Code complexity metrics
│   ├── Duplication detection
│   ├── Maintainability assessment
│   └── Technical debt calculation
└── Security Analysis
    ├── Vulnerability pattern detection
    ├── Input validation issues
    ├── Authentication problems
    └── Data exposure risks
```

### Code Quality Metrics Explained

**Essential Quality Metrics:**
```yaml
Code_Quality_Metrics:
  Complexity_Metrics:
    Cyclomatic_Complexity:
      - Measures number of linearly independent paths
      - Target: <= 10 per function
      - High complexity = harder to test and maintain
    
    Cognitive_Complexity:
      - Measures how hard code is to understand
      - Target: <= 15 per function
      - Focuses on human comprehension
    
    Nesting_Depth:
      - Maximum level of nested structures
      - Target: <= 4 levels
      - Deep nesting reduces readability
  
  Size_Metrics:
    Lines_of_Code:
      - Physical lines in source files
      - Excludes comments and blank lines
      - Indicator of maintenance effort
    
    Function_Length:
      - Lines per function/method
      - Target: <= 50 lines
      - Long functions are harder to understand
  
  Duplication_Metrics:
    Code_Duplication:
      - Percentage of duplicated code blocks
      - Target: <= 3%
      - Duplication increases maintenance cost
    
    Similar_Code_Blocks:
      - Near-identical code patterns
      - Candidates for refactoring
      - Reduces consistency risks
  
  Maintainability_Metrics:
    Technical_Debt:
      - Estimated time to fix all issues
      - Measured in hours or days
      - Accumulates over time if ignored
    
    Maintainability_Index:
      - Composite score (0-100)
      - Based on complexity, size, and duplication
      - Higher scores indicate better maintainability
```

---

## 🔧 Part 2: ESLint Configuration and Integration

### ESLint Fundamentals

**Understanding ESLint:**
ESLint is a pluggable JavaScript linting utility that identifies and reports patterns in JavaScript code.

**ESLint Configuration Hierarchy:**
```javascript
// .eslintrc.js - Comprehensive ESLint configuration
module.exports = {
  // Environment settings
  env: {
    browser: true,
    node: true,
    es2022: true,
    jest: true
  },
  
  // Parser configuration
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true
    },
    project: './tsconfig.json'
  },
  
  // Extends configurations
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    '@typescript-eslint/recommended-requiring-type-checking',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:security/recommended',
    'plugin:import/recommended',
    'plugin:import/typescript'
  ],
  
  // Plugins
  plugins: [
    '@typescript-eslint',
    'react',
    'react-hooks',
    'security',
    'import',
    'jsx-a11y'
  ],
  
  // Rule configuration
  rules: {
    // Code quality rules
    'complexity': ['error', { max: 10 }],
    'max-depth': ['error', 4],
    'max-lines-per-function': ['error', { max: 50 }],
    'max-params': ['error', 4],
    
    // Security rules
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    
    // TypeScript specific rules
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/prefer-nullish-coalescing': 'error',
    '@typescript-eslint/prefer-optional-chain': 'error',
    
    // Import rules
    'import/order': ['error', {
      'groups': [
        'builtin',
        'external',
        'internal',
        'parent',
        'sibling',
        'index'
      ],
      'newlines-between': 'always'
    }],
    
    // React rules
    'react/prop-types': 'off', // Using TypeScript
    'react/react-in-jsx-scope': 'off', // React 17+
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    
    // Accessibility rules
    'jsx-a11y/alt-text': 'error',
    'jsx-a11y/anchor-has-content': 'error',
    'jsx-a11y/aria-props': 'error'
  },
  
  // Settings
  settings: {
    react: {
      version: 'detect'
    },
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true
      }
    }
  },
  
  // Override configurations for specific files
  overrides: [
    {
      files: ['**/*.test.ts', '**/*.test.tsx'],
      env: {
        jest: true
      },
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        'max-lines-per-function': 'off'
      }
    },
    {
      files: ['**/*.config.js', '**/*.config.ts'],
      rules: {
        'import/no-default-export': 'off'
      }
    }
  ]
};
```

### ESLint GitHub Actions Integration

**Comprehensive ESLint Workflow:**
```yaml
# .github/workflows/code-quality-eslint.yml
name: Code Quality with ESLint

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  eslint:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        component: [frontend, backend, shared-utils]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: ${{ matrix.component }}/package-lock.json
      
      - name: Install Dependencies
        working-directory: ${{ matrix.component }}
        run: npm ci
      
      - name: Run ESLint
        working-directory: ${{ matrix.component }}
        run: |
          npx eslint . \
            --ext .js,.jsx,.ts,.tsx \
            --format json \
            --output-file eslint-results.json \
            --max-warnings 0
          
          npx eslint . \
            --ext .js,.jsx,.ts,.tsx \
            --format @microsoft/eslint-formatter-sarif \
            --output-file eslint-results.sarif
      
      - name: Upload ESLint Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: eslint-results-${{ matrix.component }}
          path: |
            ${{ matrix.component }}/eslint-results.json
            ${{ matrix.component }}/eslint-results.sarif
          retention-days: 30
```

**Comprehensive Line-by-Line Analysis:**

**`# .github/workflows/code-quality-eslint.yml`**
- **Purpose**: Comment indicating ESLint-focused code quality workflow
- **Location**: Standard GitHub Actions workflow directory
- **Naming**: Descriptive filename for ESLint analysis
- **Organization**: Clear identification of code quality focus
- **Convention**: Follows GitHub Actions naming standards

**`name: Code Quality with ESLint`**
- **Display name**: Human-readable workflow name for GitHub UI
- **Purpose**: Clearly identifies ESLint code quality workflow
- **Visibility**: Appears in Actions tab and status checks
- **Branding**: Specific tool identification for team clarity
- **Monitoring**: Easy identification in workflow runs

**`on:`**
- **Triggers**: Defines events that execute code quality workflow
- **Automation**: Event-driven quality analysis execution
- **Control**: Determines when quality checks run
- **Efficiency**: Targeted execution for important code changes
- **Integration**: Supports development workflow integration

**`push: branches: [main, develop]`**
- **Push triggers**: Runs on pushes to main and develop branches
- **Quality gates**: Ensures important branches receive quality validation
- **Efficiency**: Avoids expensive quality checks on feature branches
- **Protection**: Validates code quality on production-bound branches
- **Resource optimization**: Focuses quality resources strategically

**`pull_request: branches: [main]`**
- **PR validation**: Runs quality checks on pull requests to main
- **Quality gate**: Prevents poor quality code from merging
- **Review integration**: Provides quality results in PR interface
- **Protection**: Ensures main branch quality standards
- **Collaboration**: Supports code review with quality metrics

**`jobs:`**
- **Job collection**: Defines code quality analysis jobs
- **Organization**: Groups quality-related tasks logically
- **Execution**: Quality jobs run based on matrix strategy
- **Scalability**: Matrix enables parallel component analysis
- **Structure**: Foundation for comprehensive quality pipeline

**`eslint:`**
- **Job identifier**: Descriptive name for ESLint analysis job
- **Purpose**: Executes ESLint code quality and security analysis
- **Matrix**: Uses matrix strategy for multi-component analysis
- **Tool focus**: Specifically for ESLint static analysis
- **Quality**: Comprehensive code quality validation

**`runs-on: ubuntu-latest`**
- **Environment**: Ubuntu Linux for ESLint execution
- **Compatibility**: Supports all Node.js and ESLint tools
- **Performance**: Fast and reliable analysis environment
- **Cost-effective**: Economical runner for quality analysis
- **Standard**: Common choice for JavaScript quality tools

**`strategy:`**
- **Matrix configuration**: Defines parallel execution strategy
- **Efficiency**: Enables parallel analysis of multiple components
- **Organization**: Component-based quality analysis structure
- **Scalability**: Easy to add new components to analysis
- **Performance**: Reduces total quality analysis time

**`matrix: component: [frontend, backend, shared-utils]`**
- **Component list**: Defines components for parallel ESLint analysis
- **Separation**: Analyzes each component independently
- **Parallelization**: All components analyzed simultaneously
- **Organization**: Clear component-based quality structure
- **Flexibility**: Different ESLint configs per component

**`steps:`**
- **Step collection**: Sequential steps for ESLint analysis
- **Process**: Standardized quality analysis process
- **Reusability**: Same steps applied to each matrix component
- **Efficiency**: Optimized steps for fast quality analysis
- **Quality**: Comprehensive ESLint workflow

**`- name: Checkout Code`**
- **Code retrieval**: Downloads repository code for analysis
- **Foundation**: Required for ESLint to analyze source code
- **Version**: Uses latest stable checkout action
- **Standard**: Common first step in quality workflows
- **Access**: Provides ESLint access to source files

**`uses: actions/checkout@v4`**
- **Official action**: GitHub's official code checkout action
- **Version**: Latest stable version for reliability
- **Functionality**: Downloads complete repository contents
- **Security**: Maintained by GitHub with security updates
- **Integration**: Optimized for GitHub Actions environment

**`with: fetch-depth: 0`**
- **Full history**: Downloads complete git history
- **Analysis**: Some quality tools analyze code changes over time
- **Comparison**: Enables comparison with previous versions
- **Metrics**: Historical data for quality trend analysis
- **Completeness**: Ensures all necessary data available

**`- name: Setup Node.js`**
- **Environment setup**: Configures Node.js for ESLint execution
- **Runtime**: Prepares JavaScript/TypeScript execution environment
- **Tools**: Required for ESLint and related quality tools
- **Caching**: Enables npm dependency caching
- **Foundation**: Essential for all Node.js quality operations

**`uses: actions/setup-node@v4`**
- **Node.js action**: Official GitHub action for Node.js setup
- **Version**: Latest stable version for features and security
- **Reliability**: Maintained by GitHub with regular updates
- **Features**: Supports caching and multiple Node.js versions
- **Integration**: Optimized for GitHub Actions workflows

**`with: node-version: '18'`**
- **Version specification**: Uses Node.js version 18 LTS
- **Stability**: LTS version for production reliability
- **Compatibility**: Ensures ESLint compatibility
- **Consistency**: Same version across all quality jobs
- **Support**: Long-term support for stability

**`cache: 'npm'`**
- **Dependency caching**: Enables npm package caching
- **Performance**: Reduces dependency installation time by 60-80%
- **Efficiency**: Reuses cached packages across workflow runs
- **Optimization**: Dramatically improves quality analysis speed
- **Resource management**: Reduces network and time overhead

**`cache-dependency-path: ${{ matrix.component }}/package-lock.json`**
- **Dynamic cache key**: Component-specific cache management
- **Matrix integration**: Uses matrix variable for cache path
- **Precision**: Separate cache for each component
- **Efficiency**: Optimal cache hit rates per component
- **Organization**: Component-isolated dependency caching

**`- name: Install Dependencies`**
- **Dependency setup**: Installs component-specific dependencies
- **Foundation**: Required before running ESLint analysis
- **Matrix context**: Uses matrix component for directory
- **Performance**: Benefits from component-specific caching
- **Isolation**: Each component has independent dependencies

**`working-directory: ${{ matrix.component }}`**
- **Dynamic directory**: Uses matrix variable for component path
- **Context**: Sets working directory for component analysis
- **Organization**: Handles monorepo structure efficiently
- **Flexibility**: Adapts to different component structures
- **Consistency**: Standardized approach across components

**`run: npm ci`**
- **Clean install**: Reproducible dependency installation
- **Performance**: Faster than npm install in CI environments
- **Reliability**: Uses package-lock.json for exact versions
- **Best practice**: Preferred npm command for CI pipelines
- **Consistency**: Ensures identical dependency versions

**`- name: Run ESLint`**
- **Quality analysis**: Executes ESLint code quality analysis
- **Multi-format**: Generates multiple output formats
- **Comprehensive**: Analyzes all relevant file types
- **Strict**: Uses zero-warning policy for quality
- **Reporting**: Creates detailed analysis reports

**`run: |`**
- **Multi-line script**: Enables multiple ESLint commands
- **Formats**: Generates both JSON and SARIF outputs
- **Comprehensive**: Complete ESLint analysis execution
- **Reporting**: Multiple output formats for different uses
- **Quality**: Strict quality enforcement with detailed reporting

**`npx eslint . \`**
- **ESLint execution**: Runs ESLint on current directory
- **npx**: Executes ESLint from node_modules
- **Scope**: Analyzes all files in component directory
- **Tool**: Uses project-specific ESLint configuration
- **Analysis**: Comprehensive static code analysis

**`--ext .js,.jsx,.ts,.tsx \`**
- **File extensions**: Specifies file types for analysis
- **JavaScript**: Includes .js and .jsx files
- **TypeScript**: Includes .ts and .tsx files
- **Comprehensive**: Covers all common JavaScript/TypeScript extensions
- **Scope**: Ensures all relevant files analyzed

**`--format json \`**
- **Output format**: Generates JSON format results
- **Machine readable**: Structured data for programmatic processing
- **Integration**: Can be processed by other tools
- **Detailed**: Comprehensive analysis results in JSON
- **Automation**: Enables automated quality processing

**`--output-file eslint-results.json \`**
- **Output file**: Saves JSON results to specific file
- **Persistence**: Results saved for artifact upload
- **Organization**: Structured file naming for results
- **Access**: Results available for further processing
- **Reporting**: Enables detailed quality reporting

**`--max-warnings 0`**
- **Strict policy**: Treats warnings as failures
- **Quality gate**: Enforces zero-warning policy
- **Standards**: High quality standards enforcement
- **Failure**: Build fails if any warnings found
- **Excellence**: Promotes code excellence culture

**`npx eslint . \`**
- **Second execution**: Runs ESLint again for SARIF format
- **Format difference**: Same analysis, different output format
- **SARIF**: Security-focused output format
- **Integration**: SARIF integrates with GitHub security features
- **Comprehensive**: Multiple formats for different use cases

**`--format @microsoft/eslint-formatter-sarif \`**
- **SARIF formatter**: Microsoft's SARIF format for ESLint
- **Security**: SARIF format focuses on security findings
- **Integration**: Integrates with GitHub security tab
- **Standards**: Industry standard for security analysis results
- **Visibility**: Security findings visible in GitHub UI

**`--output-file eslint-results.sarif`**
- **SARIF output**: Saves SARIF format results
- **Security**: Security-focused analysis results
- **Integration**: GitHub can display SARIF results natively
- **Compliance**: Meets security reporting standards
- **Visibility**: Security findings in GitHub security tab

**`- name: Upload ESLint Results`**
- **Artifact storage**: Preserves ESLint analysis results
- **Persistence**: Results available after workflow completion
- **Sharing**: Makes results available for download
- **Integration**: Enables result processing by other tools
- **Reporting**: Comprehensive quality result preservation

**`uses: actions/upload-artifact@v3`**
- **Artifact action**: Official GitHub action for artifact management
- **Version**: Stable version for reliable artifact handling
- **Storage**: Uploads files to GitHub's artifact storage
- **Management**: Handles compression and metadata
- **Integration**: Integrates with GitHub's artifact system

**`if: always()`**
- **Conditional execution**: Runs even if previous steps failed
- **Reliability**: Ensures results uploaded regardless of ESLint outcome
- **Debugging**: Results available even for failed quality checks
- **Completeness**: Always preserves analysis results
- **Troubleshooting**: Enables analysis of quality failures

**`with: name: eslint-results-${{ matrix.component }}`**
- **Artifact naming**: Component-specific artifact names
- **Organization**: Clear identification of component results
- **Matrix**: Uses matrix variable for dynamic naming
- **Separation**: Separate artifacts for each component
- **Clarity**: Obvious component-result association

**`path: |`**
- **Multi-path**: Includes multiple files in artifact
- **Comprehensive**: Both JSON and SARIF results included
- **Organization**: Structured result file inclusion
- **Completeness**: All analysis outputs preserved
- **Flexibility**: Multiple format results available

**`${{ matrix.component }}/eslint-results.json`**
- **JSON results**: Component-specific JSON analysis results
- **Path**: Dynamic path using matrix component variable
- **Format**: Machine-readable analysis results
- **Processing**: Enables automated result processing
- **Integration**: Can be consumed by quality dashboards

**`${{ matrix.component }}/eslint-results.sarif`**
- **SARIF results**: Component-specific security analysis results
- **Security**: Security-focused analysis format
- **Integration**: GitHub security tab integration
- **Standards**: Industry standard security result format
- **Visibility**: Security findings in GitHub interface

**`retention-days: 30`**
- **Artifact lifecycle**: Results retained for 30 days
- **Balance**: Sufficient time for analysis and review
- **Storage management**: Automatic cleanup after retention period
- **Cost optimization**: Prevents unlimited artifact accumulation
- **Access**: Results available for extended analysis period
          # Run ESLint with multiple output formats
          npx eslint . \
          # ↑ npx runs ESLint without global installation
          # . means scan current directory and subdirectories
          # \ allows command to continue on next line
            --ext .js,.jsx,.ts,.tsx \
          # ↑ --ext specifies file extensions to analyze
          # Covers JavaScript, JSX (React), TypeScript, and TSX files
            --format stylish \
          # ↑ --format stylish provides human-readable console output
          # Good for developers reading workflow logs
            --format json \
          # ↑ Also outputs in JSON format for machine processing
          # Same scan, two different output formats
            --output-file eslint-results.json
          # ↑ Saves JSON results to file for later processing
          # File will be used by subsequent steps
        continue-on-error: true
        # ↑ Allows workflow to continue even if ESLint finds issues
        # Important: we want to process results even if there are violations
        # Without this, workflow would stop here on any ESLint error
      
      - name: Annotate ESLint Results
        # ↑ Adds ESLint findings as comments on pull request
        uses: ataylorme/eslint-annotate-action@v2
        # ↑ Third-party action that creates PR annotations from ESLint results
        if: always()
        # ↑ Runs even if previous steps failed (e.g., ESLint found errors)
        with:
          # ↑ Parameters passed to the annotation action
          repo-token: "${{ secrets.GITHUB_TOKEN }}"
          # ↑ GitHub token for API access (automatically provided)
          # Allows action to comment on pull requests
          report-json: "${{ matrix.component }}/eslint-results.json"
          # ↑ Path to ESLint JSON results file
          # Action reads this file and creates PR comments for each issue
      
      - name: Upload ESLint Results
        # ↑ Saves ESLint results as downloadable artifacts
        uses: actions/upload-artifact@v4
        # ↑ Official GitHub action for uploading files
        if: always()
        # ↑ Upload results whether ESLint passed or failed
        with:
          name: eslint-results-${{ matrix.component }}
          # ↑ Artifact name includes component name for identification
          # Creates separate artifacts: eslint-results-frontend, etc.
          path: ${{ matrix.component }}/eslint-results.json
          # ↑ Path to the results file to upload
          retention-days: 30
          # ↑ How long GitHub keeps the artifact (1-90 days)
```

**Detailed Explanation for Newbies:**

1. **Matrix Strategy Benefits:**
   - **Parallel Execution**: Each component runs simultaneously, saving time
   - **Isolated Results**: Problems in one component don't affect others
   - **Component-Specific Config**: Each component can have different ESLint rules
   - **Scalability**: Easy to add new components to the matrix

2. **Working Directory Concept:**
   - **Monorepo Support**: Handles projects with multiple components
   - **Isolated Dependencies**: Each component has its own package.json
   - **Scoped Analysis**: ESLint only analyzes files in the specific component

3. **Multiple Output Formats:**
   - **Stylish Format**: Human-readable for developers viewing logs
   - **JSON Format**: Machine-readable for automated processing
   - **Same Analysis**: One ESLint run produces both formats efficiently

4. **Error Handling Strategy:**
   - **continue-on-error**: Prevents workflow from stopping on ESLint violations
   - **if: always()**: Ensures result processing happens regardless of ESLint outcome
   - **Graceful Degradation**: Workflow provides feedback even when code has issues

5. **Pull Request Integration:**
   - **Annotations**: ESLint issues appear as comments on specific code lines
   - **Artifacts**: Detailed results available for download and analysis
   - **Developer Feedback**: Immediate visibility into code quality issues
          path: ${{ matrix.component }}/eslint-results.json
      
      - name: ESLint Summary
        if: always()
        run: |
          cd ${{ matrix.component }}
          
          # Parse ESLint results
          python3 << 'EOF'
          import json
          import sys
          
          try:
              with open('eslint-results.json', 'r') as f:
                  results = json.load(f)
              
              total_files = len(results)
              total_errors = sum(len([msg for msg in file['messages'] if msg['severity'] == 2]) for file in results)
              total_warnings = sum(len([msg for msg in file['messages'] if msg['severity'] == 1]) for file in results)
              
              print(f"## 🔍 ESLint Results for ${{ matrix.component }}")
              print(f"**Files Analyzed:** {total_files}")
              print(f"**Errors:** {total_errors}")
              print(f"**Warnings:** {total_warnings}")
              
              if total_errors > 0:
                  print("❌ ESLint found errors that must be fixed")
                  sys.exit(1)
              elif total_warnings > 0:
                  print("⚠️ ESLint found warnings that should be addressed")
              else:
                  print("✅ No ESLint issues found")
          
          except FileNotFoundError:
              print("❌ ESLint results file not found")
              sys.exit(1)
          EOF
```

---

## 🔒 Part 3: Security-Focused Static Analysis

### Basic Security Pattern Detection

**Security-Focused ESLint Rules:**
```javascript
// .eslintrc.security.js - Security-focused configuration
module.exports = {
  extends: [
    'plugin:security/recommended'
  ],
  
  plugins: [
    'security',
    'no-secrets'
  ],
  
  rules: {
    // Injection vulnerabilities
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-non-literal-fs-filename': 'error',
    'security/detect-eval-with-expression': 'error',
    
    // XSS vulnerabilities
    'security/detect-unsafe-regex': 'error',
    'security/detect-possible-timing-attacks': 'warn',
    
    // Information disclosure
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'warn',
    
    // Secrets detection
    'no-secrets/no-secrets': ['error', {
      'tolerance': 4.2,
      'additionalRegexes': {
        'API Key': 'api[_-]?key[_-]?[=:][\'"]?[a-zA-Z0-9]{20,}',
        'Database URL': 'postgres://[^\\s]+',
        'JWT Secret': 'jwt[_-]?secret[_-]?[=:][\'"]?[a-zA-Z0-9]{32,}'
      }
    }]
  }
};
```

**Custom Security Rules:**
```javascript
// custom-security-rules.js - Custom security rule implementations
module.exports = {
  rules: {
    'no-hardcoded-secrets': {
      meta: {
        type: 'problem',
        docs: {
          description: 'Disallow hardcoded secrets and credentials'
        },
        schema: []
      },
      
      create(context) {
        const secretPatterns = [
          /password\s*[=:]\s*['"][^'"]{8,}['"]/i,
          /secret\s*[=:]\s*['"][^'"]{16,}['"]/i,
          /api[_-]?key\s*[=:]\s*['"][^'"]{20,}['"]/i,
          /token\s*[=:]\s*['"][^'"]{32,}['"]/i
        ];
        
        return {
          Literal(node) {
            if (typeof node.value === 'string') {
              for (const pattern of secretPatterns) {
                if (pattern.test(node.raw)) {
                  context.report({
                    node,
                    message: 'Potential hardcoded secret detected'
                  });
                }
              }
            }
          }
        };
      }
    },
    
    'no-sql-injection': {
      meta: {
        type: 'problem',
        docs: {
          description: 'Detect potential SQL injection vulnerabilities'
        }
      },
      
      create(context) {
        return {
          CallExpression(node) {
            if (node.callee.property && 
                ['query', 'execute', 'raw'].includes(node.callee.property.name)) {
              
              const firstArg = node.arguments[0];
              if (firstArg && firstArg.type === 'BinaryExpression' && 
                  firstArg.operator === '+') {
                context.report({
                  node,
                  message: 'Potential SQL injection: avoid string concatenation in queries'
                });
              }
            }
          }
        };
      }
    }
  }
};
```

### Multi-Language Static Analysis

**Python Security Analysis:**
```yaml
name: Python Security Analysis

on:
  push:
    paths: ['**/*.py']

jobs:
  python-security:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install Security Tools
        run: |
          pip install bandit safety flake8 mypy
      
      - name: Run Bandit Security Scan
        run: |
          bandit -r . -f json -o bandit-results.json
        continue-on-error: true
      
      - name: Run Safety Check
        run: |
          safety check --json --output safety-results.json
        continue-on-error: true
      
      - name: Run Flake8 Quality Check
        run: |
          flake8 . --format=json --output-file=flake8-results.json
        continue-on-error: true
      
      - name: Upload Python Analysis Results
        uses: actions/upload-artifact@v3
        with:
          name: python-analysis-results
          path: |
            bandit-results.json
            safety-results.json
            flake8-results.json
```

---

## 🧪 Part 4: Hands-On Implementation

### Exercise: Complete Code Quality Pipeline

**Objective:** Implement comprehensive code quality analysis for a multi-language e-commerce application.

**Step 1: Multi-Language Quality Configuration**
```bash
#!/bin/bash
# setup-quality-tools.sh - Setup quality analysis tools

echo "🔧 Setting up code quality tools..."

# Frontend quality tools
cd frontend
npm install --save-dev \
  eslint \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  eslint-plugin-react \
  eslint-plugin-react-hooks \
  eslint-plugin-security \
  eslint-plugin-import \
  eslint-plugin-jsx-a11y \
  eslint-plugin-no-secrets \
  prettier \
  @types/node

# Backend quality tools
cd ../backend
npm install --save-dev \
  eslint \
  @typescript-eslint/parser \
  @typescript-eslint/eslint-plugin \
  eslint-plugin-security \
  eslint-plugin-node \
  prettier

# Python quality tools (if using Python services)
pip install \
  bandit \
  safety \
  flake8 \
  black \
  mypy \
  pylint

echo "✅ Quality tools installed"
```

**Step 2: Comprehensive Quality Workflow**
```yaml
name: Comprehensive Code Quality

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.11'

jobs:
  # Job 1: JavaScript/TypeScript Quality
  javascript-quality:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        component: [frontend, backend]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: ${{ matrix.component }}/package-lock.json
      
      - name: Install Dependencies
        working-directory: ${{ matrix.component }}
        run: npm ci
      
      - name: Run ESLint
        working-directory: ${{ matrix.component }}
        run: |
          npx eslint . \
            --ext .js,.jsx,.ts,.tsx \
            --format stylish \
            --format json \
            --output-file eslint-results.json
      
      - name: Run Prettier Check
        working-directory: ${{ matrix.component }}
        run: npx prettier --check .
      
      - name: TypeScript Type Check
        working-directory: ${{ matrix.component }}
        run: |
          if [ -f "tsconfig.json" ]; then
            npx tsc --noEmit
          fi
      
      - name: Calculate Quality Metrics
        working-directory: ${{ matrix.component }}
        run: |
          # Install complexity analysis tool
          npm install --no-save complexity-report
          
          # Generate complexity report
          npx cr --format json --output complexity-report.json src/
      
      - name: Upload Quality Results
        uses: actions/upload-artifact@v3
        with:
          name: js-quality-${{ matrix.component }}
          path: |
            ${{ matrix.component }}/eslint-results.json
            ${{ matrix.component }}/complexity-report.json

  # Job 2: Python Quality (if applicable)
  python-quality:
    runs-on: ubuntu-latest
    if: contains(github.event.head_commit.modified, '.py')
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install Quality Tools
        run: |
          pip install bandit safety flake8 black mypy pylint
      
      - name: Run Black Format Check
        run: black --check .
      
      - name: Run Flake8
        run: flake8 . --format=json --output-file=flake8-results.json
        continue-on-error: true
      
      - name: Run Bandit Security Scan
        run: bandit -r . -f json -o bandit-results.json
        continue-on-error: true
      
      - name: Run MyPy Type Check
        run: mypy . --json-report mypy-report
        continue-on-error: true
      
      - name: Upload Python Quality Results
        uses: actions/upload-artifact@v3
        with:
          name: python-quality-results
          path: |
            flake8-results.json
            bandit-results.json
            mypy-report/

  # Job 3: Quality Gate Evaluation
  quality-gate:
    runs-on: ubuntu-latest
    needs: [javascript-quality, python-quality]
    if: always()
    
    steps:
      - name: Download Quality Results
        uses: actions/download-artifact@v3
      
      - name: Evaluate Quality Gate
        run: |
          echo "📊 Evaluating quality gate..."
          
          python3 << 'EOF'
          import json
          import os
          import sys
          
          # Quality thresholds
          MAX_ESLINT_ERRORS = 0
          MAX_ESLINT_WARNINGS = 10
          MAX_COMPLEXITY = 10
          MAX_SECURITY_ISSUES = 0
          
          total_errors = 0
          total_warnings = 0
          security_issues = 0
          quality_issues = []
          
          # Process JavaScript quality results
          for component in ['frontend', 'backend']:
              eslint_file = f"js-quality-{component}/eslint-results.json"
              if os.path.exists(eslint_file):
                  with open(eslint_file, 'r') as f:
                      eslint_results = json.load(f)
                  
                  component_errors = sum(len([msg for msg in file['messages'] if msg['severity'] == 2]) for file in eslint_results)
                  component_warnings = sum(len([msg for msg in file['messages'] if msg['severity'] == 1]) for file in eslint_results)
                  
                  total_errors += component_errors
                  total_warnings += component_warnings
                  
                  print(f"{component}: {component_errors} errors, {component_warnings} warnings")
          
          # Process Python security results
          if os.path.exists('python-quality-results/bandit-results.json'):
              with open('python-quality-results/bandit-results.json', 'r') as f:
                  bandit_results = json.load(f)
              
              security_issues = len(bandit_results.get('results', []))
              print(f"Python security issues: {security_issues}")
          
          # Evaluate quality gate
          print("\n📋 Quality Gate Evaluation:")
          print(f"ESLint Errors: {total_errors}/{MAX_ESLINT_ERRORS}")
          print(f"ESLint Warnings: {total_warnings}/{MAX_ESLINT_WARNINGS}")
          print(f"Security Issues: {security_issues}/{MAX_SECURITY_ISSUES}")
          
          # Check thresholds
          if total_errors > MAX_ESLINT_ERRORS:
              quality_issues.append(f"Too many ESLint errors: {total_errors}")
          
          if total_warnings > MAX_ESLINT_WARNINGS:
              quality_issues.append(f"Too many ESLint warnings: {total_warnings}")
          
          if security_issues > MAX_SECURITY_ISSUES:
              quality_issues.append(f"Security issues found: {security_issues}")
          
          # Final result
          if quality_issues:
              print("\n❌ Quality Gate FAILED:")
              for issue in quality_issues:
                  print(f"  - {issue}")
              sys.exit(1)
          else:
              print("\n✅ Quality Gate PASSED")
          EOF
      
      - name: Generate Quality Report
        if: always()
        run: |
          echo "## 📊 Code Quality Report" >> $GITHUB_STEP_SUMMARY
          echo "| Component | Errors | Warnings | Status |" >> $GITHUB_STEP_SUMMARY
          echo "|-----------|--------|----------|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| Frontend | 0 | 3 | ✅ |" >> $GITHUB_STEP_SUMMARY
          echo "| Backend | 0 | 1 | ✅ |" >> $GITHUB_STEP_SUMMARY
          echo "| Python | 0 | 0 | ✅ |" >> $GITHUB_STEP_SUMMARY
```

---

## 🎓 Module Summary

You've mastered code quality and SAST fundamentals by learning:

**Core Concepts:**
- Static analysis principles and quality metrics
- ESLint configuration and security rules
- Multi-language quality analysis
- Quality gate implementation

**Practical Skills:**
- Comprehensive ESLint setup with security focus
- Custom security rule development
- Multi-component quality workflows
- Automated quality gate evaluation

**Enterprise Applications:**
- Production-ready quality standards
- Security-focused static analysis
- Comprehensive quality reporting
- Integration with development workflows

**Next Steps:**
- Implement quality analysis for your e-commerce project
- Configure custom security rules for your use case
- Set up quality gates with appropriate thresholds
- Prepare for Module 7: SonarQube/SonarCloud Mastery

---

## 📚 Additional Resources

- [ESLint Documentation](https://eslint.org/docs/)
- [ESLint Security Plugin](https://github.com/nodesecurity/eslint-plugin-security)
- [Static Analysis Tools Comparison](https://github.com/analysis-tools-dev/static-analysis)
- [Code Quality Metrics Guide](https://docs.sonarqube.org/latest/user-guide/metric-definitions/)
