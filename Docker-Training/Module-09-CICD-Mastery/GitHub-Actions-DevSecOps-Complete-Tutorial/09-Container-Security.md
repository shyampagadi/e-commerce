# Container Security - Complete Image Security Mastery

## 🎯 What You'll Master

**Industry Secret**: Container security vulnerabilities are the #1 attack vector in cloud environments, with 75% of organizations experiencing container security incidents. Master container security scanning and you'll prevent breaches that cost companies $4.45M on average.

## 🧠 Container Security Theory Deep Dive

### **Container Attack Surface Analysis**
```python
# Understanding the complete container attack surface
class ContainerAttackSurface:
    def __init__(self):
        self.attack_vectors = {
            'base_image_vulnerabilities': {
                'description': 'Vulnerabilities in the base OS image',
                'impact': 'System-level compromise',
                'examples': ['CVE-2021-44228 (Log4Shell)', 'CVE-2022-0847 (Dirty Pipe)'],
                'mitigation': 'Use minimal base images, regular updates'
            },
            'application_dependencies': {
                'description': 'Vulnerable libraries and packages',
                'impact': 'Application-level compromise',
                'examples': ['Vulnerable npm packages', 'Outdated Python libraries'],
                'mitigation': 'Dependency scanning, version pinning'
            },
            'configuration_issues': {
                'description': 'Insecure container configuration',
                'impact': 'Privilege escalation, data exposure',
                'examples': ['Running as root', 'Exposed ports', 'Mounted volumes'],
                'mitigation': 'Security policies, least privilege'
            },
            'runtime_vulnerabilities': {
                'description': 'Issues that appear during execution',
                'impact': 'Runtime compromise, data breach',
                'examples': ['Memory corruption', 'Race conditions'],
                'mitigation': 'Runtime monitoring, behavioral analysis'
            },
            'supply_chain_attacks': {
                'description': 'Compromised images or build process',
                'impact': 'Complete system compromise',
                'examples': ['Malicious base images', 'Compromised registries'],
                'mitigation': 'Image signing, trusted registries'
            }
        }
        
        self.security_layers = {
            'image_scanning': 'Scan images for known vulnerabilities',
            'configuration_analysis': 'Check container and Dockerfile security',
            'runtime_protection': 'Monitor container behavior at runtime',
            'network_security': 'Secure container networking',
            'secrets_management': 'Protect sensitive data in containers',
            'compliance_validation': 'Ensure regulatory compliance'
        }
    
    def assess_risk_level(self, vulnerabilities):
        """
        Calculate overall risk level based on vulnerabilities
        """
        risk_score = 0
        
        for vuln in vulnerabilities:
            severity_scores = {
                'CRITICAL': 10,
                'HIGH': 7,
                'MEDIUM': 4,
                'LOW': 1
            }
            risk_score += severity_scores.get(vuln['severity'], 0)
        
        if risk_score >= 20:
            return 'CRITICAL'
        elif risk_score >= 10:
            return 'HIGH'
        elif risk_score >= 5:
            return 'MEDIUM'
        else:
            return 'LOW'
```

### **Container Security Standards**
```yaml
Container_Security_Standards:
  CIS_Docker_Benchmark:
    Host_Configuration:
      - "Ensure a separate partition for containers"
      - "Ensure only trusted users are allowed to control Docker daemon"
      - "Ensure auditing is configured for Docker files and directories"
      - "Ensure Docker daemon is configured to use TLS authentication"
    
    Docker_Daemon_Configuration:
      - "Ensure network traffic is restricted between containers"
      - "Ensure the logging level is set to 'info'"
      - "Ensure Docker is allowed to make changes to iptables"
      - "Ensure insecure registries are not used"
    
    Container_Images:
      - "Ensure a user for the container has been created"
      - "Ensure that containers use only trusted base images"
      - "Ensure unnecessary packages are not installed"
      - "Ensure images are scanned and rebuilt to include security patches"
    
    Container_Runtime:
      - "Ensure containers run with a non-root user"
      - "Ensure the container's root filesystem is mounted as read-only"
      - "Ensure sensitive host system directories are not mounted"
      - "Ensure privileged containers are not used"
  
  NIST_Container_Security:
    Image_Security:
      - "Use minimal base images"
      - "Scan images for vulnerabilities"
      - "Sign and verify image integrity"
      - "Implement image lifecycle management"
    
    Runtime_Security:
      - "Implement least privilege access"
      - "Monitor container behavior"
      - "Implement network segmentation"
      - "Use security contexts and policies"
    
    Data_Protection:
      - "Encrypt data at rest and in transit"
      - "Implement secure secrets management"
      - "Protect sensitive mount points"
      - "Implement data loss prevention"
```

## 🛠️ Container Security Tools Comparison

### **Enterprise Container Security Tools**
```python
class ContainerSecurityTools:
    def __init__(self):
        self.tools = {
            'trivy': {
                'type': 'Open Source',
                'cost': 'Free',
                'strengths': [
                    'Fast and accurate scanning',
                    'Multiple vulnerability databases',
                    'Excellent CI/CD integration',
                    'Supports multiple formats (SARIF, JSON, XML)',
                    'Regular database updates'
                ],
                'weaknesses': [
                    'Limited runtime protection',
                    'Basic reporting features',
                    'No centralized management'
                ],
                'scan_types': ['OS packages', 'Language libraries', 'IaC misconfigurations'],
                'best_for': 'Development teams, CI/CD pipelines'
            },
            'clair': {
                'type': 'Open Source',
                'cost': 'Free',
                'strengths': [
                    'API-driven architecture',
                    'Scalable scanning',
                    'Good registry integration',
                    'Extensible vulnerability sources'
                ],
                'weaknesses': [
                    'Complex setup and maintenance',
                    'Limited language support',
                    'Requires additional tooling'
                ],
                'scan_types': ['OS packages', 'Static analysis'],
                'best_for': 'Large-scale registry scanning'
            },
            'snyk_container': {
                'type': 'Commercial',
                'cost': '$25/developer/month',
                'strengths': [
                    'Developer-friendly interface',
                    'Excellent IDE integration',
                    'Good remediation advice',
                    'Base image recommendations'
                ],
                'weaknesses': [
                    'Limited free tier',
                    'Focused on popular languages',
                    'Vendor lock-in'
                ],
                'scan_types': ['OS packages', 'Application dependencies'],
                'best_for': 'Developer-focused teams'
            },
            'twistlock_prisma': {
                'type': 'Enterprise Commercial',
                'cost': '$50,000+/year',
                'strengths': [
                    'Comprehensive runtime protection',
                    'Advanced threat detection',
                    'Compliance automation',
                    'Enterprise-grade reporting'
                ],
                'weaknesses': [
                    'Very expensive',
                    'Complex deployment',
                    'Resource intensive'
                ],
                'scan_types': ['Full lifecycle security'],
                'best_for': 'Large enterprises with security budget'
            },
            'aqua_security': {
                'type': 'Enterprise Commercial',
                'cost': '$30,000+/year',
                'strengths': [
                    'Full container lifecycle security',
                    'Advanced runtime protection',
                    'Kubernetes security',
                    'Compliance frameworks'
                ],
                'weaknesses': [
                    'Expensive licensing',
                    'Learning curve',
                    'Vendor lock-in'
                ],
                'scan_types': ['Image, runtime, compliance'],
                'best_for': 'Security-focused enterprises'
            }
        }
    
    def recommend_tool_stack(self, requirements):
        """
        Recommend optimal tool combination based on requirements
        """
        recommendations = []
        
        if requirements.budget == 'free':
            recommendations.append({
                'primary': 'trivy',
                'secondary': 'docker-bench-security',
                'use_case': 'Basic vulnerability scanning and configuration checks'
            })
        elif requirements.budget == 'startup':
            recommendations.append({
                'primary': 'snyk_container',
                'secondary': 'trivy',
                'use_case': 'Developer-friendly scanning with free backup'
            })
        elif requirements.budget == 'enterprise':
            recommendations.append({
                'primary': 'twistlock_prisma',
                'secondary': 'trivy',
                'use_case': 'Comprehensive security with open source validation'
            })
        
        return recommendations
```

## 🚀 GitHub Actions Container Security Implementation

### **1. Trivy Comprehensive Implementation**
```yaml
# .github/workflows/container-security-trivy.yml
name: Container Security Scanning with Trivy

on:
  push:
    branches: [main, develop]
    paths:
      - 'Dockerfile*'
      - 'docker-compose*.yml'
      - '.github/workflows/container-security-trivy.yml'
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 4 * * 1'

permissions:
  contents: read
  security-events: write
  actions: read

jobs:
  build-image:
    name: Build Container Image
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.build.outputs.image-tag }}
      image-digest: ${{ steps.build.outputs.image-digest }}
      
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Build container image
        id: build
        run: |
          IMAGE_TAG="ecommerce-app:${{ github.sha }}"
          docker build -t $IMAGE_TAG .
          
          IMAGE_DIGEST=$(docker inspect $IMAGE_TAG --format='{{index .RepoDigests 0}}')
          
          echo "image-tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
          echo "image-digest=$IMAGE_DIGEST" >> $GITHUB_OUTPUT
          
          echo "Built image: $IMAGE_TAG"
          echo "Image digest: $IMAGE_DIGEST"

  trivy-scan:
    name: Trivy Security Scan
    runs-on: ubuntu-latest
    needs: build-image
    
    strategy:
      matrix:
        scan-type: [vuln, config, secret]
    
    steps:
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build-image.outputs.image-tag }}
          format: 'sarif'
          output: 'trivy-${{ matrix.scan-type }}-results.sarif'
          scan-type: ${{ matrix.scan-type }}
          severity: 'CRITICAL,HIGH,MEDIUM'
          
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-${{ matrix.scan-type }}-results.sarif'
          category: 'trivy-${{ matrix.scan-type }}'
```

**Comprehensive Line-by-Line Analysis:**

**`# .github/workflows/container-security-trivy.yml`**
- **Purpose**: Comment indicating Trivy-focused container security workflow
- **Location**: Standard GitHub Actions workflow directory
- **Tool focus**: Specifically for Trivy vulnerability scanner
- **Security**: Dedicated container security scanning workflow
- **Organization**: Clear identification of security scanning purpose

**`name: Container Security Scanning with Trivy`**
- **Display name**: Human-readable workflow name for GitHub UI
- **Purpose**: Clearly identifies Trivy container security workflow
- **Visibility**: Appears in Actions tab and security dashboards
- **Tool identification**: Specific scanner tool mentioned
- **Security focus**: Emphasizes container security scanning

**`on:`**
- **Triggers**: Defines events that execute container security scanning
- **Automation**: Event-driven security analysis execution
- **Efficiency**: Targeted execution for container-related changes
- **Scheduling**: Includes both event-driven and scheduled scans
- **Comprehensive**: Multiple trigger types for thorough coverage

**`push: branches: [main, develop]`**
- **Push triggers**: Runs on pushes to main and develop branches
- **Security gates**: Ensures important branches receive security validation
- **Protection**: Validates container security on production-bound code
- **Quality**: Continuous security validation for critical branches
- **Efficiency**: Focuses security resources on important branches

**`paths:`**
- **Path filtering**: Only runs when container-related files change
- **Efficiency**: Prevents unnecessary scans when containers unchanged
- **Optimization**: Reduces CI/CD resource consumption
- **Relevance**: Only scans when container security could be affected
- **Smart execution**: Intelligent workflow execution based on changes

**`- 'Dockerfile*'`**
- **Dockerfile changes**: Triggers on any Dockerfile modification
- **Pattern matching**: Wildcard matches all Dockerfile variants
- **Comprehensive**: Covers Dockerfile, Dockerfile.prod, etc.
- **Security**: Container definition changes require security validation
- **Relevance**: Direct impact on container security posture

**`- 'docker-compose*.yml'`**
- **Compose files**: Triggers on docker-compose file changes
- **Orchestration**: Multi-container deployment security validation
- **Pattern**: Matches all docker-compose file variants
- **Security**: Compose configurations affect container security
- **Comprehensive**: Covers development and production compose files

**`- '.github/workflows/container-security-trivy.yml'`**
- **Workflow changes**: Triggers when security workflow modified
- **Self-validation**: Tests workflow changes automatically
- **Quality**: Ensures workflow modifications work correctly
- **Security**: Validates security workflow changes
- **Maintenance**: Automatic testing of workflow updates

**`pull_request: branches: [main]`**
- **PR validation**: Scans containers in pull requests to main
- **Quality gate**: Prevents insecure containers from merging
- **Review integration**: Provides security results in PR interface
- **Protection**: Ensures main branch container security standards
- **Collaboration**: Supports code review with security findings

**`schedule: - cron: '0 4 * * 1'`**
- **Scheduled scanning**: Weekly security scans on Monday 4 AM
- **Proactive**: Catches new vulnerabilities in existing containers
- **Maintenance**: Regular security posture validation
- **Timing**: Off-peak hours minimize impact
- **Compliance**: Meets requirements for regular security scanning

**`permissions:`**
- **Security permissions**: Defines workflow security access rights
- **Principle**: Least privilege access for security operations
- **Granular**: Fine-grained permission control
- **Compliance**: Meets security requirements for access control
- **Audit**: Clear permission documentation for security reviews

**`contents: read`**
- **Repository access**: Allows reading repository contents
- **Scope**: Minimal read access to repository data
- **Security**: Read-only access reduces security risk
- **Functionality**: Enables code checkout and file access
- **Principle**: Least privilege for security scanning

**`security-events: write`**
- **Security reporting**: Allows writing security events and findings
- **SARIF upload**: Required for uploading security scan results
- **Integration**: Enables GitHub Security tab integration
- **Visibility**: Security findings appear in GitHub interface
- **Compliance**: Required for security result reporting

**`actions: read`**
- **Workflow access**: Allows reading GitHub Actions metadata
- **Integration**: Enables workflow introspection capabilities
- **Minimal**: Read-only access to action information
- **Functionality**: Supports workflow coordination features
- **Security**: Limited access for workflow operations

**`jobs:`**
- **Job collection**: Defines container security scanning jobs
- **Organization**: Logical grouping of security tasks
- **Pipeline**: Multi-stage security scanning process
- **Efficiency**: Parallel execution where possible
- **Comprehensive**: Complete container security validation

**`build-image:`**
- **Build job**: Creates container image for security scanning
- **Foundation**: Required before security scanning can occur
- **Isolation**: Separate job for image building concerns
- **Outputs**: Provides image information to scanning jobs
- **Preparation**: Prepares artifacts for security analysis

**`name: Build Container Image`**
- **Display name**: Human-readable job name for GitHub UI
- **Purpose**: Clearly identifies image building job
- **Clarity**: Obvious job function for team understanding
- **Organization**: Clear job identification in workflow
- **Monitoring**: Easy identification in workflow runs

**`runs-on: ubuntu-latest`**
- **Environment**: Ubuntu Linux for container building
- **Docker support**: Native Docker support in Ubuntu runners
- **Performance**: Reliable environment for container operations
- **Compatibility**: Supports all container building tools
- **Standard**: Common choice for container workflows

**`outputs:`**
- **Job outputs**: Defines values available to dependent jobs
- **Communication**: Enables job-to-job data transfer
- **Image information**: Provides built image details
- **Coordination**: Connects build job to scanning jobs
- **Integration**: Enables multi-job workflow coordination

**`image-tag: ${{ steps.build.outputs.image-tag }}`**
- **Image identifier**: Provides image tag to scanning jobs
- **Reference**: Unique identifier for built container image
- **Coordination**: Enables scanning jobs to reference correct image
- **Traceability**: Links build output to security scanning
- **Integration**: Connects build and scan phases

**`image-digest: ${{ steps.build.outputs.image-digest }}`**
- **Image digest**: Provides cryptographic image identifier
- **Security**: Immutable identifier for exact image version
- **Integrity**: Ensures scanning targets correct image
- **Precision**: Cryptographically unique image reference
- **Verification**: Enables image integrity validation

**`steps:`**
- **Step collection**: Sequential tasks for image building
- **Process**: Standardized container building process
- **Foundation**: Prepares container for security scanning
- **Efficiency**: Optimized steps for container building
- **Output**: Produces container image for scanning

**`- name: Checkout code`**
- **Code retrieval**: Downloads repository code for building
- **Foundation**: Required for accessing Dockerfile and context
- **Standard**: Common first step in container workflows
- **Access**: Provides build process access to source files
- **Preparation**: Enables container image building

**`uses: actions/checkout@v4`**
- **Official action**: GitHub's official code checkout action
- **Version**: Latest stable version for reliability
- **Functionality**: Downloads complete repository contents
- **Security**: Maintained by GitHub with security updates
- **Integration**: Optimized for GitHub Actions environment

**`- name: Set up Docker Buildx`**
- **Docker enhancement**: Configures advanced Docker build capabilities
- **Features**: Enables multi-platform builds and caching
- **Performance**: Optimized Docker building capabilities
- **Compatibility**: Required for some advanced Docker features
- **Foundation**: Prepares enhanced Docker build environment

**`uses: docker/setup-buildx-action@v3`**
- **Buildx action**: Official Docker Buildx setup action
- **Version**: Stable version for reliable Docker operations
- **Features**: Enables advanced Docker build features
- **Performance**: Optimized container building capabilities
- **Integration**: Docker-maintained action for GitHub Actions

**`- name: Build container image`**
- **Image creation**: Builds Docker container image for scanning
- **Security target**: Creates the artifact to be security scanned
- **Process**: Standard Docker image building process
- **Output**: Produces container image with metadata
- **Foundation**: Essential step for security scanning workflow

**`id: build`**
- **Step identifier**: Unique name for referencing step outputs
- **Output access**: Enables other jobs to access build results
- **Reference**: Used in output expressions and job coordination
- **Communication**: Enables step-to-job data transfer
- **Integration**: Connects build step to workflow outputs

**`run: |`**
- **Multi-line script**: Enables complex image building logic
- **Flexibility**: Allows custom build process implementation
- **Control**: Full control over image building process
- **Metadata**: Captures image information for scanning
- **Output**: Generates job outputs for dependent jobs

**`IMAGE_TAG="ecommerce-app:${{ github.sha }}"`**
- **Tag generation**: Creates unique image tag using commit SHA
- **Uniqueness**: Each commit gets unique image identifier
- **Traceability**: Links image to specific code commit
- **Versioning**: Provides version control for container images
- **Identification**: Clear image identification for scanning

**`docker build -t $IMAGE_TAG .`**
- **Image building**: Builds Docker image with specified tag
- **Context**: Uses current directory as build context
- **Tagging**: Applies generated tag to built image
- **Standard**: Standard Docker build command
- **Output**: Creates container image ready for scanning

**`IMAGE_DIGEST=$(docker inspect $IMAGE_TAG --format='{{index .RepoDigests 0}}')`**
- **Digest extraction**: Retrieves cryptographic image digest
- **Inspection**: Uses Docker inspect to get image metadata
- **Format**: Extracts specific digest information
- **Security**: Provides immutable image identifier
- **Integrity**: Enables image integrity verification

**`echo "image-tag=$IMAGE_TAG" >> $GITHUB_OUTPUT`**
- **Output setting**: Sets job output for image tag
- **Communication**: Makes image tag available to other jobs
- **GitHub Actions**: Uses GitHub Actions output mechanism
- **Coordination**: Enables job-to-job communication
- **Integration**: Connects build job to scanning jobs

**`echo "image-digest=$IMAGE_DIGEST" >> $GITHUB_OUTPUT`**
- **Digest output**: Sets job output for image digest
- **Security**: Provides cryptographic image identifier
- **Verification**: Enables image integrity validation
- **Communication**: Makes digest available to scanning jobs
- **Traceability**: Links exact image version to security results

**`trivy-scan:`**
- **Scanning job**: Executes Trivy security scanning
- **Security**: Core security validation job
- **Dependencies**: Requires built image from previous job
- **Matrix**: Uses matrix strategy for multiple scan types
- **Comprehensive**: Complete security scanning implementation

**`name: Trivy Security Scan`**
- **Display name**: Human-readable security scanning job name
- **Purpose**: Clearly identifies Trivy scanning job
- **Security focus**: Emphasizes security scanning purpose
- **Tool identification**: Specific scanner tool mentioned
- **Clarity**: Obvious security scanning job identification

**`needs: build-image`**
- **Dependency**: Waits for image building job completion
- **Sequence**: Ensures image exists before scanning
- **Coordination**: Links build and scan phases
- **Efficiency**: Only scans when image build succeeds
- **Pipeline**: Logical security scanning progression

**`strategy: matrix:`**
- **Matrix strategy**: Enables parallel scanning with different types
- **Efficiency**: Multiple scan types run simultaneously
- **Comprehensive**: Covers different security aspects
- **Organization**: Structured approach to security scanning
- **Performance**: Parallel execution reduces total scan time

**`scan-type: [vuln, config, secret]`**
- **Scan types**: Defines different Trivy scanning modes
- **Vulnerability**: Scans for known security vulnerabilities
- **Configuration**: Analyzes container configuration security
- **Secrets**: Detects exposed secrets and credentials
- **Comprehensive**: Complete security scanning coverage

**`- name: Run Trivy vulnerability scanner`**
- **Security scanning**: Executes Trivy security analysis
- **Tool**: Uses Trivy open-source vulnerability scanner
- **Comprehensive**: Performs specified type of security scan
- **Integration**: Uses official Trivy GitHub Action
- **Results**: Generates security findings in SARIF format

**`uses: aquasecurity/trivy-action@master`**
- **Trivy action**: Official Trivy action from Aqua Security
- **Version**: Uses master branch for latest features
- **Maintenance**: Maintained by Trivy developers
- **Integration**: Optimized for GitHub Actions environment
- **Functionality**: Complete Trivy scanning capabilities

**`with: image-ref: ${{ needs.build-image.outputs.image-tag }}`**
- **Scan target**: Specifies image to scan using build job output
- **Coordination**: Uses image tag from build job
- **Accuracy**: Scans exact image built in previous job
- **Traceability**: Links scanning to specific built image
- **Integration**: Connects build and scan job outputs

**`format: 'sarif'`**
- **Output format**: Generates SARIF format security results
- **Standard**: Industry standard for security analysis results
- **Integration**: SARIF integrates with GitHub Security tab
- **Compatibility**: Compatible with security tools and dashboards
- **Visibility**: Enables GitHub native security result display

**`output: 'trivy-${{ matrix.scan-type }}-results.sarif'`**
- **Result file**: Dynamic filename based on scan type
- **Organization**: Separate files for each scan type
- **Matrix**: Uses matrix variable for unique filenames
- **Structure**: Organized security result storage
- **Processing**: Enables type-specific result handling

**`scan-type: ${{ matrix.scan-type }}`**
- **Scan configuration**: Uses matrix variable for scan type
- **Dynamic**: Different scan types per matrix execution
- **Flexibility**: Adapts scanning behavior per matrix value
- **Comprehensive**: Covers vulnerability, config, and secret scans
- **Efficiency**: Parallel execution of different scan types

**`severity: 'CRITICAL,HIGH,MEDIUM'`**
- **Severity filtering**: Focuses on important security findings
- **Quality**: Filters out low-severity noise
- **Efficiency**: Reduces result volume to actionable items
- **Priority**: Emphasizes critical and high-impact vulnerabilities
- **Actionable**: Provides focused security findings

**`- name: Upload Trivy scan results to GitHub Security tab`**
- **Result integration**: Uploads security findings to GitHub
- **Visibility**: Makes security results visible in GitHub UI
- **Integration**: Uses GitHub's native security features
- **Accessibility**: Security findings available to team
- **Compliance**: Meets security reporting requirements

**`uses: github/codeql-action/upload-sarif@v2`**
- **SARIF upload**: Official GitHub action for SARIF result upload
- **Integration**: Integrates with GitHub Security tab
- **Version**: Stable version for reliable result upload
- **Functionality**: Handles SARIF parsing and display
- **Security**: Enables native GitHub security features

**`if: always()`**
- **Conditional execution**: Runs even if scanning fails
- **Reliability**: Ensures results uploaded regardless of scan outcome
- **Debugging**: Results available even for failed scans
- **Completeness**: Always preserves security findings
- **Troubleshooting**: Enables analysis of scanning failures

**`with: sarif_file: 'trivy-${{ matrix.scan-type }}-results.sarif'`**
- **Result file**: Specifies SARIF file to upload
- **Dynamic**: Uses matrix variable for type-specific files
- **Organization**: Uploads appropriate file per scan type
- **Accuracy**: Ensures correct results uploaded per scan
- **Structure**: Maintains organized security result upload

**`category: 'trivy-${{ matrix.scan-type }}'`**
- **Result categorization**: Organizes security findings by scan type
- **Organization**: Separates vulnerability, config, and secret findings
- **Clarity**: Clear categorization in GitHub Security tab
- **Navigation**: Easy filtering of security results by type
- **Structure**: Organized security finding presentation
          # Create unique image tag using git commit SHA
          IMAGE_TAG="security-scan:${{ github.sha }}"
          # ↑ ${{ github.sha }} is the commit hash (unique identifier)
          # Creates tags like "security-scan:abc123def456"
          
          # Build image with security-focused labels
          docker buildx build \
          # ↑ Uses buildx for advanced build features
            --load \
          # ↑ --load saves image to local Docker daemon for scanning
            --tag "$IMAGE_TAG" \
          # ↑ --tag assigns the name/tag to the built image
            --label "org.opencontainers.image.source=${{ github.server_url }}/${{ github.repository }}" \
          # ↑ OCI standard label linking image to source repository
          # Helps with supply chain security and traceability
            --label "org.opencontainers.image.revision=${{ github.sha }}" \
          # ↑ Records exact commit that built this image
            --label "org.opencontainers.image.created=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
          # ↑ Records when image was built (ISO 8601 format)
            .
          # ↑ . means build from current directory (looks for Dockerfile)
          
          # Get image digest for verification
          IMAGE_DIGEST=$(docker inspect "$IMAGE_TAG" --format='{{index .RepoDigests 0}}' 2>/dev/null || echo "local-build")
          # ↑ docker inspect gets detailed image information
          # --format extracts specific field (RepoDigests[0])
          # 2>/dev/null suppresses error messages
          # || echo "local-build" provides fallback if digest not available
          
          # Set outputs for other jobs to use
          echo "image-tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
          # ↑ $GITHUB_OUTPUT is special file for setting job outputs
          echo "image-digest=$IMAGE_DIGEST" >> $GITHUB_OUTPUT
          
          echo "✅ Built image: $IMAGE_TAG"
          # ↑ Confirmation message in workflow logs

  # Comprehensive Trivy scanning
  trivy-security-scan:
    # ↑ Job that performs the actual security scanning
    name: Trivy Security Analysis
    # ↑ Descriptive job name
    needs: build-image
    # ↑ This job depends on build-image job completing successfully
    # Creates job dependency chain: build → scan
    runs-on: ubuntu-latest
    # ↑ Uses Ubuntu virtual machine
    
    strategy:
      # ↑ Defines how to run this job multiple times with different parameters
      matrix:
        # ↑ Matrix strategy runs job once for each combination
        scan-type: [
          # ↑ Different types of security scans to perform
          'vuln',      # Vulnerability scanning
          'config',    # Configuration scanning  
          'secret'     # Secret scanning
        ]
        # Each scan type runs as a separate job instance
        # Provides focused results for each security area
    
    steps:
      - name: Run Trivy ${{ matrix.scan-type }} scan
        # ↑ Step name includes current matrix value for clarity
        uses: aquasecurity/trivy-action@master
        # ↑ Official Trivy action from Aqua Security
        with:
          # ↑ Parameters passed to Trivy action
          image-ref: ${{ needs.build-image.outputs.image-tag }}
          # ↑ References image tag from build-image job output
          # needs.build-image.outputs accesses the previous job's outputs
          format: 'sarif'
          # ↑ SARIF (Static Analysis Results Interchange Format)
          # Standard format for security tool results
          output: 'trivy-${{ matrix.scan-type }}-results.sarif'
          # ↑ Output filename includes scan type for identification
          # Creates files like: trivy-vuln-results.sarif
          scan-type: ${{ matrix.scan-type }}
          # ↑ Tells Trivy which type of scan to perform
          severity: 'CRITICAL,HIGH,MEDIUM'
          # ↑ Only report these severity levels
          # Filters out LOW and UNKNOWN to focus on actionable issues
          
      - name: Upload Trivy scan results to GitHub Security tab
        # ↑ Integrates scan results with GitHub's security features
        uses: github/codeql-action/upload-sarif@v3
        # ↑ Official GitHub action for uploading security results
        if: always()
        # ↑ Upload results even if scan found vulnerabilities
        with:
          sarif_file: 'trivy-${{ matrix.scan-type }}-results.sarif'
          # ↑ Path to SARIF file created by Trivy
          category: 'trivy-${{ matrix.scan-type }}'
          # ↑ Categorizes results in GitHub Security tab
          # Creates separate sections for vuln, config, secret scans
```

**Detailed Explanation for Newbies:**

1. **Workflow Triggers:**
   - **Path Filtering**: Only runs when Docker-related files change (saves resources)
   - **Scheduled Scans**: Weekly scans catch new vulnerabilities in existing images
   - **PR Integration**: Prevents vulnerable containers from reaching production

2. **Job Dependencies:**
   - **build-image → trivy-security-scan**: Sequential execution ensures image exists before scanning
   - **Job Outputs**: build-image passes image information to scanning job
   - **Isolation**: Each job runs in separate virtual machine for security

3. **Docker Build Process:**
   - **Buildx**: Advanced Docker builder with multi-platform support
   - **OCI Labels**: Standard metadata for container supply chain security
   - **Local Loading**: --load saves image locally for immediate scanning

4. **Matrix Strategy Benefits:**
   - **Parallel Scanning**: All scan types run simultaneously
   - **Focused Results**: Separate results for vulnerabilities, config issues, secrets
   - **Scalability**: Easy to add new scan types to the matrix

5. **Security Integration:**
   - **SARIF Format**: Standard format enables GitHub Security tab integration
   - **Severity Filtering**: Focuses on actionable security issues
   - **Always Upload**: Results available even when vulnerabilities found
      matrix:
        scan-type: ['vuln', 'config', 'secret']
      fail-fast: false
      
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Run Trivy ${{ matrix.scan-type }} scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build-image.outputs.image-tag }}
          format: 'sarif'
          output: 'trivy-${{ matrix.scan-type }}-results.sarif'
          scan-type: ${{ matrix.scan-type }}
          severity: 'CRITICAL,HIGH,MEDIUM'
          exit-code: '0'  # Don't fail the job, we'll handle this later
          
      - name: Upload Trivy SARIF results
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-${{ matrix.scan-type }}-results.sarif'
          category: 'trivy-${{ matrix.scan-type }}'
          
      - name: Generate detailed report
        if: always()
        run: |
          echo "📊 Generating detailed Trivy ${{ matrix.scan-type }} report..."
          
          # Generate human-readable report
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v ${{ github.workspace }}:/workspace \
            aquasec/trivy:latest image \
            --format table \
            --severity CRITICAL,HIGH,MEDIUM,LOW \
            --output /workspace/trivy-${{ matrix.scan-type }}-report.txt \
            ${{ needs.build-image.outputs.image-tag }}
          
          # Generate JSON report for processing
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v ${{ github.workspace }}:/workspace \
            aquasec/trivy:latest image \
            --format json \
            --severity CRITICAL,HIGH,MEDIUM,LOW \
            --output /workspace/trivy-${{ matrix.scan-type }}-report.json \
            ${{ needs.build-image.outputs.image-tag }}
            
      - name: Process scan results
        if: always()
        run: |
          echo "🔍 Processing Trivy ${{ matrix.scan-type }} scan results..."
          
          if [ -f "trivy-${{ matrix.scan-type }}-report.json" ]; then
            # Extract vulnerability counts
            python3 << 'EOF'
          import json
          import sys
          
          scan_type = "${{ matrix.scan-type }}"
          
          try:
              with open(f'trivy-{scan_type}-report.json', 'r') as f:
                  data = json.load(f)
              
              total_vulns = 0
              severity_counts = {'CRITICAL': 0, 'HIGH': 0, 'MEDIUM': 0, 'LOW': 0}
              
              if 'Results' in data:
                  for result in data['Results']:
                      if 'Vulnerabilities' in result:
                          for vuln in result['Vulnerabilities']:
                              severity = vuln.get('Severity', 'UNKNOWN')
                              if severity in severity_counts:
                                  severity_counts[severity] += 1
                              total_vulns += 1
              
              print(f"📊 {scan_type.upper()} Scan Results:")
              print(f"  🔴 Critical: {severity_counts['CRITICAL']}")
              print(f"  🟠 High: {severity_counts['HIGH']}")
              print(f"  🟡 Medium: {severity_counts['MEDIUM']}")
              print(f"  🔵 Low: {severity_counts['LOW']}")
              print(f"  📊 Total: {total_vulns}")
              
              # Save summary for later use
              summary = {
                  'scan_type': scan_type,
                  'total_vulnerabilities': total_vulns,
                  'severity_counts': severity_counts
              }
              
              with open(f'trivy-{scan_type}-summary.json', 'w') as f:
                  json.dump(summary, f)
                  
          except Exception as e:
              print(f"❌ Error processing {scan_type} results: {e}")
              sys.exit(1)
          EOF
          fi
          
      - name: Upload scan artifacts
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: trivy-${{ matrix.scan-type }}-results
          path: |
            trivy-${{ matrix.scan-type }}-results.sarif
            trivy-${{ matrix.scan-type }}-report.txt
            trivy-${{ matrix.scan-type }}-report.json
            trivy-${{ matrix.scan-type }}-summary.json
          retention-days: 30

  # Dockerfile security analysis
  dockerfile-security:
    name: Dockerfile Security Analysis
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Run Trivy config scan on Dockerfile
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: 'Dockerfile'
          format: 'sarif'
          output: 'dockerfile-security.sarif'
          
      - name: Upload Dockerfile SARIF results
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'dockerfile-security.sarif'
          category: 'dockerfile-security'
          
      - name: Run Hadolint (Dockerfile linter)
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: Dockerfile
          format: sarif
          output-file: hadolint-results.sarif
          
      - name: Upload Hadolint SARIF results
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: hadolint-results.sarif
          category: 'hadolint'

  # Container runtime security analysis
  container-runtime-security:
    name: Container Runtime Security
    needs: build-image
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Run Docker Bench Security
        run: |
          echo "🔒 Running Docker Bench Security..."
          
          # Clone Docker Bench Security
          git clone https://github.com/docker/docker-bench-security.git
          cd docker-bench-security
          
          # Run security benchmark
          sudo ./docker-bench-security.sh -l /tmp/docker-bench.log
          
          # Process results
          if [ -f "/tmp/docker-bench.log" ]; then
            echo "📊 Docker Bench Security Results:"
            grep -E "(WARN|INFO|PASS|NOTE)" /tmp/docker-bench.log | head -20
            
            # Count issues
            WARNINGS=$(grep -c "WARN" /tmp/docker-bench.log || echo "0")
            PASSES=$(grep -c "PASS" /tmp/docker-bench.log || echo "0")
            
            echo "⚠️ Warnings: $WARNINGS"
            echo "✅ Passes: $PASSES"
            
            # Copy log for artifact upload
            cp /tmp/docker-bench.log ../docker-bench-results.log
          fi
          
      - name: Test container security configuration
        run: |
          echo "🧪 Testing container security configuration..."
          
          IMAGE_TAG="${{ needs.build-image.outputs.image-tag }}"
          
          # Test 1: Check if container runs as non-root
          echo "Test 1: Checking if container runs as non-root user..."
          USER_ID=$(docker run --rm "$IMAGE_TAG" id -u 2>/dev/null || echo "0")
          if [ "$USER_ID" = "0" ]; then
            echo "❌ Container runs as root user (security risk)"
          else
            echo "✅ Container runs as non-root user (UID: $USER_ID)"
          fi
          
          # Test 2: Check for sensitive file mounts
          echo "Test 2: Checking container configuration..."
          docker inspect "$IMAGE_TAG" > container-config.json
          
          # Check for privileged mode
          PRIVILEGED=$(jq -r '.[0].Config.Privileged // false' container-config.json)
          if [ "$PRIVILEGED" = "true" ]; then
            echo "❌ Container configured to run in privileged mode"
          else
            echo "✅ Container not configured for privileged mode"
          fi
          
          # Test 3: Check exposed ports
          echo "Test 3: Checking exposed ports..."
          EXPOSED_PORTS=$(jq -r '.[0].Config.ExposedPorts // {} | keys[]' container-config.json 2>/dev/null || echo "none")
          if [ "$EXPOSED_PORTS" != "none" ]; then
            echo "ℹ️ Exposed ports: $EXPOSED_PORTS"
          else
            echo "ℹ️ No exposed ports configured"
          fi
          
      - name: Upload runtime security results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: runtime-security-results
          path: |
            docker-bench-results.log
            container-config.json
          retention-days: 30

  # Consolidate all security results
  security-summary:
    name: Security Summary Report
    needs: [build-image, trivy-security-scan, dockerfile-security, container-runtime-security]
    if: always()
    runs-on: ubuntu-latest
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v3
        
      - name: Generate comprehensive security report
        run: |
          echo "📊 Generating comprehensive container security report..."
          
          # Create summary report
          cat > security-summary.md << 'EOF'
          # Container Security Analysis Report
          
          **Image:** ${{ needs.build-image.outputs.image-tag }}
          **Scan Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
          **Repository:** ${{ github.repository }}
          **Commit:** ${{ github.sha }}
          
          ## Vulnerability Scanning Results
          
          EOF
          
          # Process Trivy results
          for scan_type in vuln config secret; do
            if [ -f "trivy-${scan_type}-results/trivy-${scan_type}-summary.json" ]; then
              echo "### ${scan_type^} Scan Results" >> security-summary.md
              python3 << EOF
          import json
          
          try:
              with open('trivy-${scan_type}-results/trivy-${scan_type}-summary.json', 'r') as f:
                  data = json.load(f)
              
              counts = data['severity_counts']
              total = data['total_vulnerabilities']
              
              print(f"- 🔴 Critical: {counts['CRITICAL']}")
              print(f"- 🟠 High: {counts['HIGH']}")
              print(f"- 🟡 Medium: {counts['MEDIUM']}")
              print(f"- 🔵 Low: {counts['LOW']}")
              print(f"- 📊 Total: {total}")
              print()
              
          except:
              print("- ❌ Results not available")
              print()
          EOF
            fi
          done >> security-summary.md
          
          echo "## Recommendations" >> security-summary.md
          echo "1. Address all CRITICAL and HIGH severity vulnerabilities immediately" >> security-summary.md
          echo "2. Review Dockerfile security best practices" >> security-summary.md
          echo "3. Implement runtime security monitoring" >> security-summary.md
          echo "4. Regular security scanning in CI/CD pipeline" >> security-summary.md
          
          # Display summary
          cat security-summary.md
          
      - name: Upload comprehensive report
        uses: actions/upload-artifact@v3
        with:
          name: comprehensive-security-report
          path: security-summary.md
          retention-days: 90
          
      - name: Comment on PR with security summary
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            
            try {
              const summary = fs.readFileSync('security-summary.md', 'utf8');
              
              await github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: `## 🔒 Container Security Analysis\n\n${summary}`
              });
            } catch (error) {
              console.log('Could not post security summary comment:', error);
            }
```

This comprehensive container security implementation provides enterprise-grade vulnerability scanning, configuration analysis, runtime security testing, and detailed reporting. The examples demonstrate real-world security patterns used by major organizations to protect their container infrastructure.
