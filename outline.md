# Introduction
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

# Background
1. CI/CD Fundamentals
2. Kubernetes Basics
3. Helm Essentials
4. Benchmarking Metrics

# Related Work

# Requirements Analysis
1. Overview
2. Current System
    - describe the current Hades setup (Jandow's Paper)
3. Proposed System
    1. Functional Requirements
    2. Nonfunctional Requirements
4. System Models
    1. Scenarios
        - Visionary Scenarios: Close the Hades loop, acting as a full functional job system
        - Demo Scenarios: Current implementation of Hades
    2. Use Case Model
    3. Analysis Object Model
    4. Dynamic Model
    5. ~~User Interface~~
        - I don't have UI
# System Design
1. Overview
2. Design Goals
3. Subsystem Decomposition
4. Hardware Software Mapping
5. Persistent Data Management
    - Hades doesn't have Data Storage
    - CI-Benchmarker use SQLlite
6. Access Control
    - Hades API doesn't have access control
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