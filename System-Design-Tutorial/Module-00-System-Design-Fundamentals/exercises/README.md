# Module-00 Exercises and Assessment

## How to Use
- Pick one exercise per section (General + AWS) to complete
- Keep solutions in this folder using subfolders per exercise
- Diagrams can be ASCII in Markdown or links to draw.io files

## Section A: General Principles Exercises

1. System Context Mapping (C4 Level 1)
   - Deliverables: Context diagram, external dependencies list, assumptions
   - Criteria: Clear boundaries, key actors, top 5 risks

2. Requirements Analysis Deep Dive
   - Deliverables: Functional + NFR matrix, constraints list, acceptance criteria
   - Criteria: Traceability, clarity, measurable NFRs (latency, SLOs)

3. Quality Attribute Scenarios
   - Deliverables: 6 scenarios (perf, avail, sec, cost, operability, maintainability)
   - Criteria: Stimulus, environment, response, measure

4. CAP vs PACELC Trade-off Case
   - Deliverables: Decision memo for CP vs AP choice with PACELC rationale
   - Criteria: Business impact, data needs, risk analysis

5. Architecture Patterns Fit Matrix
   - Deliverables: Compare Monolith vs Microservices vs Serverless vs EDA
   - Criteria: Decision table with weighted scoring and justification

## Section B: AWS-Focused Exercises

1. Well-Architected Review (Paper Exercise)
   - Deliverables: Pillar-by-pillar risks (H/M/L), improvement plan
   - Criteria: Concrete actions, owners, timeline

2. AWS Account Baseline Plan
   - Deliverables: OU layout, IAM model, guardrails, logging plan
   - Criteria: Least privilege, separation of duties, audit readiness

3. Reference Architecture Draft
   - Deliverables: ASCII diagram + component list for web, serverless, or data stack
   - Criteria: Multi-AZ, cost-awareness, scaling and DR paths

4. Cost Model
   - Deliverables: Monthly cost estimate for dev/test/prod
   - Criteria: Right-sizing, savings plans/spot, lifecycle policies

5. Resilience Test Plan
   - Deliverables: Chaos scenarios, failover steps, recovery verification
   - Criteria: RTO/RPO validation and observability hooks

## Assessment Rubric (10 pts each)
- Completeness (2)
- Technical accuracy (2)
- Clarity and diagrams (2)
- Trade-off analysis (2)
- Practical feasibility (2)

## Submission
- Create subfolder per exercise: `/exercises/A1-context-diagram/`
- Include `README.md` with answers and any diagrams
- Link to any external diagram sources

## Solution Outlines

### Section A: General Principles Exercises

#### 1. System Context Mapping (C4 Level 1)
**Solution Outline**:
- Identify the system boundary and primary purpose
- Map external actors (users, external systems, administrators)
- Document key interactions and data flows
- List external dependencies and assumptions
- Identify top 5 risks and mitigation strategies
- Use C4 context diagram notation with clear boundaries

#### 2. Requirements Analysis Deep Dive
**Solution Outline**:
- Create functional requirements matrix with priority levels
- Define non-functional requirements with measurable criteria
- Document constraints (technical, business, regulatory)
- Establish acceptance criteria for each requirement
- Create traceability matrix linking requirements to design decisions
- Include performance targets (latency, throughput, availability)

#### 3. Quality Attribute Scenarios
**Solution Outline**:
- Define 6 scenarios covering different quality attributes
- Use the format: "When [stimulus], the system shall [response] within [measure]"
- Include performance, availability, security, cost, operability, maintainability
- Specify the environment and context for each scenario
- Provide measurable criteria for success
- Consider trade-offs between competing attributes

#### 4. CAP vs PACELC Trade-off Case
**Solution Outline**:
- Analyze the business requirements for consistency needs
- Evaluate availability requirements and downtime tolerance
- Assess partition tolerance requirements
- Apply PACELC framework for normal operation scenarios
- Document the decision rationale with business impact analysis
- Consider data types and access patterns in the decision
- Provide examples of when the opposite choice would be appropriate

#### 5. Architecture Patterns Fit Matrix
**Solution Outline**:
- Create a decision matrix comparing 4+ architecture patterns
- Define evaluation criteria with weights based on requirements
- Score each pattern against criteria (1-10 scale)
- Calculate weighted scores and rank patterns
- Document the rationale for the top choice
- Consider hybrid approaches and pattern combinations
- Address potential anti-patterns and mitigation strategies

### Section B: AWS-Focused Exercises

#### 1. Well-Architected Review (Paper Exercise)
**Solution Outline**:
- Review each of the 5 pillars systematically
- Identify specific risks with High/Medium/Low classification
- Provide concrete improvement actions with owners and timelines
- Include cost estimates for improvements where applicable
- Reference specific AWS services and features
- Consider both technical and operational improvements
- Document the review process and methodology used

#### 2. AWS Account Baseline Plan
**Solution Outline**:
- Design organizational unit (OU) structure with clear purposes
- Define IAM model with roles, policies, and permission boundaries
- Specify guardrails using Service Control Policies (SCPs)
- Plan logging and monitoring strategy across all accounts
- Include tagging standards and cost allocation model
- Address compliance and audit requirements
- Provide implementation timeline and migration strategy

#### 3. Reference Architecture Draft
**Solution Outline**:
- Choose one architecture type (web, serverless, or data)
- Create ASCII diagram showing all components and connections
- Specify AWS services for each component with justification
- Include multi-AZ deployment for high availability
- Address scaling and disaster recovery paths
- Consider cost optimization opportunities
- Document assumptions and constraints

#### 4. Cost Model
**Solution Outline**:
- Break down costs by environment (dev/test/prod)
- Include compute, storage, network, and managed service costs
- Apply right-sizing recommendations and savings plans
- Consider spot instances and reserved capacity where appropriate
- Include data transfer and egress costs
- Plan for cost monitoring and alerting
- Provide cost optimization recommendations

#### 5. Resilience Test Plan
**Solution Outline**:
- Define chaos engineering scenarios for different failure modes
- Specify failover procedures and recovery steps
- Include RTO/RPO validation criteria
- Plan observability and monitoring during tests
- Address both infrastructure and application-level failures
- Consider regional and availability zone failures
- Document test results and improvement actions

## Assessment Criteria

### Completeness (2 points)
- All required deliverables are present
- Each section is fully addressed
- No missing components or sections

### Technical Accuracy (2 points)
- Correct use of system design concepts
- Accurate AWS service recommendations
- Proper application of frameworks and methodologies

### Clarity and Diagrams (2 points)
- Clear, well-structured documentation
- Effective use of diagrams and visuals
- Easy to follow and understand

### Trade-off Analysis (2 points)
- Thorough analysis of alternatives
- Clear rationale for decisions
- Consideration of pros and cons

### Practical Feasibility (2 points)
- Realistic and implementable solutions
- Consideration of real-world constraints
- Appropriate level of detail for the scope

## Submission Guidelines

1. **File Organization**: Create a subfolder for each exercise (e.g., `A1-context-diagram/`)
2. **Documentation**: Include a `README.md` in each subfolder with your solution
3. **Diagrams**: Use ASCII diagrams in Markdown or link to external diagram files
4. **References**: Cite any external resources or tools used
5. **Code**: Include any code snippets or configuration examples
6. **Assumptions**: Document any assumptions made during the exercise

## Getting Help

- Review the concepts in the `concepts/` directory
- Check AWS documentation for service-specific guidance
- Use the design decision frameworks in the master plan
- Consult with peers or mentors for feedback
- Practice with similar exercises to build confidence

