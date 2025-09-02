# 🎓 Module 1 Completion Assessment

## 📋 Knowledge Check

### Theory Questions (Answer each)

1. **What is the difference between a program and a process?**
   - Your answer: ________________

2. **What are the 4 layers of the TCP/IP model?**
   - Layer 1: ________________
   - Layer 2: ________________
   - Layer 3: ________________
   - Layer 4: ________________

3. **What does the command `docker run -p 8080:80 nginx` do?**
   - Your answer: ________________

### Practical Skills Test

#### Test 1: Command Line Mastery
Complete these tasks:
```bash
# 1. Create directory structure
mkdir -p test/{src,docs,config}

# 2. Create files with content
echo "Hello World" > test/src/app.py
echo "# Documentation" > test/docs/README.md

# 3. Find all .py files
find test -name "*.py"

# 4. Count lines in all files
wc -l test/*/*.* 2>/dev/null
```

#### Test 2: Process Management
```bash
# 1. Start background process
sleep 300 &

# 2. Find its PID
ps aux | grep sleep

# 3. Kill it
kill %1
```

#### Test 3: Network Testing
```bash
# 1. Test connectivity
ping -c 3 8.8.8.8

# 2. Check open ports
netstat -tuln | head -10

# 3. Test HTTP connection
curl -I http://google.com
```

## 🏆 Final Project: System Monitor

Create a comprehensive system monitoring script:

### Requirements
1. Check system resources (CPU, memory, disk)
2. Monitor network connectivity
3. List running processes
4. Generate report
5. Handle errors gracefully

### Template
```bash
#!/bin/bash
# System Monitor - Module 1 Final Project
# Name: ________________
# Date: ________________

echo "=== System Monitor Report ==="
echo "Generated: $(date)"
echo

# TODO: Implement each section
echo "=== System Resources ==="
# Your code here

echo "=== Network Status ==="
# Your code here

echo "=== Process Summary ==="
# Your code here

echo "=== Report Complete ==="
```

### Evaluation Criteria
- [ ] Script runs without errors
- [ ] All sections implemented
- [ ] Proper error handling
- [ ] Clear output formatting
- [ ] Code is well-commented

## ✅ Module 1 Checklist

Before proceeding to Module 2, ensure you can:

### Computer Programs Understanding
- [ ] Explain what programs and processes are
- [ ] Understand how programs communicate
- [ ] Know why Docker solves deployment problems

### Command Line Skills
- [ ] Navigate file system efficiently
- [ ] Create, modify, and delete files/directories
- [ ] Use pipes and redirection
- [ ] Manage processes (start, stop, monitor)
- [ ] Search and filter text data

### Networking Knowledge
- [ ] Understand IP addresses and ports
- [ ] Know common protocols (HTTP, TCP, UDP)
- [ ] Test network connectivity
- [ ] Troubleshoot basic network issues
- [ ] Understand client-server communication

### Problem-Solving Abilities
- [ ] Debug command line issues
- [ ] Read and interpret error messages
- [ ] Use documentation and help commands
- [ ] Break complex problems into steps

## 🚀 Ready for Module 2?

If you've completed all assessments and checked all boxes, you're ready for **Module 2: Docker Fundamentals**!

### What's Next
Module 2 will cover:
- Docker installation and setup
- Container lifecycle management
- Image creation and management
- Basic Docker networking
- Troubleshooting Docker issues

### Time Investment
- Module 1 completion: 15-20 hours
- Module 2 duration: 20-25 hours
- Total progress: 13% complete

**Congratulations on completing the foundation!** 🎉
