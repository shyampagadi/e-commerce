# Environment Management - Complete Theory & Implementation Guide

## 🎯 **Environment Management Theory Foundation**

### **Understanding Environment Architecture**
**Theory**: Environment management in CI/CD involves creating isolated, consistent deployment targets that mirror production characteristics while enabling safe testing and gradual rollout strategies.

**Environment Hierarchy Theory:**
- **Development**: Feature development and initial testing
- **Staging**: Production-like environment for integration testing
- **Production**: Live environment serving real users
- **Review Apps**: Temporary environments for merge request validation

**Business Impact Theory:**
- **Risk Mitigation**: Proper environments prevent 90% of production incidents
- **Quality Assurance**: Staging environments catch 85% of integration issues
- **Cost Optimization**: Environment-specific resources reduce infrastructure costs by 40-60%
- **Compliance**: Regulatory requirements demand environment separation and audit trails

---

## 🔧 **Level 1: Basic Environment Configuration Theory & Implementation**

### **Workflow Rules Architecture**

**Theory Background:**
GitLab workflow rules control when entire pipelines execute based on conditions like branch names, pipeline sources, and custom variables. This enables environment-specific behavior without code duplication.

**Conditional Execution Theory:**
- **Branch-based Logic**: Different branches trigger different environments
- **Source-based Logic**: Pipeline source (push, MR, schedule) determines behavior
- **Variable-based Logic**: Custom conditions enable complex deployment strategies
- **Cost Optimization**: Prevents unnecessary pipeline executions

### **Basic Environment Setup**

**Learning Example - Progressive Environment Implementation:**

**Level 1: Simple Environment Rules (Beginner)**
```yaml
# Basic environment-based workflow
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      variables:
        ENVIRONMENT: "production"
    - if: $CI_COMMIT_BRANCH == "develop"
      variables:
        ENVIRONMENT: "staging"
```

**Line-by-Line Analysis:**
- **Line 1**: `workflow:` - Global pipeline control section
- **Line 2**: `  rules:` - Conditional execution logic array
- **Line 3**: `    - if: $CI_COMMIT_BRANCH == "main"` - Condition for main branch
- **Line 4**: `      variables:` - Variables set when condition matches
- **Line 5**: `        ENVIRONMENT: "production"` - Environment variable assignment
- **Theory**: Workflow rules execute before any jobs, controlling entire pipeline behavior

**Level 2: Comprehensive Environment Rules (Intermediate)**
```yaml
# Complete environment workflow with all scenarios
workflow:
  rules:
    # Production environment (main branch)
    - if: $CI_COMMIT_BRANCH == "main"
      variables:
        ENVIRONMENT: "production"
        DEPLOY_STRATEGY: "blue-green"
        SECURITY_LEVEL: "strict"
        
    # Staging environment (develop branch)
    - if: $CI_COMMIT_BRANCH == "develop"
      variables:
        ENVIRONMENT: "staging"
        DEPLOY_STRATEGY: "rolling"
        SECURITY_LEVEL: "standard"
        
    # Review environment (merge requests)
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      variables:
        ENVIRONMENT: "review"
        DEPLOY_STRATEGY: "direct"
        SECURITY_LEVEL: "basic"
        
    # Development environment (feature branches)
    - if: $CI_COMMIT_BRANCH =~ /^feature\/.*/
      variables:
        ENVIRONMENT: "development"
        DEPLOY_STRATEGY: "direct"
        SECURITY_LEVEL: "basic"
        
    # Hotfix environment (hotfix branches)
    - if: $CI_COMMIT_BRANCH =~ /^hotfix\/.*/
      variables:
        ENVIRONMENT: "hotfix"
        DEPLOY_STRATEGY: "canary"
        SECURITY_LEVEL: "strict"
```

**Advanced Configuration Analysis:**

**`workflow:`**
- **What it does**: Controls when entire pipelines run based on conditions
- **Theory**: Global pipeline gate that prevents unnecessary executions
- **Business value**: Reduces CI/CD costs by 30-50% through selective execution
- **Execution**: Evaluated before any jobs are created or scheduled

**`rules:`**
- **What it does**: Array of conditional statements for pipeline execution
- **Theory**: First matching rule determines pipeline behavior
- **Logic**: Rules evaluated in order, first match wins
- **Flexibility**: Supports complex boolean logic and pattern matching

**`if: $CI_COMMIT_BRANCH == "main"`**
- **What it does**: Triggers pipeline only for main branch commits
- **Theory**: Branch-based conditional execution for production deployments
- **Security**: Ensures production deployments only from stable branch
- **Compliance**: Meets audit requirements for production change control
- **Variable**: `$CI_COMMIT_BRANCH` is GitLab predefined variable

**`variables: ENVIRONMENT: "production"`**
- **What it does**: Sets environment variable for all jobs in pipeline
- **Theory**: Pipeline-wide configuration without job-level duplication
- **Usage**: Jobs access via `$ENVIRONMENT` variable for conditional behavior
- **Scope**: Available to all jobs, scripts, and deployment configurations
- **Override**: Job-level variables can override pipeline-level variables

**`if: $CI_PIPELINE_SOURCE == "merge_request_event"`**
- **What it does**: Creates review environment for merge requests
- **Theory**: Temporary environments for code review and testing
- **Business value**: Enables stakeholder review of actual running application
- **Collaboration**: Non-technical users can test changes before merge
- **Cleanup**: Review environments typically auto-delete after merge/close

**`if: $CI_COMMIT_BRANCH =~ /^feature\/.*/`**
- **What it does**: Matches feature branches using regular expression
- **Theory**: Pattern matching enables flexible branch naming conventions
- **Regex**: `^feature\/.*` matches any branch starting with "feature/"
- **Examples**: Matches "feature/login", "feature/payment", "feature/user-profile"
- **Flexibility**: Supports team branching strategies and naming conventions

### **Environment-Specific Job Configuration**

**Level 3: Production Environment Jobs (Expert)**
```yaml
# Development deployment with manual trigger
deploy-development:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to development environment"
    - apk add --no-cache curl kubectl
    - kubectl config use-context development
    - kubectl apply -f k8s/development/ --namespace=dev
    - kubectl rollout status deployment/app --namespace=dev
  environment:
    name: development/$CI_COMMIT_REF_SLUG
    url: https://dev-$CI_COMMIT_REF_SLUG.myapp.com
    on_stop: cleanup-development
  rules:
    - if: $CI_COMMIT_BRANCH != "main" && $CI_COMMIT_BRANCH != "develop"
      when: manual
  artifacts:
    reports:
      dotenv: deploy.env

# Staging deployment with automatic trigger
deploy-staging:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to staging environment"
    - apk add --no-cache curl kubectl
    - kubectl config use-context staging
    - kubectl apply -f k8s/staging/ --namespace=staging
    - kubectl rollout status deployment/app --namespace=staging
    - curl -f https://staging.myapp.com/health || exit 1
  environment:
    name: staging
    url: https://staging.myapp.com
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"
      when: on_success
  dependencies:
    - build-application
    - run-tests

# Production deployment with manual approval
deploy-production:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploying to production environment"
    - apk add --no-cache curl kubectl
    - kubectl config use-context production
    - kubectl apply -f k8s/production/ --namespace=production
    - kubectl rollout status deployment/app --namespace=production
    - kubectl get pods --namespace=production
    - curl -f https://myapp.com/health || exit 1
  environment:
    name: production
    url: https://myapp.com
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
  dependencies:
    - build-application
    - run-tests
    - security-scan
  before_script:
    - echo "Production deployment requires manual approval"
    - echo "Deploying commit: $CI_COMMIT_SHA"
    - echo "Deployed by: $GITLAB_USER_NAME"

# Environment cleanup job
cleanup-development:
  stage: cleanup
  image: alpine:latest
  script:
    - echo "Cleaning up development environment"
    - apk add --no-cache kubectl
    - kubectl config use-context development
    - kubectl delete namespace dev-$CI_COMMIT_REF_SLUG --ignore-not-found=true
  environment:
    name: development/$CI_COMMIT_REF_SLUG
    action: stop
  rules:
    - if: $CI_COMMIT_BRANCH != "main" && $CI_COMMIT_BRANCH != "develop"
      when: manual
```

**Environment Job Configuration Analysis:**

**`environment: name: development/$CI_COMMIT_REF_SLUG`**
- **What it does**: Creates dynamic environment name using branch slug
- **Theory**: Each branch gets isolated environment for parallel development
- **Variable**: `$CI_COMMIT_REF_SLUG` is sanitized branch name (safe for URLs)
- **Example**: Branch "feature/user-login" becomes "development/feature-user-login"
- **Isolation**: Prevents conflicts between different feature developments

**`environment: url: https://dev-$CI_COMMIT_REF_SLUG.myapp.com`**
- **What it does**: Provides direct link to deployed environment
- **Theory**: Dynamic URLs enable easy access to branch-specific deployments
- **Business value**: Stakeholders can test specific features without setup
- **Convenience**: One-click access from GitLab environment page
- **Testing**: Enables parallel testing of multiple features

**`environment: on_stop: cleanup-development`**
- **What it does**: Defines job to run when environment is stopped
- **Theory**: Automatic cleanup prevents resource waste and cost accumulation
- **Trigger**: Executes when environment stop button clicked in GitLab
- **Resource management**: Deletes Kubernetes namespaces, cloud resources
- **Cost optimization**: Prevents abandoned environments from consuming resources

**`rules: - if: $CI_COMMIT_BRANCH != "main" && $CI_COMMIT_BRANCH != "develop"`**
- **What it does**: Runs for feature branches (excludes main and develop)
- **Theory**: Boolean logic with AND operator for complex conditions
- **Logic**: NOT main AND NOT develop = feature branches only
- **Purpose**: Feature branches deploy to development environment
- **Safety**: Prevents accidental staging/production deployments from features

**`when: manual`**
- **What it does**: Requires manual approval before job execution
- **Theory**: Human gate for sensitive operations or cost control
- **Safety**: Prevents automatic deployments to expensive environments
- **Control**: Developers choose when to deploy for testing
- **Cost management**: Avoids unnecessary environment creation during development

**`when: on_success`**
- **What it does**: Automatically runs when all previous jobs succeed
- **Theory**: Conditional automation based on pipeline state
- **Efficiency**: Staging deployments happen automatically for integration testing
- **Quality gate**: Only successful builds reach staging environment
- **Feedback loop**: Faster integration testing through automation

**`dependencies:`**
- **What it does**: Specifies which jobs must complete before this job runs
- **Theory**: Explicit dependency management beyond stage-based ordering
- **Artifacts**: Downloads artifacts from specified dependency jobs
- **Validation**: Ensures required build outputs and test results are available
- **Reliability**: Prevents deployments without proper validation

**`before_script:`**
- **What it does**: Commands executed before main script section
- **Theory**: Common setup tasks for job preparation
- **Logging**: Audit trail for production deployments
- **Context**: Provides deployment metadata for troubleshooting
- **Compliance**: Records who deployed what and when

**`environment: action: stop`**
- **What it does**: Marks job as environment cleanup action
- **Theory**: Special job type for resource deallocation
- **Lifecycle**: Completes environment lifecycle management
- **Integration**: Links with GitLab environment tracking
- **Automation**: Enables programmatic environment cleanup

**Business Impact of Comprehensive Environment Management:**
- **Risk Mitigation**: Proper environment isolation prevents 90% of production incidents
- **Cost Optimization**: Dynamic environments reduce infrastructure costs by 40-60%
- **Development Velocity**: Parallel feature environments increase team productivity by 50%
- **Quality Assurance**: Staging validation catches 85% of integration issues
- **Compliance**: Audit trails and approval gates meet regulatory requirements
- **Operational Excellence**: Automated cleanup prevents resource waste and cost overruns
        ENVIRONMENT: "external"

variables:
  # Default variables
  DEFAULT_ENVIRONMENT: "development"
  BUILD_TYPE: "standard"

stages:
  - validate
  - build
  - test
  - security
  - deploy
  - notify
```

### Advanced Trigger Conditions
```yaml
# Complex conditional triggers
conditional-job:
  stage: build
  script:
    - echo "Running conditional job"
  rules:
    # Multiple conditions with AND logic
    - if: $CI_COMMIT_BRANCH == "main" && $CI_COMMIT_MESSAGE !~ /\[skip ci\]/
      variables:
        BUILD_TYPE: "production"
        
    # OR logic using multiple rules
    - if: $CI_COMMIT_BRANCH == "develop"
      variables:
        BUILD_TYPE: "staging"
    - if: $CI_COMMIT_BRANCH =~ /^release\/.*/
      variables:
        BUILD_TYPE: "release"
        
    # Exclude certain conditions
    - if: $CI_COMMIT_MESSAGE =~ /\[skip build\]/
      when: never
      
    # File-based triggers
    - changes:
        - "src/**/*"
        - "package*.json"
        - "requirements.txt"
      when: always
      
    # Time-based conditions
    - if: $CI_PIPELINE_SOURCE == "schedule" && $SCHEDULE_TYPE == "nightly"
      variables:
        BUILD_TYPE: "nightly"
        
    # User-based conditions
    - if: $GITLAB_USER_LOGIN == "admin" || $GITLAB_USER_LOGIN == "devops-team"
      when: manual
      allow_failure: false
```

## File Change Detection

### Changes-Based Triggers
```yaml
# Frontend build only when frontend files change
build-frontend:
  stage: build
  script:
    - npm ci
    - npm run build:frontend
  rules:
    - changes:
        - "frontend/**/*"
        - "package*.json"
        - "webpack.config.js"
        - ".babelrc"
      when: always
    - when: never
  artifacts:
    paths:
      - dist/frontend/
    expire_in: 1 hour

# Backend build only when backend files change
build-backend:
  stage: build
  script:
    - pip install -r requirements.txt
    - python setup.py build
  rules:
    - changes:
        - "backend/**/*"
        - "requirements.txt"
        - "setup.py"
        - "pyproject.toml"
      when: always
    - when: never
  artifacts:
    paths:
      - dist/backend/
    expire_in: 1 hour

# Infrastructure deployment on infrastructure changes
deploy-infrastructure:
  stage: deploy
  script:
    - terraform plan
    - terraform apply -auto-approve
  rules:
    - changes:
        - "terraform/**/*"
        - "*.tf"
        - "*.tfvars"
      when: manual
      allow_failure: false
    - when: never
  environment:
    name: infrastructure
    action: prepare

# Documentation deployment
deploy-docs:
  stage: deploy
  script:
    - mkdocs build
    - aws s3 sync site/ s3://docs-bucket/
  rules:
    - changes:
        - "docs/**/*"
        - "mkdocs.yml"
        - "*.md"
      when: always
    - when: never
  environment:
    name: documentation
    url: https://docs.example.com
```

### Complex Change Detection
```yaml
# Multi-component change detection
detect-changes:
  stage: validate
  script:
    - echo "Detecting changes..."
  rules:
    - changes:
        - "frontend/**/*"
      variables:
        FRONTEND_CHANGED: "true"
    - changes:
        - "backend/**/*"
      variables:
        BACKEND_CHANGED: "true"
    - changes:
        - "mobile/**/*"
      variables:
        MOBILE_CHANGED: "true"
    - changes:
        - "infrastructure/**/*"
      variables:
        INFRA_CHANGED: "true"

# Conditional builds based on changes
build-if-changed:
  stage: build
  script:
    - |
      if [ "$FRONTEND_CHANGED" = "true" ]; then
        echo "Building frontend..."
        npm run build:frontend
      fi
      if [ "$BACKEND_CHANGED" = "true" ]; then
        echo "Building backend..."
        python setup.py build
      fi
      if [ "$MOBILE_CHANGED" = "true" ]; then
        echo "Building mobile..."
        flutter build apk
      fi
  needs: ["detect-changes"]
```

## Branch-Based Workflows

### GitFlow Integration
```yaml
# GitFlow-based pipeline rules
variables:
  # Branch-specific variables
  MAIN_BRANCH: "main"
  DEVELOP_BRANCH: "develop"

# Feature branch workflow
feature-validation:
  stage: validate
  script:
    - echo "Validating feature branch"
    - npm run lint
    - npm run test:unit
  rules:
    - if: $CI_COMMIT_BRANCH =~ /^feature\/.*/
      when: always
    - when: never

# Develop branch integration
integration-tests:
  stage: test
  script:
    - echo "Running integration tests"
    - npm run test:integration
  rules:
    - if: $CI_COMMIT_BRANCH == $DEVELOP_BRANCH
      when: always
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == $DEVELOP_BRANCH
      when: always
    - when: never

# Release branch preparation
prepare-release:
  stage: build
  script:
    - echo "Preparing release"
    - npm run build:production
    - npm run test:e2e
  rules:
    - if: $CI_COMMIT_BRANCH =~ /^release\/.*/
      when: always
    - when: never
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

# Hotfix deployment
hotfix-deploy:
  stage: deploy
  script:
    - echo "Deploying hotfix"
    - kubectl apply -f k8s/production/
  rules:
    - if: $CI_COMMIT_BRANCH =~ /^hotfix\/.*/
      when: manual
      allow_failure: false
    - when: never
  environment:
    name: production
    url: https://app.example.com

# Main branch production deployment
production-deploy:
  stage: deploy
  script:
    - echo "Deploying to production"
    - kubectl apply -f k8s/production/
  rules:
    - if: $CI_COMMIT_BRANCH == $MAIN_BRANCH
      when: manual
      allow_failure: false
    - when: never
  environment:
    name: production
    url: https://app.example.com
```

### Environment-Specific Rules
```yaml
# Environment-based deployment rules
deploy-development:
  stage: deploy
  script:
    - echo "Deploying to development"
    - kubectl apply -f k8s/development/
  rules:
    - if: $CI_COMMIT_BRANCH =~ /^feature\/.*/
      when: always
    - if: $CI_COMMIT_BRANCH == "develop"
      when: always
    - when: never
  environment:
    name: development-$CI_COMMIT_REF_SLUG
    url: https://dev-$CI_COMMIT_REF_SLUG.example.com
    on_stop: cleanup-development

cleanup-development:
  stage: deploy
  script:
    - echo "Cleaning up development environment"
    - kubectl delete namespace dev-$CI_COMMIT_REF_SLUG
  rules:
    - if: $CI_COMMIT_BRANCH =~ /^feature\/.*/
      when: manual
    - when: never
  environment:
    name: development-$CI_COMMIT_REF_SLUG
    action: stop

deploy-staging:
  stage: deploy
  script:
    - echo "Deploying to staging"
    - kubectl apply -f k8s/staging/
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"
      when: always
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "main"
      when: always
    - when: never
  environment:
    name: staging
    url: https://staging.example.com

deploy-production:
  stage: deploy
  script:
    - echo "Deploying to production"
    - kubectl apply -f k8s/production/
  rules:
    - if: $CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG
      when: manual
      allow_failure: false
    - when: never
  environment:
    name: production
    url: https://app.example.com
```

## Scheduled Pipelines

### Cron-Based Scheduling
```yaml
# Scheduled pipeline configurations
# Configure in GitLab UI: CI/CD > Schedules

# Nightly build and test
nightly-build:
  stage: build
  script:
    - echo "Running nightly build"
    - npm run build:production
    - npm run test:full-suite
    - npm run test:performance
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule" && $SCHEDULE_TYPE == "nightly"
      when: always
    - when: never
  artifacts:
    paths:
      - dist/
      - test-reports/
    expire_in: 1 week

# Weekly security scan
security-scan:
  stage: security
  script:
    - echo "Running weekly security scan"
    - npm audit --audit-level high
    - docker run --rm -v $(pwd):/app clair-scanner
    - trivy fs .
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule" && $SCHEDULE_TYPE == "security"
      when: always
    - when: never
  artifacts:
    reports:
      sast: security-report.json
    expire_in: 1 month

# Monthly dependency update
dependency-update:
  stage: build
  script:
    - echo "Updating dependencies"
    - npm update
    - pip-review --auto
    - git add .
    - git commit -m "chore: update dependencies [skip ci]"
    - git push origin $CI_COMMIT_BRANCH
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule" && $SCHEDULE_TYPE == "dependency-update"
      when: always
    - when: never

# Database backup
database-backup:
  stage: deploy
  script:
    - echo "Creating database backup"
    - pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
    - aws s3 cp backup-$(date +%Y%m%d).sql s3://backups/
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule" && $SCHEDULE_TYPE == "backup"
      when: always
    - when: never
```

## Manual Triggers and Approvals

### Manual Job Configuration
```yaml
# Manual deployment with approval
manual-production-deploy:
  stage: deploy
  script:
    - echo "Deploying to production"
    - kubectl apply -f k8s/production/
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
      allow_failure: false
    - when: never
  environment:
    name: production
    url: https://app.example.com
  before_script:
    - echo "Production deployment requires manual approval"
    - echo "Deployment will affect live users"

# Manual rollback
rollback-production:
  stage: deploy
  script:
    - echo "Rolling back production deployment"
    - kubectl rollout undo deployment/app
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
      allow_failure: true
    - when: never
  environment:
    name: production
    url: https://app.example.com

# Manual cleanup
cleanup-resources:
  stage: deploy
  script:
    - echo "Cleaning up unused resources"
    - kubectl delete pods --field-selector=status.phase=Succeeded
    - docker system prune -f
  rules:
    - when: manual
      allow_failure: true
```

### Conditional Manual Jobs
```yaml
# Manual job with conditions
conditional-manual-deploy:
  stage: deploy
  script:
    - echo "Conditional manual deployment"
  rules:
    # Manual for main branch
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
      allow_failure: false
      
    # Automatic for develop branch
    - if: $CI_COMMIT_BRANCH == "develop"
      when: always
      
    # Manual for feature branches with label
    - if: $CI_COMMIT_BRANCH =~ /^feature\/.*/ && $CI_MERGE_REQUEST_LABELS =~ /deploy/
      when: manual
      allow_failure: true
      
    # Never run otherwise
    - when: never
```

## External Triggers

### API Triggers
```yaml
# API-triggered pipeline
api-triggered-job:
  stage: build
  script:
    - echo "Pipeline triggered via API"
    - echo "Trigger token: $CI_JOB_TOKEN"
    - echo "Trigger variables: $TRIGGER_PAYLOAD"
  rules:
    - if: $CI_PIPELINE_SOURCE == "trigger"
      when: always
    - when: never
  variables:
    TRIGGERED_BY: "external-api"

# Webhook response job
webhook-response:
  stage: notify
  script:
    - |
      curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d '{
          "status": "completed",
          "pipeline_id": "'$CI_PIPELINE_ID'",
          "commit_sha": "'$CI_COMMIT_SHA'",
          "branch": "'$CI_COMMIT_BRANCH'"
        }'
  rules:
    - if: $CI_PIPELINE_SOURCE == "trigger"
      when: always
    - when: never
```

### Cross-Project Triggers
```yaml
# Trigger downstream project
trigger-downstream:
  stage: deploy
  trigger:
    project: group/downstream-project
    branch: main
    strategy: depend
  variables:
    UPSTREAM_COMMIT: $CI_COMMIT_SHA
    UPSTREAM_BRANCH: $CI_COMMIT_BRANCH
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: always
    - when: never

# Multi-project trigger
trigger-multiple-projects:
  stage: deploy
  trigger:
    - project: group/frontend-project
      branch: main
    - project: group/backend-project
      branch: main
    - project: group/mobile-project
      branch: main
  rules:
    - if: $CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG
      when: always
    - when: never
```

## Advanced Rule Patterns

### Complex Logic Rules
```yaml
# Advanced rule combinations
complex-deployment:
  stage: deploy
  script:
    - echo "Complex deployment logic"
  rules:
    # Production deployment: main branch + tag + manual
    - if: $CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/
      when: manual
      allow_failure: false
      variables:
        ENVIRONMENT: "production"
        REPLICAS: "5"
        
    # Staging deployment: develop branch + automatic
    - if: $CI_COMMIT_BRANCH == "develop" && $CI_COMMIT_MESSAGE !~ /\[skip deploy\]/
      when: always
      variables:
        ENVIRONMENT: "staging"
        REPLICAS: "2"
        
    # Review app: MR with deploy label
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" && $CI_MERGE_REQUEST_LABELS =~ /deploy/
      when: manual
      allow_failure: true
      variables:
        ENVIRONMENT: "review-$CI_MERGE_REQUEST_IID"
        REPLICAS: "1"
        
    # Hotfix: hotfix branch + manual + high priority
    - if: $CI_COMMIT_BRANCH =~ /^hotfix\/.*/ && $PRIORITY == "high"
      when: manual
      allow_failure: false
      variables:
        ENVIRONMENT: "production"
        REPLICAS: "5"
        HOTFIX: "true"
        
    # Never run for documentation changes
    - if: $CI_COMMIT_MESSAGE =~ /^docs:/
      when: never
      
    # Default: never run
    - when: never
```

## Hands-on Exercises

### Exercise 1: Branch-Based Workflow
Create a complete GitFlow workflow with:
- Feature branch validation
- Develop branch integration tests
- Release branch preparation
- Main branch production deployment
- Hotfix emergency deployment

### Exercise 2: Change Detection
Implement smart change detection for:
- Frontend/backend separation
- Infrastructure changes
- Documentation updates
- Configuration changes

### Exercise 3: Scheduled Operations
Set up scheduled pipelines for:
- Nightly builds and tests
- Weekly security scans
- Monthly dependency updates
- Daily database backups

## Summary

Pipeline triggers and rules in GitLab CI/CD enable:
- **Smart Execution**: Run pipelines only when needed
- **Branch Workflows**: GitFlow and custom branch strategies
- **Change Detection**: File-based conditional execution
- **Scheduled Operations**: Automated maintenance and monitoring
- **Manual Controls**: Approval workflows and manual triggers
- **External Integration**: API and webhook-driven pipelines

Master these trigger patterns to create efficient, intelligent CI/CD pipelines that respond appropriately to different events and conditions while minimizing unnecessary resource usage.
