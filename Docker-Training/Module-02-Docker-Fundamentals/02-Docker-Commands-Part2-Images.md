# 🐳 Docker Commands Part 2: Image Management - Enhanced Progressive Learning

## 🎯 Learning Objectives
By the end of this section, you will:
- **Master Docker image lifecycle** from creation to deletion with complete understanding
- **Understand image architecture** including layers, tags, and repository concepts
- **Apply image management** to real-world e-commerce deployment scenarios
- **Optimize image usage** for performance, security, and storage efficiency
- **Troubleshoot image issues** with confidence and systematic approaches

---

## 🏗️ Understanding Docker Images: The Foundation of Containers

### **What Are Docker Images? (Complete Conceptual Foundation)**

**Definition and Purpose:**
Docker images are **read-only templates** used to create containers. Think of them as:
- **Blueprints**: Like architectural plans for building houses (containers)
- **Snapshots**: Frozen state of a filesystem with applications pre-installed
- **Templates**: Reusable patterns for creating identical environments
- **Packages**: Complete application bundles with all dependencies included

**Why Images Matter for Business:**
- **Consistency**: Same image produces identical containers across all environments
- **Efficiency**: Share common layers, reducing storage and transfer costs by 60-80%
- **Speed**: Pre-built images enable instant application deployment
- **Reliability**: Immutable images prevent configuration drift and deployment issues
- **Scalability**: Single image can spawn thousands of identical containers

### **Image Architecture Deep Dive**

**Layer-Based Architecture:**
```
Docker Image Structure (Bottom to Top)
├── Base Layer (OS fundamentals - Ubuntu, Alpine, etc.)
├── Runtime Layer (Node.js, Python, Java runtime)
├── Dependencies Layer (npm packages, pip modules)
├── Application Layer (your code and configuration)
└── Configuration Layer (environment variables, startup commands)
```

**How Layers Work:**
- **Read-Only**: Each layer is immutable once created
- **Stacked**: Layers build upon each other using Union File System
- **Shared**: Multiple images can share common base layers
- **Cached**: Docker reuses layers to speed up builds and downloads
- **Efficient**: Only changed layers need to be updated or transferred

**Business Impact of Layer Architecture:**
- **Storage Savings**: 70-90% reduction in disk usage through layer sharing
- **Network Efficiency**: Only new/changed layers transfer during updates
- **Build Speed**: Layer caching reduces build times from minutes to seconds
- **Deployment Speed**: Faster container startup due to pre-cached layers

---

## 🖼️ docker images - List and Inspect Images

### **Understanding Image Listing (Progressive Learning)**

#### **Level 1: Basic Image Inventory**

**Simple Image Listing:**
```bash
# List all locally stored images
docker images
```

**What This Command Does:**
1. **Queries Docker Daemon**: Requests list of all local images
2. **Reads Image Database**: Scans Docker's internal image storage
3. **Formats Output**: Presents human-readable table format
4. **Shows Metadata**: Displays key information for each image

**Expected Output Analysis:**
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               alpine              bef258acf10d        2 weeks ago         23.4MB
nginx               latest              605c77e624dd        2 weeks ago         141MB
ubuntu              20.04               ba6acccedd29        4 weeks ago         72.8MB
hello-world         latest              feb5d9fea6a5        16 months ago       13.3kB
```

**Column-by-Column Explanation:**

**REPOSITORY (Image Name):**
- **Purpose**: Human-readable name for the image
- **Format**: Usually follows `organization/application` pattern
- **Examples**: `nginx` (official), `mycompany/webapp` (custom)
- **Business Value**: Easy identification and organization of applications

**TAG (Version/Variant):**
- **Purpose**: Specific version or configuration variant
- **Common Tags**: `latest` (newest), `alpine` (minimal), `1.21.0` (specific version)
- **Best Practice**: Always use specific tags in production (never `latest`)
- **Business Impact**: Version control prevents unexpected updates breaking systems

**IMAGE ID (Unique Identifier):**
- **Format**: First 12 characters of SHA256 hash
- **Purpose**: Absolute unique identification (no naming conflicts)
- **Immutability**: Same ID always refers to identical image content
- **Use Cases**: Precise image referencing in automation scripts

**CREATED (Build Date):**
- **Information**: When image was originally built (not downloaded)
- **Security Relevance**: Older images may have security vulnerabilities
- **Maintenance**: Helps identify images needing updates
- **Compliance**: Important for audit trails and change management

**SIZE (Storage Usage):**
- **Measurement**: Compressed image size on disk
- **Optimization Target**: Smaller images = faster deployment
- **Cost Impact**: Directly affects storage costs and transfer times
- **Performance**: Smaller images start containers faster

#### **Level 2: Advanced Image Listing and Filtering**

**Complete Command Syntax:**
```bash
docker images [OPTIONS] [REPOSITORY[:TAG]]
```

**All Available Options with Business Context:**
```bash
-a, --all             # Show all images (including intermediate build layers)
--digests            # Show cryptographic digests for security verification
-f, --filter filter   # Filter output based on conditions (automation-friendly)
--format string      # Custom output formatting for scripts and reports
--no-trunc          # Show full image IDs and names (for precise identification)
-q, --quiet         # Only show image IDs (perfect for scripting)
```

**Advanced Listing Examples:**

**Show All Images (Including Build Intermediates):**
```bash
# Display intermediate layers and dangling images
docker images -a
```

**Expected Output Analysis:**
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               alpine              bef258acf10d        2 weeks ago         23.4MB
<none>              <none>              abc123def456        2 weeks ago         20.1MB
nginx               latest              605c77e624dd        2 weeks ago         141MB
<none>              <none>              def456ghi789        2 weeks ago         135MB
ubuntu              20.04               ba6acccedd29        4 weeks ago         72.8MB
```

**Understanding `<none>` Images:**
- **Intermediate Layers**: Created during multi-stage builds, not directly usable
- **Dangling Images**: Untagged images from previous builds or failed operations
- **Storage Impact**: Can consume significant disk space if not cleaned regularly
- **Cleanup Strategy**: Use `docker image prune` to remove unused intermediates
- **Business Value**: Understanding helps optimize storage costs and build processes

**Security-Focused Listing with Digests:**
```bash
# Show cryptographic digests for image verification
docker images --digests
```

**Expected Output:**
```
REPOSITORY    TAG       DIGEST                                                                    IMAGE ID       CREATED       SIZE
nginx         alpine    sha256:2d194b392dd16955b2e95c7f4b1b3f0915d4c2e8e8c8f5b8a9c7d6e5f4g3h2i1    bef258acf10d   2 weeks ago   23.4MB
```

**Why Digests Matter:**
- **Security Verification**: Ensures image hasn't been tampered with
- **Compliance**: Required for security audits and regulatory compliance
- **Supply Chain Security**: Verifies image authenticity from registry
- **Production Safety**: Guarantees exact same image across environments

#### **Level 3: Filtering and Automation-Ready Commands**

**Filter by Repository (Specific Application Focus):**
```bash
# Show only nginx images
docker images nginx

# Show specific repository and tag
docker images nginx:alpine

# Show all images from specific organization
docker images mycompany/*
```

**Filter by Conditions (Advanced Automation):**
```bash
# Show images created before specific date
docker images --filter "before=nginx:latest"

# Show images created after specific date  
docker images --filter "since=ubuntu:20.04"

# Show dangling images (untagged)
docker images --filter "dangling=true"

# Show images with specific label
docker images --filter "label=maintainer=mycompany"
```

**Business Applications of Filtering:**
- **Security Audits**: Identify old images needing updates
- **Storage Management**: Find unused images consuming space
- **Compliance Reporting**: Generate reports for specific image sets
- **Automation**: Script-friendly commands for CI/CD pipelines

**Custom Formatting for Reports and Automation:**
```bash
# Show only repository and tag (clean output)
docker images --format "table {{.Repository}}\\t{{.Tag}}\\t{{.Size}}"

# JSON format for API integration
docker images --format "{{json .}}"

# Custom format for monitoring systems
docker images --format "{{.Repository}}:{{.Tag}} - {{.Size}} - {{.CreatedSince}}"
```

**Expected Custom Format Output:**
```
REPOSITORY      TAG        SIZE
nginx           alpine     23.4MB
nginx           latest     141MB
ubuntu          20.04      72.8MB
```

**Quiet Mode for Scripting:**
```bash
# Get only image IDs (perfect for automation)
docker images -q

# Expected output:
# bef258acf10d
# 605c77e624dd
# ba6acccedd29

# Practical automation example:
# Remove all images
docker rmi $(docker images -q)

# Remove specific filtered images
docker rmi $(docker images --filter "dangling=true" -q)
```

**Business Value of Advanced Listing:**
- **Operational Efficiency**: Quick identification of specific images
- **Cost Optimization**: Identify storage waste and cleanup opportunities
- **Security Management**: Track image ages and update requirements
- **Automation Integration**: Script-friendly output for CI/CD systems
- **Compliance Reporting**: Generate audit trails and inventory reports
```bash
# Show only nginx images
docker images nginx

# Show specific tag
docker images nginx:alpine
```

**Expected Output:**
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               alpine              bef258acf10d        2 weeks ago         23.4MB
```

**Filter by Dangling Images:**
```bash
# Show untagged images
docker images --filter "dangling=true"
```

**Expected Output:**
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              abc123def456        2 weeks ago         20.1MB
<none>              <none>              def456ghi789        2 weeks ago         135MB
```

**Filter by Creation Time:**
```bash
# Show images created before specific image
docker images --filter "before=nginx:alpine"

# Show images created after specific image
docker images --filter "since=ubuntu:20.04"
```

**Custom Format Output:**
```bash
# Custom format showing repository, tag, and size
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

**Expected Output:**
```
REPOSITORY          TAG                 SIZE
nginx               alpine              23.4MB
nginx               latest              141MB
ubuntu              20.04               72.8MB
```

**Available Format Variables:**
- `.ID`: Image ID
- `.Repository`: Repository name
- `.Tag`: Image tag
- `.Digest`: Image digest
- `.CreatedSince`: Time since created
- `.CreatedAt`: Creation timestamp
- `.Size`: Image size

**Show Image Digests:**
```bash
# Include SHA256 digests
docker images --digests
```

**Expected Output:**
```
REPOSITORY          TAG                 DIGEST                                                                    IMAGE ID            CREATED             SIZE
nginx               alpine              sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e   bef258acf10d        2 weeks ago         23.4MB
```

---

## ⬇️ docker pull - Download Images from Registries

### **Understanding Image Pulling: The Foundation of Container Deployment**

**What docker pull Does:**
Docker pull downloads images from registries (repositories) to your local machine. This is essential because:
- **Containers require images**: You can't run containers without local images
- **Registry distribution**: Images are stored centrally and distributed on-demand
- **Version control**: Pull specific versions for consistent deployments
- **Dependency management**: Automatically handles image layers and dependencies

**The Complete Pull Process:**
```
docker pull nginx
     ↓
1. Resolves image name to full registry path (docker.io/library/nginx:latest)
2. Connects to registry (Docker Hub by default)
3. Downloads image manifest (metadata about layers)
4. Downloads each layer (only if not already cached locally)
5. Verifies layer integrity using SHA256 checksums
6. Assembles layers into complete image
7. Tags image in local storage
8. Returns success confirmation
```

**Business Impact of Image Pulling:**
- **Deployment Speed**: Pre-pulled images enable instant container startup
- **Bandwidth Optimization**: Layer caching reduces network usage by 60-80%
- **Reliability**: Verified downloads ensure image integrity
- **Version Control**: Specific tags enable consistent deployments across environments

### **Command Syntax and Options**
```bash
docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```

**Available Options with Business Context:**
```bash
-a, --all-tags                # Download all tagged images in repository
--disable-content-trust       # Skip image verification (default: true)
--platform string            # Set platform for multi-architecture images
-q, --quiet                   # Suppress verbose output (automation-friendly)
```

### **Progressive Learning: Simple to Advanced Pulling**

#### **Level 1: Basic Image Downloading**

**Simple Pull (Latest Version):**
```bash
# Pull latest version of nginx
docker pull nginx
```

**Step-by-Step Process Analysis:**
```
Using default tag: latest
latest: Pulling from library/nginx
a2abf6c4d29d: Pull complete 
a9edb18cadd1: Pull complete 
589b7251471a: Pull complete 
186b1aaa4aa6: Pull complete 
b4c0378c841a: Pull complete 
Digest: sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

**Output Explanation Line-by-Line:**
- **"Using default tag: latest"**: No tag specified, Docker assumes `:latest`
- **"latest: Pulling from library/nginx"**: Downloading from official nginx repository
- **"a2abf6c4d29d: Pull complete"**: Each line represents a layer being downloaded
- **"Digest: sha256:..."**: Cryptographic fingerprint of the complete image
- **"Status: Downloaded newer image"**: Confirms successful download
- **"docker.io/library/nginx:latest"**: Full image reference including registry

#### **Level 2: Specific Version Management**

**Pull Specific Version (Production Best Practice):**
```bash
# Pull specific nginx version (recommended for production)
docker pull nginx:1.23-alpine
```

**Why Specific Tags Are Critical:**
- **Predictability**: Same tag always refers to same image content
- **Security**: Avoid unexpected updates that might introduce vulnerabilities
- **Compliance**: Audit trails require specific version tracking
- **Rollback**: Easy to revert to known-good versions

#### **Level 3: Advanced Pulling Strategies**

**Pull by Digest (Maximum Security):**
```bash
# Pull exact image using cryptographic digest
docker pull nginx@sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
```

**Multi-Platform Pulling:**
```bash
# Pull for specific CPU architecture
docker pull --platform linux/amd64 nginx:alpine  # Intel/AMD 64-bit
docker pull --platform linux/arm64 nginx:alpine  # ARM 64-bit (Apple M1, AWS Graviton)
```

**Registry-Specific Pulling:**
```bash
# Pull from different registries
docker pull gcr.io/google-containers/nginx:latest
docker pull mycompany.registry.com:5000/internal-app:latest
```

**Quiet Mode for Automation:**
```bash
# Suppress verbose output (perfect for scripts)
docker pull -q nginx:alpine
```

**Expected Output:**
```
Using default tag: latest
latest: Pulling from library/nginx
a2abf6c4d29d: Pull complete 
a9edb18cadd1: Pull complete 
589b7251471a: Pull complete 
186b1aaa4aa6: Pull complete 
b4df32aa5a72: Pull complete 
a0bcbecc962e: Pull complete 
Digest: sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

**Output Explanation:**
- **Using default tag: latest**: No tag specified, defaulted to latest
- **Pull complete**: Each layer downloaded successfully
- **Digest**: SHA256 hash of the image manifest
- **Status**: Confirmation of successful download
- **docker.io/library/nginx:latest**: Full image name with registry

**Pull Specific Tag:**
```bash
# Pull specific version
docker pull nginx:1.23-alpine
```

**Expected Output:**
```
1.23-alpine: Pulling from library/nginx
63b65145d645: Pull complete 
fce3d4d00afa: Pull complete 
7db8b8c62e8d: Pull complete 
3cd0b96ae4c8: Pull complete 
b2b7a5399b5f: Pull complete 
5b7d4bb5e4b7: Pull complete 
Digest: sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Downloaded newer image for nginx:1.23-alpine
docker.io/library/nginx:1.23-alpine
```

**Pull by Digest:**
```bash
# Pull specific image by SHA256 digest
docker pull nginx@sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
```

**Pull All Tags:**
```bash
# Pull all available tags for repository
docker pull -a nginx
```

**Expected Output:**
```
latest: Pulling from library/nginx
Digest: sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Image is up to date for nginx:latest
alpine: Pulling from library/nginx
Digest: sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Downloaded newer image for nginx:alpine
1.23: Pulling from library/nginx
...
```

**Pull from Different Registry:**
```bash
# Pull from specific registry
docker pull gcr.io/google-containers/nginx:latest

# Pull from private registry
docker pull myregistry.com:5000/myapp:v1.0
```

**Platform-Specific Pull:**
```bash
# Pull for specific platform (useful for ARM/x86)
docker pull --platform linux/amd64 nginx:alpine
docker pull --platform linux/arm64 nginx:alpine
```

**Quiet Pull:**
```bash
# Suppress verbose output
docker pull -q nginx:alpine
```

**Expected Output:**
```
docker.io/library/nginx:alpine
```

---

## 🏷️ docker tag - Tag Images

### Syntax
```bash
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
```

### Detailed Examples

**Basic Tagging:**
```bash
# Tag existing image with new name
docker tag nginx:alpine my-nginx:v1.0

# Verify new tag
docker images | grep my-nginx
```

**Expected Output:**
```
my-nginx            v1.0                bef258acf10d        2 weeks ago         23.4MB
```

**Tag for Different Registry:**
```bash
# Tag for pushing to different registry
docker tag nginx:alpine myregistry.com/nginx:alpine

# Tag for Docker Hub with username
docker tag nginx:alpine myusername/nginx:custom
```

**Multiple Tags for Same Image:**
```bash
# Create multiple tags for same image
docker tag nginx:alpine my-app:latest
docker tag nginx:alpine my-app:v1.0
docker tag nginx:alpine my-app:stable

# Verify all tags point to same image ID
docker images | grep bef258acf10d
```

**Expected Output:**
```
nginx               alpine              bef258acf10d        2 weeks ago         23.4MB
my-app              latest              bef258acf10d        2 weeks ago         23.4MB
my-app              v1.0                bef258acf10d        2 weeks ago         23.4MB
my-app              stable              bef258acf10d        2 weeks ago         23.4MB
```

---

## 🗑️ docker rmi - Remove Images

### Syntax
```bash
docker rmi [OPTIONS] IMAGE [IMAGE...]
```

### All Available Options
```bash
-f, --force      Force removal of the image
--no-prune      Do not delete untagged parents
```

### Detailed Examples

**Remove Single Image:**
```bash
# Remove image by name:tag
docker rmi nginx:alpine
```

**Expected Output:**
```
Untagged: nginx:alpine
Untagged: nginx@sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Deleted: sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Deleted: sha256:abc123def456789012345678901234567890123456789012345678901234567890
```

**Output Explanation:**
- **Untagged**: Removed tag references
- **Deleted**: Removed image layers (only if no other tags reference them)

**Remove by Image ID:**
```bash
# Remove using image ID
docker rmi bef258acf10d
```

**Force Remove (with containers):**
```bash
# Force remove even if containers exist
docker rmi -f nginx:alpine
```

**Expected Output:**
```
Untagged: nginx:alpine
Deleted: sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
```

**Remove Multiple Images:**
```bash
# Remove multiple images at once
docker rmi nginx:alpine ubuntu:20.04 hello-world:latest
```

**Remove All Dangling Images:**
```bash
# Remove untagged images
docker rmi $(docker images -f "dangling=true" -q)
```

**Remove All Images:**
```bash
# Remove all images (dangerous!)
docker rmi $(docker images -q)
```

---

## 🔍 docker inspect - Detailed Image Information

### Syntax
```bash
docker inspect [OPTIONS] NAME|ID [NAME|ID...]
```

### All Available Options
```bash
-f, --format string   Format the output using the given Go template
-s, --size           Display total file sizes if the type is container
--type string        Return JSON for specified type (container|image|node|network|secret|service|volume|task|plugin)
```

### Detailed Examples

**Basic Image Inspection:**
```bash
# Get complete image information
docker inspect nginx:alpine
```

**Expected Output (Abbreviated):**
```json
[
    {
        "Id": "sha256:bef258acf10dc257d9dc5b4c4b5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e",
        "RepoTags": [
            "nginx:alpine"
        ],
        "RepoDigests": [
            "nginx@sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2024-01-01T10:30:45.123456789Z",
        "Container": "abc123def456789012345678901234567890123456789012345678901234567890",
        "ContainerConfig": {
            "Hostname": "abc123def456",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.23.3",
                "NJS_VERSION=0.7.9",
                "PKG_RELEASE=1"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) ",
                "CMD [\"nginx\" \"-g\" \"daemon off;\"]"
            ],
            "Image": "sha256:def456ghi789012345678901234567890123456789012345678901234567890123",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            }
        },
        "DockerVersion": "20.10.21",
        "Author": "",
        "Config": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.23.3",
                "NJS_VERSION=0.7.9",
                "PKG_RELEASE=1"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "Image": "sha256:def456ghi789012345678901234567890123456789012345678901234567890123",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            }
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 23456789,
        "VirtualSize": 23456789,
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/abc123def456/diff:/var/lib/docker/overlay2/def456ghi789/diff",
                "MergedDir": "/var/lib/docker/overlay2/ghi789jkl012/merged",
                "UpperDir": "/var/lib/docker/overlay2/ghi789jkl012/diff",
                "WorkDir": "/var/lib/docker/overlay2/ghi789jkl012/work"
            },
            "Name": "overlay2"
        },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:layer1hash",
                "sha256:layer2hash",
                "sha256:layer3hash",
                "sha256:layer4hash",
                "sha256:layer5hash",
                "sha256:layer6hash"
            ]
        },
        "Metadata": {
            "LastTagTime": "2024-01-15T10:30:45.123456789Z"
        }
    }
]
```

**Key Information Explained:**
- **Id**: Full SHA256 image ID
- **RepoTags**: All tags pointing to this image
- **Created**: When image was built
- **Config**: Runtime configuration (environment, command, etc.)
- **Architecture**: CPU architecture (amd64, arm64, etc.)
- **Size**: Compressed image size
- **RootFS.Layers**: Individual layer hashes

**Extract Specific Information:**
```bash
# Get only environment variables
docker inspect --format='{{.Config.Env}}' nginx:alpine
```

**Expected Output:**
```
[PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin NGINX_VERSION=1.23.3 NJS_VERSION=0.7.9 PKG_RELEASE=1]
```

**Get Image Architecture:**
```bash
# Check image architecture
docker inspect --format='{{.Architecture}}' nginx:alpine
```

**Expected Output:**
```
amd64
```

**Get Image Layers:**
```bash
# List all layers
docker inspect --format='{{range .RootFS.Layers}}{{println .}}{{end}}' nginx:alpine
```

**Expected Output:**
```
sha256:layer1hash
sha256:layer2hash
sha256:layer3hash
sha256:layer4hash
sha256:layer5hash
sha256:layer6hash
```

---

## 📊 docker history - Image Layer History

### Syntax
```bash
docker history [OPTIONS] IMAGE
```

### All Available Options
```bash
--format string    Pretty-print images using a Go template
-H, --human        Print sizes and dates in human readable format (default true)
--no-trunc        Don't truncate output
-q, --quiet       Only show image IDs
```

### Detailed Examples

**Basic History:**
```bash
# Show image build history
docker history nginx:alpine
```

**Expected Output:**
```
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
bef258acf10d        2 weeks ago         /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…   0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  STOPSIGNAL SIGQUIT           0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  EXPOSE 80                    0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  ENTRYPOINT ["/docker-entr…   0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop) COPY file:abc123def456789…    4.61kB              
<missing>           2 weeks ago         /bin/sh -c #(nop) COPY file:def456ghi789012…    1.04kB              
<missing>           2 weeks ago         /bin/sh -c set -x     && addgroup -g 101 -S…    17.8MB              
<missing>           2 weeks ago         /bin/sh -c #(nop)  ENV PKG_RELEASE=1             0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  ENV NJS_VERSION=0.7.9         0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  ENV NGINX_VERSION=1.23.3      0B                  
<missing>           2 weeks ago         /bin/sh -c #(nop)  LABEL maintainer=NGINX Do…    0B                  
<missing>           4 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]               0B                  
<missing>           4 weeks ago         /bin/sh -c #(nop) ADD file:ghi789jkl012345…      5.54MB
```

**Column Explanations:**
- **IMAGE**: Layer ID (only top layer shows full ID)
- **CREATED**: When layer was created
- **CREATED BY**: Dockerfile instruction that created layer
- **SIZE**: Size added by this layer
- **COMMENT**: Additional information

**Show Full Commands:**
```bash
# Don't truncate command output
docker history --no-trunc nginx:alpine
```

**Custom Format:**
```bash
# Show only size and command
docker history --format "table {{.Size}}\t{{.CreatedBy}}" nginx:alpine
```

**Expected Output:**
```
SIZE                CREATED BY
0B                  /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon off;"]
0B                  /bin/sh -c #(nop)  STOPSIGNAL SIGQUIT
0B                  /bin/sh -c #(nop)  EXPOSE 80
17.8MB              /bin/sh -c set -x     && addgroup -g 101 -S nginx
5.54MB              /bin/sh -c #(nop) ADD file:ghi789jkl012345678901234567890123456789012345678901234567890 in /
```

---

## 🧹 Image Cleanup Commands

### docker image prune - Remove Unused Images

**Syntax:**
```bash
docker image prune [OPTIONS]
```

**Options:**
```bash
-a, --all             Remove all unused images, not just dangling ones
--filter filter       Provide filter values (e.g. 'until=<timestamp>')
-f, --force          Do not prompt for confirmation
```

**Examples:**

**Remove Dangling Images:**
```bash
# Remove untagged images
docker image prune
```

**Expected Output:**
```
WARNING! This will remove all dangling images.
Are you sure you want to continue? [y/N] y
Deleted Images:
deleted: sha256:abc123def456789012345678901234567890123456789012345678901234567890
deleted: sha256:def456ghi789012345678901234567890123456789012345678901234567890123

Total reclaimed space: 45.2MB
```

**Remove All Unused Images:**
```bash
# Remove all images not used by containers
docker image prune -a
```

**Force Remove Without Confirmation:**
```bash
# Skip confirmation prompt
docker image prune -f
```

**Remove Images Older Than 24 Hours:**
```bash
# Remove images created more than 24 hours ago
docker image prune --filter "until=24h"
```

---

## 🚀 Next Steps

You now have complete mastery of Docker image management:

- ✅ **docker images**: List and filter images with all options
- ✅ **docker pull**: Download images with platform and registry options
- ✅ **docker tag**: Create image tags and aliases
- ✅ **docker rmi**: Remove images safely and forcefully
- ✅ **docker inspect**: Extract detailed image information
- ✅ **docker history**: Understand image layer structure
- ✅ **docker image prune**: Clean up unused images

**Ready for Part 3: Container Execution and Debugging** where you'll master docker exec, logs, and advanced container operations!
