# 💻 Command Line Mastery: Complete Theory Guide

## 🎯 Learning Objectives
By the end of this section, you will understand:
- What the command line is and why it's essential for Docker
- The anatomy of command line interfaces
- How commands work internally
- The relationship between GUI and CLI
- Essential command patterns and concepts

---

## 📚 What is the Command Line?

### Definition
The **command line interface (CLI)** is a text-based way to interact with your computer. Instead of clicking buttons and icons, you type commands that tell the computer exactly what to do.

### Historical Context
Before graphical user interfaces (GUIs) existed, the command line was the ONLY way to use computers. Even today, it remains the most powerful and efficient way to:
- Automate repetitive tasks
- Manage servers and cloud infrastructure
- Develop and deploy software
- Work with Docker containers

### GUI vs CLI Comparison

#### Graphical User Interface (GUI)
```
User Action: Click "New Folder" button
What happens internally:
1. Mouse click detected at coordinates (x, y)
2. GUI determines which button was clicked
3. GUI calls the underlying system function
4. System creates folder
5. GUI updates display to show new folder
```

#### Command Line Interface (CLI)
```
User Action: Type "mkdir new-folder"
What happens internally:
1. Shell parses the command
2. Shell directly calls system function
3. System creates folder
4. Shell reports success/failure
```

**Key Difference:** CLI is direct communication with the system, while GUI is an intermediary layer.

---

## 🏗️ Command Line Architecture

### The Shell: Your Command Interpreter

#### What is a Shell?
A **shell** is a program that:
- Takes your typed commands
- Interprets what you mean
- Executes the appropriate system functions
- Returns results to you

#### Popular Shells

##### Bash (Bourne Again Shell)
```
Default on: Linux, macOS, Windows Subsystem for Linux
Strengths: 
- Powerful scripting capabilities
- Extensive history and documentation
- Wide compatibility
- Rich feature set for automation
```

##### PowerShell
```
Default on: Windows
Strengths:
- Object-oriented (not just text)
- Deep Windows integration
- Powerful scripting language
- .NET framework integration
```

##### Zsh (Z Shell)
```
Default on: macOS (newer versions)
Strengths:
- Enhanced auto-completion
- Better customization
- Improved history search
- Plugin ecosystem
```

### Command Anatomy

#### Basic Structure
```
command [options] [arguments]
   ↓        ↓         ↓
  What    How      What to act on
```

#### Detailed Breakdown
```bash
ls -la /home/user/documents
│  │   │
│  │   └── Argument: What directory to list
│  └────── Options: -l (long format), -a (show hidden files)
└───────── Command: List directory contents
```

#### Real-World Example
```bash
docker run -d -p 8080:80 --name web-server nginx
│     │   │  │        │              │
│     │   │  │        │              └── Argument: Image name
│     │   │  │        └─────────────────── Option: Container name
│     │   │  └──────────────────────────── Option: Port mapping
│     │   └─────────────────────────────── Option: Detached mode
│     └─────────────────────────────────── Subcommand: Run container
└───────────────────────────────────────── Main command: Docker
```

---

## 🔍 How Commands Work Internally

### Command Execution Process

#### Step 1: Command Parsing
```
Input: "ls -la /home"
Shell breaks this into:
- Command: "ls"
- Options: "-la"
- Arguments: "/home"
```

#### Step 2: Command Location
```
Shell searches for "ls" command in:
1. Built-in commands (internal to shell)
2. Aliases (user-defined shortcuts)
3. Functions (user-defined functions)
4. PATH directories (system locations)
```

#### Step 3: PATH Resolution
```
PATH=/usr/local/bin:/usr/bin:/bin
Shell checks:
1. /usr/local/bin/ls (not found)
2. /usr/bin/ls (not found)
3. /bin/ls (found!)
```

#### Step 4: Process Creation
```
Shell creates new process:
1. Fork: Create copy of shell process
2. Exec: Replace copy with "ls" program
3. Wait: Shell waits for "ls" to complete
4. Return: "ls" exits, shell continues
```

#### Step 5: Output Handling
```
"ls" program:
1. Reads directory contents
2. Formats output according to options
3. Writes to stdout (standard output)
4. Shell displays stdout to terminal
```

### Environment Variables

#### What are Environment Variables?
Environment variables are named values that programs can access. Think of them as global settings that all programs can read.

#### Common Environment Variables
```bash
PATH=/usr/local/bin:/usr/bin:/bin
HOME=/home/username
USER=username
SHELL=/bin/bash
LANG=en_US.UTF-8
```

#### How Programs Use Environment Variables
```python
# Python example
import os
home_directory = os.environ['HOME']
current_user = os.environ['USER']
```

#### Docker and Environment Variables
```bash
# Setting environment variables for Docker containers
docker run -e DATABASE_URL=postgresql://localhost:5432/mydb myapp
```

---

## 📁 File System Navigation Deep Dive

### File System Hierarchy

#### Unix/Linux File System
```
/ (root)
├── bin/          # Essential system binaries
├── etc/          # System configuration files
├── home/         # User home directories
│   └── username/ # Your personal directory
├── usr/          # User programs and data
│   ├── bin/      # User binaries
│   └── local/    # Locally installed software
├── var/          # Variable data (logs, databases)
└── tmp/          # Temporary files
```

#### Windows File System
```
C:\ (C drive)
├── Program Files\     # Installed applications
├── Program Files (x86)\ # 32-bit applications
├── Users\            # User profiles
│   └── Username\     # Your personal directory
├── Windows\          # Operating system files
└── ProgramData\      # Application data
```

### Path Types

#### Absolute Paths
```bash
# Linux/Mac
/home/user/documents/file.txt
/usr/local/bin/docker

# Windows
C:\Users\User\Documents\file.txt
C:\Program Files\Docker\docker.exe
```

**Characteristics:**
- Start from the root of the file system
- Always work regardless of current location
- Longer to type but unambiguous

#### Relative Paths
```bash
# From /home/user/
documents/file.txt        # Go into documents folder
../other-user/file.txt    # Go up one level, then into other-user
./current-folder/file.txt # Explicitly reference current directory
```

**Characteristics:**
- Relative to your current location
- Shorter to type
- Can break if you change directories

### Special Directory References
```bash
.     # Current directory
..    # Parent directory
~     # Home directory
-     # Previous directory (in cd command)
```

---

## 🔧 Essential Command Categories

### File Operations

#### Viewing Files
```bash
cat filename.txt      # Display entire file
less filename.txt     # Display file page by page
head filename.txt     # Display first 10 lines
tail filename.txt     # Display last 10 lines
tail -f filename.txt  # Follow file as it grows (great for logs)
```

**When to use each:**
- `cat`: Small files you want to see completely
- `less`: Large files you want to browse
- `head`: Check the beginning of a file
- `tail`: Check the end of a file or monitor logs
- `tail -f`: Watch log files in real-time

#### File Manipulation
```bash
cp source.txt dest.txt           # Copy file
cp -r source-dir/ dest-dir/      # Copy directory recursively
mv oldname.txt newname.txt       # Move/rename file
rm filename.txt                  # Delete file
rm -rf directory/                # Delete directory and contents
```

**Safety Tips:**
- Always double-check `rm` commands
- Use `ls` to verify before deleting
- Consider using `mv` to "delete" (move to trash folder)

### Process Management

#### Viewing Processes
```bash
ps aux                    # Show all running processes
ps aux | grep docker      # Find Docker-related processes
top                       # Real-time process monitor
htop                      # Enhanced process monitor (if installed)
```

#### Process Control
```bash
command &                 # Run command in background
jobs                      # List background jobs
fg %1                     # Bring job 1 to foreground
bg %1                     # Send job 1 to background
kill PID                  # Terminate process by ID
kill -9 PID               # Force kill process
killall process-name      # Kill all processes with name
```

### Text Processing

#### Searching
```bash
grep "pattern" file.txt           # Find lines containing pattern
grep -r "pattern" directory/      # Search recursively in directory
grep -i "pattern" file.txt        # Case-insensitive search
grep -n "pattern" file.txt        # Show line numbers
```

#### Filtering and Sorting
```bash
sort file.txt                     # Sort lines alphabetically
sort -n file.txt                  # Sort numerically
uniq file.txt                     # Remove duplicate lines
wc file.txt                       # Count lines, words, characters
wc -l file.txt                    # Count only lines
```

---

## 🔗 Pipes and Redirection: The Power of Combination

### Understanding Pipes

#### What is a Pipe?
A **pipe** (`|`) connects the output of one command to the input of another command. It's like connecting water pipes - data flows from one command to the next.

#### Visual Representation
```
Command A → | → Command B → | → Command C → Output
```

#### Real Examples
```bash
# Count how many .txt files are in current directory
ls *.txt | wc -l

# Find all Docker processes and count them
ps aux | grep docker | wc -l

# Show the 10 largest files in current directory
ls -la | sort -k5 -n | tail -10
```

### Redirection

#### Output Redirection
```bash
command > file.txt        # Redirect output to file (overwrite)
command >> file.txt       # Redirect output to file (append)
command 2> error.log      # Redirect errors to file
command > output.txt 2>&1 # Redirect both output and errors
```

#### Input Redirection
```bash
command < input.txt       # Use file as input to command
```

#### Practical Examples
```bash
# Save directory listing to file
ls -la > directory-contents.txt

# Append current date to log file
date >> activity.log

# Save Docker container list
docker ps > running-containers.txt

# Run command and save both output and errors
docker build . > build.log 2>&1
```

---

## 🎯 Why Command Line is Essential for Docker

### Docker is CLI-First
Docker was designed as a command-line tool. While GUI tools exist, the CLI is:
- More powerful
- More flexible
- Better for automation
- Industry standard

### Common Docker Command Patterns
```bash
# Basic pattern
docker [command] [options] [arguments]

# Examples
docker run -d -p 8080:80 nginx
docker build -t myapp .
docker logs container-name
docker exec -it container-name bash
```

### Automation and Scripting
```bash
#!/bin/bash
# Deploy script
docker build -t myapp .
docker stop myapp-container || true
docker rm myapp-container || true
docker run -d --name myapp-container -p 8080:80 myapp
echo "Deployment complete!"
```

### Integration with CI/CD
```yaml
# GitLab CI example
deploy:
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker run -d $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

---

## 🧠 Mental Models for Command Line Success

### Think in Terms of Data Flow
```
Input → Process → Output
  ↓        ↓        ↓
Files   Commands   Files
Pipes   Programs   Screen
User    Scripts    Network
```

### Command Composition
Instead of thinking about individual commands, think about combining them:
```bash
# Instead of: "How do I find large files?"
# Think: "List files" + "Sort by size" + "Show largest"
ls -la | sort -k5 -n | tail -10
```

### Pattern Recognition
Many commands follow similar patterns:
```bash
# Pattern: command -options target
ls -la directory/
cp -r source/ destination/
rm -rf unwanted-directory/
docker run -d -p 8080:80 nginx
```

---

## 🚀 Next Steps

You now understand:
- What the command line is and why it's powerful
- How commands work internally
- Essential command categories and patterns
- Why CLI skills are crucial for Docker

Ready for **Module 1, Part 3: Command Line Practice** where you'll get hands-on experience with all these concepts!
