# Interactive Labs - Module 00

## Lab 1: CAP Theorem Simulation
**Duration**: 45 minutes

### Setup
```bash
# Clone the CAP theorem simulator
git clone https://github.com/system-design-tutorial/cap-simulator.git
cd cap-simulator
docker-compose up -d
```

### Exercise Steps
1. **Consistency Test**: Simulate network partition and observe data consistency
2. **Availability Test**: Test system availability during node failures
3. **Partition Tolerance**: Create network splits and measure system behavior

### Expected Outcomes
- Understand CP vs AP trade-offs through hands-on experience
- Measure consistency lag in distributed systems
- Observe availability impact during partitions

## Lab 2: AWS Well-Architected Review
**Duration**: 60 minutes

### Setup
```bash
# Install AWS CLI and configure
aws configure
aws wellarchitected create-workload --workload-name "lab-workload"
```

### Exercise Steps
1. **Create Workload**: Define a simple web application workload
2. **Answer Questions**: Complete Well-Architected review questions
3. **Generate Report**: Create improvement recommendations
4. **Implement Fix**: Address one high-risk item

### Deliverables
- Well-Architected review report
- Risk mitigation plan
- Implementation of one improvement

## Lab 3: Requirements Analysis Workshop
**Duration**: 90 minutes

### Scenario
Design requirements for a social media platform with 1M users.

### Interactive Elements
1. **Stakeholder Interviews**: Role-play with different personas
2. **Requirements Prioritization**: Use MoSCoW method
3. **Constraint Analysis**: Identify technical and business constraints
4. **Trade-off Matrix**: Create decision framework

### Tools Provided
- Requirements template
- Stakeholder persona cards
- Constraint analysis worksheet
- Trade-off decision matrix

## Lab 4: Architecture Decision Records (ADR) Practice
**Duration**: 45 minutes

### Exercise
Create ADRs for technology choices in a microservices architecture.

### Interactive Components
1. **Decision Context**: Analyze given business scenario
2. **Options Evaluation**: Compare 3-4 technology options
3. **ADR Creation**: Write formal architecture decision record
4. **Peer Review**: Review and provide feedback on ADRs

### Templates Provided
- ADR template with examples
- Technology comparison matrix
- Decision criteria checklist
