# Common Mistakes & Troubleshooting - Complete Theory & Practice Guide

## 🎯 **Learning Theory Foundation**

### **Understanding GitLab CI/CD Error Patterns**
**Theory**: Most pipeline failures follow predictable patterns. Understanding these patterns enables proactive error prevention and faster troubleshooting.

**Error Classification System:**
- **Syntax Errors (40%)**: YAML formatting, indentation, structure
- **Configuration Errors (25%)**: Missing sections, undefined references
- **Runtime Errors (20%)**: Image issues, dependency failures, resource limits
- **Logic Errors (15%)**: Incorrect conditions, wrong variables, timing issues

**Business Impact Theory:**
- **Cost of Errors**: Each pipeline failure costs 15-30 minutes of developer time
- **Compound Effect**: Errors block entire teams, multiplying impact
- **Quality Impact**: Failed pipelines delay releases and reduce confidence
- **Learning Curve**: Understanding patterns reduces future error rates by 80%

---

## 🚨 **Critical Error Categories with Theory**

### **Category 1: YAML Syntax Errors - Foundational Theory**

**Theory Background:**
YAML (YAML Ain't Markup Language) is a human-readable data serialization standard. GitLab CI/CD uses YAML for pipeline configuration because it's both machine-parseable and human-readable. However, YAML's sensitivity to whitespace makes it error-prone.

**Whitespace Theory:**
- **Indentation Rules**: YAML uses indentation to represent hierarchy
- **Consistency Requirement**: All indentation must use same character (spaces OR tabs, never mixed)
- **Semantic Meaning**: Indentation level determines data structure relationships
- **Parser Behavior**: Mixed indentation causes immediate parsing failure

#### **1. YAML Indentation Errors - The #1 Pipeline Killer**

**Learning Example - Progressive Complexity:**

**Level 1: Basic Indentation (Beginner)**
```yaml
# Correct basic job structure
simple-job:
  script:
    - echo "Hello World"
```
**Theory**: 2-space indentation creates clear hierarchy: job → property → list item

**Level 2: Complex Indentation (Intermediate)**
```yaml
# Correct complex job with multiple properties
complex-job:
  stage: test
  image: node:18
  variables:
    NODE_ENV: production
  script:
    - npm install
    - npm test
  artifacts:
    paths:
      - coverage/
    expire_in: 1 week
```
**Theory**: Consistent 2-space indentation maintains readability and parseability

**❌ Common Mistake - Mixed Indentation:**
```yaml
# Wrong - mixed spaces and tabs (invisible error)
job1:
  script:
	- echo "hello"  # Tab character used (invisible)
    - echo "world"  # Space characters used
```

**Line-by-Line Error Analysis:**
- **Line 1**: `job1:` - Correct job name definition
- **Line 2**: `  script:` - Correct 2-space indentation for property
- **Line 3**: `	- echo "hello"` - **ERROR**: Tab character (ASCII 9) used
- **Line 4**: `    - echo "world"` - Space characters (ASCII 32) used
- **Parser Result**: "mapping values are not allowed here" error
- **Root Cause**: YAML parser cannot handle mixed whitespace types

**✅ Correct Implementation:**
```yaml
# Right - consistent spaces only
job1:
  script:
    - echo "hello"  # 4 spaces total (2 + 2)
    - echo "world"  # 4 spaces total (consistent)
```

**Line-by-Line Success Analysis:**
- **Line 1**: `job1:` - Job identifier with colon separator
- **Line 2**: `  script:` - Property key with 2-space indentation
- **Line 3**: `    - echo "hello"` - List item with 4-space indentation (2+2)
- **Line 4**: `    - echo "world"` - Consistent 4-space indentation
- **Parser Result**: Valid YAML structure, successful parsing

**Business Impact:**
- **Time Saved**: Prevents 2-3 hours debugging per occurrence
- **Team Productivity**: Reduces support tickets by 40%
- **Pipeline Reliability**: Improves success rate from 60% to 85%
- **Developer Confidence**: Clear errors enable faster resolution

#### **2. Missing Script Section - Configuration Theory**

**Theory Background:**
GitLab CI/CD jobs represent units of work. Every job must define what work to perform through the `script` section. Jobs without scripts have no executable content and fail immediately.

**Job Lifecycle Theory:**
1. **Job Creation**: GitLab creates job from YAML definition
2. **Validation**: Checks for required sections (script is mandatory)
3. **Execution**: Runs commands defined in script section
4. **Completion**: Reports success/failure based on script exit codes

**Learning Example - Job Structure Evolution:**

**Level 1: Minimal Job (Beginner)**
```yaml
# Simplest possible working job
hello-job:
  script:
    - echo "Hello GitLab CI/CD"
```
**Theory**: Minimal viable job requires only name and script

**Level 2: Standard Job (Intermediate)**
```yaml
# Standard job with common properties
test-job:
  stage: test
  image: node:18
  script:
    - npm install
    - npm test
```
**Theory**: Additional properties control execution environment and timing

**Level 3: Advanced Job (Expert)**
```yaml
# Production-ready job with full configuration
production-test:
  stage: test
  image: node:18-alpine
  variables:
    NODE_ENV: test
    CI: true
  before_script:
    - apk add --no-cache git
  script:
    - npm ci --only=production
    - npm run test:coverage
  after_script:
    - npm run cleanup
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  retry: 2
```
**Theory**: Production jobs include error handling, reporting, and reliability features

**❌ Common Mistake - Missing Script:**
```yaml
# Wrong - no executable commands defined
test-job:
  stage: test
  image: node:18
  # Missing script section causes immediate failure
```

**Configuration Analysis:**
- **Line 1**: `test-job:` - Valid job name
- **Line 2**: `  stage: test` - Valid stage assignment
- **Line 3**: `  image: node:18` - Valid image specification
- **Missing**: `script:` section with executable commands
- **GitLab Behavior**: Job fails before execution with configuration error
- **Error Message**: "jobs:test-job config should contain either a script or trigger"

**✅ Correct Implementation:**
```yaml
# Right - complete job with executable script
test-job:
  stage: test
  image: node:18
  script:
    - npm install    # Install project dependencies
    - npm test       # Execute test suite
```

**Configuration Success Analysis:**
- **Line 1**: `test-job:` - Unique job identifier
- **Line 2**: `  stage: test` - Execution stage assignment
- **Line 3**: `  image: node:18` - Docker runtime environment
- **Line 4**: `  script:` - **REQUIRED**: Executable commands section
- **Line 5**: `    - npm install` - Dependency installation command
- **Line 6**: `    - npm test` - Test execution command
- **GitLab Behavior**: Job executes successfully with proper script definition

### **Category 2: Pipeline Structure Errors - Architecture Theory**

**Theory Background:**
GitLab CI/CD pipelines use stages to organize job execution order. Stages create a directed acyclic graph (DAG) that determines job dependencies and parallelization opportunities.

**Stage Architecture Theory:**
- **Sequential Execution**: Stages run in defined order
- **Parallel Jobs**: Jobs within same stage run in parallel
- **Dependency Management**: Later stages depend on earlier stage success
- **Failure Propagation**: Stage failure stops subsequent stages

#### **3. Undefined Stage References - Structure Theory**

**Learning Example - Pipeline Architecture Evolution:**

**Level 1: Simple Pipeline (Beginner)**
```yaml
# Basic three-stage pipeline
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - echo "Building application"

test-job:
  stage: test
  script:
    - echo "Testing application"

deploy-job:
  stage: deploy
  script:
    - echo "Deploying application"
```
**Theory**: Linear pipeline with clear progression: build → test → deploy

**Level 2: Complex Pipeline (Intermediate)**
```yaml
# Multi-environment pipeline with parallel jobs
stages:
  - prepare
  - build
  - test
  - security
  - deploy-staging
  - deploy-production

prepare-workspace:
  stage: prepare
  script:
    - echo "Preparing build environment"

build-frontend:
  stage: build
  script:
    - npm run build:frontend

build-backend:
  stage: build
  script:
    - npm run build:backend

unit-tests:
  stage: test
  script:
    - npm run test:unit

integration-tests:
  stage: test
  script:
    - npm run test:integration

security-scan:
  stage: security
  script:
    - npm audit
    - docker scan $CI_REGISTRY_IMAGE

deploy-staging:
  stage: deploy-staging
  script:
    - kubectl apply -f k8s/staging/

deploy-production:
  stage: deploy-production
  script:
    - kubectl apply -f k8s/production/
  when: manual
```
**Theory**: Complex pipeline with parallel execution and manual gates

**❌ Common Mistake - Undefined Stage:**
```yaml
# Wrong - referencing non-existent stage
stages:
  - build
  - test
  # 'deploy' stage not defined here

deploy-job:
  stage: deploy  # ERROR: stage not in stages list
  script:
    - echo "deploying"
```

**Structure Error Analysis:**
- **Line 2**: `  - build` - Defines 'build' stage (valid)
- **Line 3**: `  - test` - Defines 'test' stage (valid)
- **Line 4**: `# 'deploy' stage not defined` - Missing stage definition
- **Line 6**: `deploy-job:` - Job name (valid)
- **Line 7**: `  stage: deploy` - **ERROR**: References undefined stage
- **GitLab Behavior**: Pipeline validation fails immediately
- **Error Message**: "stage 'deploy' is not defined in stages"

**✅ Correct Implementation:**
```yaml
# Right - all referenced stages properly defined
stages:
  - build
  - test
  - deploy  # Now 'deploy' stage is defined

deploy-job:
  stage: deploy  # Valid reference to defined stage
  script:
    - echo "deploying application to production"
```

**Structure Success Analysis:**
- **Line 2**: `  - build` - First stage in execution sequence
- **Line 3**: `  - test` - Second stage in execution sequence  
- **Line 4**: `  - deploy` - Third stage in execution sequence
- **Line 6**: `deploy-job:` - Job identifier
- **Line 7**: `  stage: deploy` - Valid stage reference
- **Line 8**: `  script:` - Required executable section
- **Line 9**: `    - echo "deploying..."` - Deployment command
- **GitLab Behavior**: Pipeline validates and executes successfully

**Business Impact of Proper Structure:**
- **Execution Reliability**: Proper stages ensure predictable job ordering
- **Parallel Efficiency**: Well-defined stages enable optimal parallelization
- **Debugging Clarity**: Clear structure simplifies troubleshooting
- **Team Understanding**: Explicit stages communicate pipeline flow
- **Maintenance Ease**: Structured pipelines are easier to modify and extend

### **Systematic Troubleshooting Theory**

**Debugging Methodology:**
1. **Error Classification**: Identify error type (syntax, configuration, runtime)
2. **Root Cause Analysis**: Trace error to specific line or configuration
3. **Solution Application**: Apply targeted fix based on error pattern
4. **Validation Testing**: Verify fix resolves issue without side effects
5. **Prevention Implementation**: Add safeguards to prevent recurrence

**Error Prevention Strategy:**
- **Validation Tools**: Use YAML linters and GitLab CI lint API
- **Template Usage**: Standardize common patterns to reduce errors
- **Code Review**: Implement peer review for pipeline changes
- **Testing**: Use feature branches to test pipeline changes safely
- **Documentation**: Maintain clear examples and troubleshooting guides

This comprehensive approach transforms common mistakes from frustrating roadblocks into learning opportunities that build expertise and confidence in GitLab CI/CD implementation.

**✅ Correct Way:**
```yaml
# Right - consistent spaces only
job1:
  script:
    - echo "hello"  # 2 spaces
    - echo "world"  # 2 spaces
```

**🔍 How to Fix:**
- Use only spaces, never tabs
- Be consistent with indentation (2 or 4 spaces)
- Use a YAML validator or editor with YAML support

**⚠️ Warning Signs:**
- Error: "mapping values are not allowed here"
- Error: "could not find expected ':'"

---

### **2. Missing `script:` Section** 👷‍♂️

**❌ Common Mistake:**
```yaml
# Wrong - no script section
test-job:
  stage: test
  image: node:18
  # Missing script section!
```

**✅ Correct Way:**
```yaml
# Right - every job needs a script
test-job:
  stage: test
  image: node:18
  script:
    - npm test
```

**🔍 How to Fix:**
- Every job MUST have a `script:` section
- Even if it's just `- echo "placeholder"`

**⚠️ Warning Signs:**
- Error: "jobs:job config should contain either a script or trigger"

---

### **3. Using Undefined Stages** 🎭

**❌ Common Mistake:**
```yaml
# Wrong - using stage that doesn't exist
stages:
  - build
  - test

deploy-job:
  stage: deploy  # This stage was never defined!
  script:
    - echo "deploying"
```

**✅ Correct Way:**
```yaml
# Right - define all stages first
stages:
  - build
  - test
  - deploy  # Now it's defined

deploy-job:
  stage: deploy  # This works now
  script:
    - echo "deploying"
```

**🔍 How to Fix:**
- Always define stages at the top of your `.gitlab-ci.yml`
- Make sure job stages match defined stages exactly

**⚠️ Warning Signs:**
- Error: "stage 'deploy' is not defined"

---

### **4. Incorrect Cache Configuration** 💾

**❌ Common Mistake:**
```yaml
# Wrong - cache without proper key
job1:
  cache:
    - node_modules/  # Missing 'paths:' and 'key:'
  script:
    - npm install
```

**✅ Correct Way:**
```yaml
# Right - proper cache structure
job1:
  cache:
    key: "$CI_COMMIT_REF_SLUG"
    paths:
      - node_modules/
  script:
    - npm install
```

**🔍 How to Fix:**
- Always include `key:` and `paths:` in cache configuration
- Use meaningful cache keys like branch name or file hash

**⚠️ Warning Signs:**
- Cache not working (always downloading dependencies)
- Error: "cache config should be a hash"

---

### **5. Hardcoding Secrets in Code** 🔒

**❌ Common Mistake:**
```yaml
# Wrong - secret exposed in code
deploy:
  script:
    - kubectl config set-credentials user --token=abc123secret
```

**✅ Correct Way:**
```yaml
# Right - use GitLab CI/CD variables
deploy:
  script:
    - kubectl config set-credentials user --token=$KUBE_TOKEN
```

**🔍 How to Fix:**
- Use GitLab CI/CD variables for all secrets
- Mark variables as "Protected" and "Masked"
- Never commit secrets to your repository

**⚠️ Warning Signs:**
- Secrets visible in job logs
- Security scanner alerts about exposed credentials

---

### **6. Not Using Specific Image Tags** 🏷️

**❌ Common Mistake:**
```yaml
# Wrong - using 'latest' tag
job1:
  image: node:latest  # Unpredictable, changes over time
  script:
    - npm test
```

**✅ Correct Way:**
```yaml
# Right - specific version
job1:
  image: node:18.17.1  # Predictable, consistent
  script:
    - npm test
```

**🔍 How to Fix:**
- Always use specific version tags
- Update versions intentionally, not accidentally

**⚠️ Warning Signs:**
- Jobs that worked yesterday suddenly fail
- Inconsistent behavior between pipeline runs

---

### **7. Artifacts Expiring Too Soon** 📦

**❌ Common Mistake:**
```yaml
# Wrong - artifacts expire too quickly
build:
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour  # Too short for most use cases
```

**✅ Correct Way:**
```yaml
# Right - reasonable expiration
build:
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week  # Enough time for debugging
```

**🔍 How to Fix:**
- Set appropriate expiration times based on usage
- Use longer times for important artifacts
- Consider storage costs vs. convenience

**⚠️ Warning Signs:**
- Artifacts missing when you need them for debugging
- Deployment jobs failing because build artifacts expired

---

### **8. Jobs Running on Wrong Branches** 🌿

**❌ Common Mistake:**
```yaml
# Wrong - production job runs on all branches
deploy-production:
  script:
    - deploy-to-production.sh
  # No branch restrictions!
```

**✅ Correct Way:**
```yaml
# Right - restricted to main branch only
deploy-production:
  script:
    - deploy-to-production.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

**🔍 How to Fix:**
- Use `rules:` or `only:` to control when jobs run
- Be especially careful with deployment jobs
- Test branch restrictions with feature branches

**⚠️ Warning Signs:**
- Production deployments from feature branches
- Unnecessary job runs wasting resources

---

### **9. Not Handling Job Failures Properly** ❌

**❌ Common Mistake:**
```yaml
# Wrong - ignoring potential failures
deploy:
  script:
    - risky-command-that-might-fail
    - important-cleanup-command  # This won't run if above fails
```

**✅ Correct Way:**
```yaml
# Right - proper error handling
deploy:
  script:
    - risky-command-that-might-fail || echo "Command failed but continuing"
    - important-cleanup-command
  after_script:
    - cleanup-script.sh  # Always runs, even if job fails
```

**🔍 How to Fix:**
- Use `after_script:` for cleanup that must always run
- Handle expected failures with `|| true` or proper error checking
- Set appropriate `allow_failure:` settings

**⚠️ Warning Signs:**
- Resources not cleaned up after failed jobs
- Inconsistent environment state after failures

---

### **10. Inefficient Parallel Job Distribution** ⚡

**❌ Common Mistake:**
```yaml
# Wrong - uneven test distribution
test:
  parallel: 4
  script:
    - npm test  # All tests run on all 4 jobs (wasteful)
```

**✅ Correct Way:**
```yaml
# Right - proper test splitting
test:
  parallel: 4
  script:
    - npm test -- --shard=$CI_NODE_INDEX/$CI_NODE_TOTAL
```

**🔍 How to Fix:**
- Use proper test splitting for parallel jobs
- Distribute work evenly across parallel instances
- Monitor job durations to optimize distribution

**⚠️ Warning Signs:**
- Some parallel jobs finish much faster than others
- Tests running multiple times unnecessarily

---

## 🔧 **Troubleshooting Common Issues**

### **Issue 1: Pipeline Stuck in "Pending" Status** ⏳

**🔍 Symptoms:**
- Jobs show "pending" for long periods
- No runner picking up jobs

**🛠️ Troubleshooting Steps:**
1. **Check Runner Availability:**
   ```bash
   # In GitLab UI: Settings > CI/CD > Runners
   # Look for active runners with green dot
   ```

2. **Check Runner Tags:**
   ```yaml
   # If your job has tags, make sure runners have matching tags
   job1:
     tags:
       - docker  # Runner must have 'docker' tag
     script:
       - echo "test"
   ```

3. **Check Runner Capacity:**
   - Runners might be busy with other jobs
   - Consider adding more runners or increasing concurrent jobs

**✅ Solutions:**
- Register additional runners
- Remove unnecessary tags
- Increase runner concurrent job limit

---

### **Issue 2: "Permission Denied" Errors** 🚫

**🔍 Symptoms:**
- Cannot access files or directories
- Docker permission errors

**🛠️ Troubleshooting Steps:**
1. **Check File Permissions:**
   ```yaml
   debug-permissions:
     script:
       - ls -la  # Check file permissions
       - whoami  # Check current user
       - id      # Check user ID and groups
   ```

2. **Fix Docker Permissions:**
   ```yaml
   # Add user to docker group or use sudo
   before_script:
     - sudo usermod -aG docker $USER
     # OR use docker with sudo
     - sudo docker build .
   ```

**✅ Solutions:**
- Use `chmod +x script.sh` to make scripts executable
- Run containers with appropriate user permissions
- Use `sudo` when necessary (but avoid in production)

---

### **Issue 3: Cache Not Working** 💾

**🔍 Symptoms:**
- Dependencies downloaded every time
- Build times not improving

**🛠️ Troubleshooting Steps:**
1. **Check Cache Key:**
   ```yaml
   # Debug cache key
   debug-cache:
     script:
       - echo "Cache key: $CI_COMMIT_REF_SLUG"
       - ls -la .cache/ || echo "No cache directory"
   ```

2. **Verify Cache Paths:**
   ```yaml
   # Make sure cached directories exist
   job1:
     cache:
       key: "$CI_COMMIT_REF_SLUG"
       paths:
         - node_modules/  # This directory must exist
     script:
       - npm install  # This creates node_modules/
   ```

**✅ Solutions:**
- Use consistent cache keys across jobs
- Ensure cached directories are created by your scripts
- Check runner cache storage configuration

---

### **Issue 4: Environment Variables Not Working** 🔧

**🔍 Symptoms:**
- Variables showing as empty
- Configuration not applied

**🛠️ Troubleshooting Steps:**
1. **Debug Variables:**
   ```yaml
   debug-vars:
     script:
       - echo "All environment variables:"
       - env | sort
       - echo "Specific variable: $MY_VARIABLE"
   ```

2. **Check Variable Scope:**
   ```yaml
   # Global variables
   variables:
     GLOBAL_VAR: "available everywhere"
   
   # Job-specific variables
   job1:
     variables:
       JOB_VAR: "only in this job"
     script:
       - echo $GLOBAL_VAR  # Works
       - echo $JOB_VAR     # Works
   
   job2:
     script:
       - echo $GLOBAL_VAR  # Works
       - echo $JOB_VAR     # Empty! Not available here
   ```

**✅ Solutions:**
- Check variable names for typos
- Verify variable scope (global vs job-specific)
- Ensure variables are not masked when you need to see them

---

### **Issue 5: Docker Build Failures** 🐳

**🔍 Symptoms:**
- Docker commands fail
- Image build errors

**🛠️ Troubleshooting Steps:**
1. **Check Docker Service:**
   ```yaml
   build-docker:
     image: docker:24.0.5
     services:
       - docker:24.0.5-dind  # Docker-in-Docker service
     script:
       - docker info  # Check if Docker is available
       - docker build .
   ```

2. **Debug Dockerfile:**
   ```yaml
   debug-dockerfile:
     script:
       - cat Dockerfile  # Show Dockerfile contents
       - docker build --no-cache .  # Build without cache
   ```

**✅ Solutions:**
- Add `docker:dind` service for Docker builds
- Check Dockerfile syntax
- Use `--no-cache` to debug caching issues

---

## 🎯 **Prevention Strategies**

### **1. Use Pipeline Validation** ✅
```yaml
# Add validation job
validate-pipeline:
  stage: .pre
  script:
    - echo "Validating pipeline configuration"
    - gitlab-ci-lint .gitlab-ci.yml  # If available
```

### **2. Implement Gradual Rollouts** 🚀
```yaml
# Test changes on feature branches first
deploy-staging:
  script:
    - deploy-to-staging.sh
  rules:
    - if: $CI_COMMIT_BRANCH != "main"

deploy-production:
  script:
    - deploy-to-production.sh
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual  # Require manual approval
```

### **3. Monitor Pipeline Performance** 📊
```yaml
# Add performance monitoring
monitor-performance:
  stage: .post
  script:
    - echo "Pipeline duration: $CI_PIPELINE_DURATION seconds"
    - echo "Job count: $(curl -s $CI_API_V4_URL/projects/$CI_PROJECT_ID/pipelines/$CI_PIPELINE_ID/jobs | jq length)"
```

---

## 🆘 **Emergency Procedures**

### **Pipeline Completely Broken** 🚨
1. **Immediate Actions:**
   - Revert to last known good `.gitlab-ci.yml`
   - Push revert commit to main branch
   - Disable Auto DevOps if it's interfering

2. **Investigation:**
   - Check recent commits for pipeline changes
   - Review job logs for error messages
   - Test changes in feature branch first

### **Production Deployment Failed** 💥
1. **Immediate Actions:**
   - Check if rollback is possible
   - Verify production health status
   - Communicate with stakeholders

2. **Recovery Steps:**
   ```yaml
   # Emergency rollback job
   emergency-rollback:
     stage: deploy
     script:
       - kubectl rollout undo deployment/myapp
       - kubectl rollout status deployment/myapp
     when: manual
     only:
       - main
   ```

---

## 📚 **Additional Resources**

### **Debugging Tools** 🔍
- **GitLab CI Lint**: Validate YAML syntax
- **Pipeline Editor**: Visual pipeline editing
- **Job Logs**: Detailed execution information
- **Runner Logs**: System-level debugging

### **Best Practices** ✨
- Start simple, add complexity gradually
- Test pipeline changes in feature branches
- Use descriptive job and stage names
- Document complex pipeline logic
- Regular pipeline performance reviews

**🎯 Remember**: Every expert was once a beginner who made these same mistakes. Learn from them, and you'll become proficient much faster!
