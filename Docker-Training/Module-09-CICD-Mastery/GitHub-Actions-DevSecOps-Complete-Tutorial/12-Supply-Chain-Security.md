# 🔗 Supply Chain Security

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** supply chain security threats and SLSA framework
- **Master** artifact signing and verification with Sigstore/Cosign
- **Implement** Software Bill of Materials (SBOM) generation
- **Configure** provenance tracking and attestation
- **Apply** comprehensive supply chain security for e-commerce applications

## 🎯 Real-World Context
Supply chain attacks like SolarWinds (2020) and Codecov (2021) have cost organizations billions and affected thousands of companies. Google, Microsoft, and other tech giants developed the SLSA framework to address these threats. Understanding supply chain security is critical for enterprise DevSecOps roles.

---

## 📚 Part 1: Supply Chain Security Fundamentals

### Understanding Supply Chain Attacks

**What is a Supply Chain Attack?**
An attack that targets the software development and distribution process rather than the final application directly.

**Common Attack Vectors:**
```
Supply Chain Attack Vectors
├── Source Code Attacks
│   ├── Compromised developer accounts
│   ├── Malicious code injection
│   ├── Backdoor insertion
│   └── Repository tampering
├── Build System Attacks
│   ├── Compromised CI/CD pipelines
│   ├── Malicious build scripts
│   ├── Dependency confusion
│   └── Build environment tampering
├── Distribution Attacks
│   ├── Package repository compromise
│   ├── Registry poisoning
│   ├── Man-in-the-middle attacks
│   └── Artifact tampering
└── Deployment Attacks
    ├── Infrastructure compromise
    ├── Configuration tampering
    ├── Runtime injection
    └── Update mechanism abuse
```

### SLSA Framework Overview

**SLSA (Supply-chain Levels for Software Artifacts):**
A security framework that defines levels of supply chain security with increasing requirements.

**SLSA Levels:**
```yaml
SLSA_Levels:
  Level_0:
    - No guarantees
    - Basic software development
    - No security requirements
  
  Level_1:
    - Build process exists
    - Provenance available
    - Basic build documentation
  
  Level_2:
    - Version controlled source
    - Authenticated provenance
    - Service-generated provenance
  
  Level_3:
    - Hardened build platform
    - Non-falsifiable provenance
    - Isolated build environment
  
  Level_4:
    - Two-party review
    - Hermetic builds
    - Reproducible builds
```

---

## 🔐 Part 2: Artifact Signing and Verification

### Sigstore and Cosign Integration

**Understanding Sigstore:**
Sigstore is a free, open-source service for signing and verifying software artifacts without managing cryptographic keys.

**Basic Cosign Workflow:**
```yaml
name: Artifact Signing with Cosign

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract Metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
      
      - name: Build and Push Container
        uses: docker/build-push-action@v5
        id: build
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
      
      - name: Install Cosign
        uses: sigstore/cosign-installer@v3
      
      - name: Sign Container Image
        run: |
          cosign sign --yes ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ steps.build.outputs.digest }}
```

**Line-by-Line Analysis:**

**`name: Artifact Signing with Cosign`** - Supply chain security workflow using Sigstore Cosign
**`tags: ['v*']`** - Triggers on version tags for release artifact signing
**`env: REGISTRY: ghcr.io`** - GitHub Container Registry for signed artifacts
**`permissions: id-token: write`** - Required for OIDC keyless signing with Cosign
**`uses: docker/setup-buildx-action@v3`** - Advanced Docker build capabilities for signing
**`uses: docker/login-action@v3`** - Authenticates with container registry for push/sign
**`uses: docker/metadata-action@v5`** - Generates semantic versioning tags for artifacts
**`type=semver,pattern={{version}}`** - Creates version tags from Git tags
**`type=semver,pattern={{major}}.{{minor}}`** - Creates major.minor version tags
**`uses: docker/build-push-action@v5`** - Builds and pushes container with digest output
**`id: build`** - Captures build outputs including image digest for signing
**`push: true`** - Pushes container to registry before signing
**`uses: sigstore/cosign-installer@v3`** - Installs Cosign tool for artifact signing
**`cosign sign --yes`** - Signs container image using keyless OIDC authentication
**`${{ steps.build.outputs.digest }}`** - Uses exact image digest for immutable signing
          # Sign the container image
          cosign sign --yes ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ steps.build.outputs.digest }}
        env:
          COSIGN_EXPERIMENTAL: 1
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ steps.build.outputs.digest }}
          format: spdx-json
          output-file: sbom.spdx.json
      
      - name: Sign SBOM
        run: |
          # Sign the SBOM
          cosign sign-blob --yes sbom.spdx.json --output-signature sbom.spdx.json.sig
        env:
          COSIGN_EXPERIMENTAL: 1
      
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: |
            sbom.spdx.json
            sbom.spdx.json.sig
```

### Advanced Signing with Custom Keys

**Key-based Signing Workflow:**
```yaml
name: Advanced Artifact Signing

on:
  release:
    types: [published]

jobs:
  sign-artifacts:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Cosign with Custom Key
        run: |
          # Install cosign
          curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
          sudo mv cosign-linux-amd64 /usr/local/bin/cosign
          sudo chmod +x /usr/local/bin/cosign
          
          # Setup private key
          echo "${{ secrets.COSIGN_PRIVATE_KEY }}" > cosign.key
          echo "${{ secrets.COSIGN_PASSWORD }}" > cosign.password
      
      - name: Build Application
        run: |
          # Build your application
          npm ci
          npm run build
          
          # Create release archive
          tar -czf ecommerce-app-${{ github.event.release.tag_name }}.tar.gz dist/
      
      - name: Sign Release Artifacts
        run: |
          # Sign the release archive
          cosign sign-blob \
            --key cosign.key \
            --output-signature ecommerce-app-${{ github.event.release.tag_name }}.tar.gz.sig \
            ecommerce-app-${{ github.event.release.tag_name }}.tar.gz
        env:
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
      
      - name: Upload Signed Artifacts to Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            ecommerce-app-${{ github.event.release.tag_name }}.tar.gz
            ecommerce-app-${{ github.event.release.tag_name }}.tar.gz.sig
      
      - name: Cleanup
        if: always()
        run: |
          rm -f cosign.key cosign.password
```

---

## 📋 Part 3: Software Bill of Materials (SBOM)

### SBOM Generation and Management

**Understanding SBOM:**
A Software Bill of Materials is a comprehensive inventory of all components, libraries, and dependencies in a software application.

**SBOM Generation Workflow:**
```yaml
name: SBOM Generation and Management

on:
  push:
    branches: [main, develop]
  release:
    types: [published]

jobs:
  generate-sbom:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        component: [frontend, backend, mobile-api]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        if: matrix.component != 'mobile-api'
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: ${{ matrix.component }}/package-lock.json
      
      - name: Setup Java
        if: matrix.component == 'mobile-api'
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Install Dependencies
        if: matrix.component != 'mobile-api'
        working-directory: ${{ matrix.component }}
        run: npm ci
      
      - name: Generate SBOM with Syft
        uses: anchore/sbom-action@v0
        with:
          path: ${{ matrix.component }}
          format: spdx-json
          output-file: ${{ matrix.component }}-sbom.spdx.json
      
      - name: Generate CycloneDX SBOM
        if: matrix.component != 'mobile-api'
        working-directory: ${{ matrix.component }}
        run: |
          # Install CycloneDX generator
          npm install -g @cyclonedx/cyclonedx-npm
          
          # Generate CycloneDX SBOM
          cyclonedx-npm --output-file ../cyclonedx-${{ matrix.component }}.json
      
      - name: Generate Maven SBOM
        if: matrix.component == 'mobile-api'
        working-directory: ${{ matrix.component }}
        run: |
          # Generate Maven dependency tree
          mvn dependency:tree -DoutputFile=../maven-dependencies.txt
          
          # Generate CycloneDX SBOM for Maven
          mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom
          cp target/bom.json ../cyclonedx-${{ matrix.component }}.json
      
      - name: Validate SBOM
        run: |
          # Install SBOM validation tools
          pip install spdx-tools
          
          # Validate SPDX SBOM
          python -m spdx_tools.spdx.validation.validate_anything ${{ matrix.component }}-sbom.spdx.json
      
      - name: Upload SBOM Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: sbom-${{ matrix.component }}
          path: |
            ${{ matrix.component }}-sbom.spdx.json
            cyclonedx-${{ matrix.component }}.json
            maven-dependencies.txt

  consolidate-sbom:
    needs: generate-sbom
    runs-on: ubuntu-latest
    
    steps:
      - name: Download All SBOMs
        uses: actions/download-artifact@v3
      
      - name: Consolidate SBOMs
        run: |
          # Create consolidated SBOM directory
          mkdir consolidated-sbom
          
          # Merge all component SBOMs
          python3 << 'EOF'
          import json
          import os
          from datetime import datetime
          
          consolidated = {
              "spdxVersion": "SPDX-2.3",
              "dataLicense": "CC0-1.0",
              "SPDXID": "SPDXRef-DOCUMENT",
              "name": "E-Commerce Platform SBOM",
              "documentNamespace": f"https://github.com/{os.environ.get('GITHUB_REPOSITORY', 'unknown')}/sbom-{datetime.now().isoformat()}",
              "creationInfo": {
                  "created": datetime.now().isoformat(),
                  "creators": ["Tool: GitHub Actions SBOM Generator"]
              },
              "packages": []
          }
          
          # Process each component SBOM
          for component in ['frontend', 'backend', 'mobile-api']:
              sbom_file = f"sbom-{component}/{component}-sbom.spdx.json"
              if os.path.exists(sbom_file):
                  with open(sbom_file, 'r') as f:
                      component_sbom = json.load(f)
                  
                  # Add component packages to consolidated SBOM
                  if 'packages' in component_sbom:
                      for package in component_sbom['packages']:
                          package['component'] = component
                          consolidated['packages'].append(package)
          
          # Save consolidated SBOM
          with open('consolidated-sbom/platform-sbom.spdx.json', 'w') as f:
              json.dump(consolidated, f, indent=2)
          
          print(f"Consolidated SBOM created with {len(consolidated['packages'])} packages")
          EOF
      
      - name: Generate SBOM Report
        run: |
          python3 << 'EOF'
          import json
          
          with open('consolidated-sbom/platform-sbom.spdx.json', 'r') as f:
              sbom = json.load(f)
          
          packages = sbom.get('packages', [])
          
          # Generate summary report
          report = f"""# E-Commerce Platform SBOM Report
          
          **Generated:** {sbom['creationInfo']['created']}
          **Total Packages:** {len(packages)}
          
          ## Component Breakdown
          """
          
          # Count packages by component
          component_counts = {}
          for package in packages:
              component = package.get('component', 'unknown')
              component_counts[component] = component_counts.get(component, 0) + 1
          
          for component, count in component_counts.items():
              report += f"- **{component}:** {count} packages\n"
          
          report += "\n## License Summary\n"
          
          # Count licenses
          license_counts = {}
          for package in packages:
              license_info = package.get('licenseConcluded', 'Unknown')
              license_counts[license_info] = license_counts.get(license_info, 0) + 1
          
          for license_type, count in sorted(license_counts.items()):
              report += f"- **{license_type}:** {count} packages\n"
          
          # Save report
          with open('consolidated-sbom/sbom-report.md', 'w') as f:
              f.write(report)
          EOF
      
      - name: Upload Consolidated SBOM
        uses: actions/upload-artifact@v3
        with:
          name: consolidated-sbom
          path: consolidated-sbom/
```

---

## 🎓 Module Summary

You've mastered supply chain security by learning:

**Core Concepts:**
- Supply chain attack vectors and SLSA framework
- Artifact signing and verification principles
- SBOM generation and management
- Provenance tracking and attestation

**Practical Skills:**
- Implementing Sigstore/Cosign for artifact signing
- Generating comprehensive SBOMs
- Setting up supply chain security workflows
- Validating and verifying software artifacts

**Enterprise Applications:**
- Multi-component SBOM consolidation
- Automated signing and verification pipelines
- Supply chain security governance
- Compliance reporting and audit trails

**Next Steps:**
- Implement supply chain security for your e-commerce project
- Set up artifact signing and SBOM generation
- Configure supply chain security monitoring
- Prepare for Module 13: Secrets Management

---

## 📚 Additional Resources

- [SLSA Framework](https://slsa.dev/)
- [Sigstore Documentation](https://docs.sigstore.dev/)
- [SPDX Specification](https://spdx.github.io/spdx-spec/)
- [CycloneDX SBOM Standard](https://cyclonedx.org/)
