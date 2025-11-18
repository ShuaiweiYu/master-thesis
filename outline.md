# Introduction
- [ ] Copy from the Proposal and Modify
1. Problem
    - Hades is deploy outside K8S
    - Hades doesn't have automatically deployment possibility
    - Hades doesn't have a Operator (no cloud native best practice)
    - Hades Operator don't have logging possibilities
    - We don't have Benchmarking possibilities
2. Motivation
    - K8S migration improves efficieny
    - Helm Chart ease the deployments
    - Operator improves the redouce utilization
3. Objectives
    - Implement a Kubernetes Operator for Hades
    - Evaluate Hades’ Performance via Benchmarking
    - Optimize the Kubernetes.Based Executor
4. Outline

# ~~Background~~
- [ ] Less necesaary, can talk little about this (low piority, can skip for now)
1. CI/CD Fundamentals
2. Kubernetes Basics
3. Helm Essentials
4. Benchmarking Metrics

# Related Work
-[ ] More important, have to do more literature review

# Requirements Analysis
1. Overview
2. Current System
    - describe the current Hades setup (Jandow's Paper)
3. Proposed System
    - [ ] This is renamed to qulity attributes/constraints, take a look at the new templates
    1. Functional Requirements
        - [ ] I don't have Functional Requirements for hades
        - [ ] I have Functional Requirements for CI-Benchmarker
        - Quality attributes are FEPBS (fucntionality, usibility, performance)
        - Constraints are K8S (Constraints in the implementation)
    2. Nonfunctional Requirements
4. System Models
    1. ~~Scenarios~~
        - [ ] Low priority, maybe not needed
        - Visionary Scenarios: Close the Hades loop, acting as a full functional job system
        - Demo Scenarios: Current implementation of Hades
    2. ~~Use Case Model~~
        - [ ] Low priority, maybe not needed
    3. Analysis Object Model
        - [ ] Medium priority, Still can come up wuth some, refer to Jandow's Paper
    4. Dynamic Model
        - [ ] High priority
    5. ~~User Interface~~
        - [ ] If we have time, we can build one
        - I don't have UI
# System Design
1. ~~Overview~~
    - [ ] Can be replaced using heading
2. Design Goals
3. Subsystem Decomposition
    - [ ] Huge part of my work
4. Hardware Software Mapping
5. Persistent Data Management
    - Hades use NATS, very interesting for k8s + operator
    - CI-Benchmarker use SQLlite
6. Access Control
    - Hades Operator supports RBAC
7. Global Software Control
8. Boundry Conditions

# Evaluation
- Namely my benchmarking result here
1. Design
2. Objectives
3. Results
4. Findings
5. Discussion
6. Limitations

# Summary
1. Status
    1. Realized Goals
    2. Open Goals
2. Conclusion
3. Future Work
