= Schedule

The project is divided into distinct phases with specific objectives to ensure a structured and result-oriented workflow. Following an agile methodology, the development will progress in bi-weekly sprints, focusing on incremental delivery of high-level, vertically integrated features.

- *01.08.2025 – Thesis Kickoff*

- *By the end of August – Benchmarking Framework & Familiarization*
  - Initial explore and familiarize the Hades project structure and codebase
  - Develop a benchmarking framework for evaluating various Hades deployments
// Milestones 2.b Implement a benchmarking suite to measure system performance under various load conditions.
  

- *By the end of September – Kubernetes-native Architecture Design*
  - Design a Kubernetes-native architecture for Hades.
  - Implement a Helm chart to facilitate consistent and scalable deployment and configuration.
// Milestones 2.a Develop a Helm chart for streamlined deployment.
// Milestones 1.a Implement a Kubernetes Operator for Hades.

- *By the end of October – Logging Infrastructure and Integration*
  - Implement a logging infrastructure to provide observability for build processes and cluster activity.
  - Integrate the Hades into Artemis to provide necessary logging outcomes.
  - By now, the objective *4.1* is fullfilled
// Goals 1.e Add fluentbit logging infrastructure

- *By the end of November – Deployment & Performance Benchmarking*
  - Deploy the Hades executor within a Kubernetes environment.
  - Perform a comprehensive benchmarking study to assess performance and identify areas for optimization.
  - By now, the objective *4.2* is fullfilled
// Milestones 1.b Transition the Hades executor to run inside the Kubernetes cluster.
// Milestones 1.c Integrate Service Accounts for secure API access.

- *By the end of December – Execution Layer Optimization*
  - Optimize the build execution layer based on prior benchmark results.
  - Refine the Kubernetes executor utilizing native API resources.
  - Implement effective load-balancing strategies to enhance scalability and performance.
  - By now, the objective *4.3* is fullfilled
// Milestones 3.a Improve the Kubernetes executor using native API objects (Pods, Jobs, etc.).
// Milestones 3.b Implement and fine-tune concurrent job execution strategies.

- *By 01.01.2026 – Finalization*
  - Implement feedback
  - Resolve possible follow-up issues

- *01.02.2026 – Final Delivery*