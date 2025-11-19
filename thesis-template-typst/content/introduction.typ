= Introduction

Continuous Integration and Continuous Deployment (CI/CD) are essential in modern software development to streamline testing and delivery processes @elazharyUncoveringBenefitsChallenges2022. Educational platforms increasingly adopt these practices to automate the assessment of programming tasks. Artemis is an interactive learning platform offering hands-on coding exercises and automatic feedback on student submissions @kruscheArTEMiSAutomaticAssessment2018d. To support Artemis's continuous assessment workflows, Jandow developed Hades, a job scheduling system that receives build requests, validates them through a Gateway, enqueues them for execution, and delegates them to Kubernetes-based Build Agents @jandowHadesCIScalableContinuous.

Hades leverages Kubernetes as Build Agents due to its scalability, automated resource allocation, and self-recovery capabilities #footnote[https://kubernetes.io/]. In its current architecture, Hades is deployed externally to the Kubernetes cluster and interacts with the cluster through the Kubernetes API, kubectl #footnote[https://kubernetes.io/docs/reference/kubectl/]. While functional, this design contrasts with Kubernetes-native approaches and introduces certain architectural trade-offs.

#figure(
  image("../figures/HadesCI-Stripped-Logging-Components.png"),
  caption: [HadesCI Architecture @jandowHadesCIScalableContinuous],
)

Current trends in CI/CD increasingly leverage deploying build execution systems within Kubernetes clusters to benefit from cloud-native capabilities @mustyalaCICDPIPELINES. Adapting Hades more closely to Kubernetes may lead to improvements in maintainability, deployment efficiency, and scalability.


== Problem
#TODO[
  Describe the problem that you like to address in your thesis to show the importance of your work. Focus on the negative symptoms of the currently available solution.
]

We identified four major problems in the current Hades setup that this work aims to address. The goal is to enhance Hades using native Kubernetes and improve its maintainability and observability.

First, Hades is deployed manually and externally from the Kubernetes cluster. This setup requires administrators to manage deployment and upgrades, increasing the risk of human error. The current architecture has no self-recovery mechanisms and is prone to single points of failure. During periods of high usage, such as exams, the gateway may become overloaded, leading to higher latency and a degraded user experience.

Second, the Kubernetes integration of Hades does not follow cloud-native best practices. It does not leverage native Kubernetes API objects and lacks a load-balancing mechanism. This will lead to imbalanced resource allocation, causing resource contention and impacting the user experience.

Third, Hades lacks the monitoring and logging support for the Kubernetes Operator. It is difficult to trace the system status without a robust monitoring and logging system. Moreover, build logs are not propagated to external trigger systems, making it hard to understand the outcome of submitted build jobs, especially in failure cases.

Fourth, Hades currently provides no benchmarking framework, which limits the ability to measure and analyze system performance. Without standardized benchmarks, evaluating Hades's behavior under varying workloads is challenging, which hinders optimization for high concurrency and makes bottlenecks harder to identify.

== Motivation
#TODO[
  Motivate scientifically why solving this problem is necessary. What kind of benefits do we have by solving the problem?
]

Addressing the limitations in the current Hades setup is essential to improve its scalability, reliability, and operational efficiency. Migrating Hades into the Kubernetes cluster and adopting cloud-native mechanisms enables the system to better handle high volumes of build jobs, recover from failures automatically, and reduce the maintenance burden on administrators @bernsteinContainersCloudLXC2014.

Improving Hades with a Kubernetes-native approach offers several benefits. Kubernetes's built-in auto-scaling and self-healing capabilities can enhance the robustness and security of the system. Moreover, adopting modern deployment practices with Helm  #footnote[https://helm.sh/] can reduce human error and improve maintainability, which is beneficial in long-running scenarios where many users submit diverse build jobs, placing varying demands on the system. 

Rather than implementing a separate load balancer, this thesis employ scheduler-driven workload distribution using Kubernetes primitives. This topology-aware placement improves cluster-wide utilization and reduces hot-spotting, enabling Hades to sustain higher concurrency while keeping user-perceived responsiveness stable. To objectively validate these improvements, we design a benchmarking framework that reports latency, throughput, and infrastructure efficiency, allowing developers to pinpoint bottlenecks and quantify the effect of code and configuration changes over time.

== Objectives
#TODO[
  Describe the research goals and/or research questions and how you address them by summarizing what you want to achieve in your thesis, e.g. developing a system and then evaluating it.
]

The current proof-of-concept implementation of Hades has demonstrated the feasibility of running build jobs using Kubernetes @jandowHadesCIScalableContinuous. This thesis builds on that foundation by migrating Hades into the Kubernetes cluster and improving its architecture according to cloud-native best practices. The goal is to enhance resource utilization, scalability, and system reliability. This work addresses three main objectives:
+ Implement a Kubernetes Operator for Hades
+ Evaluate Hades' Performance via Benchmarking
+ Optimize the Kubernetes-Based Executor

#figure(
  image("../figures/HadesCI-Logging-Components.png"),
  caption: [Integration of HadesCI with Learning Platform and Benchmarking Suite (adapted from @jandowHadesCIScalableContinuous)],
)

=== Implement a Kubernetes Operator for Hades 
This thesis intends to transition the Hades executor into the cluster. To achieve this, the project will design and implement a custom Kubernetes Operator that manages and automates the lifecycle of build jobs within the cluster. Running the executor inside Kubernetes enables direct API interactions and closer integration with native services.

To improve security, the operator will use Kubernetes Service Accounts with fine-grained permissions following the industrial best practice in IT security @mahboobKubernetesCICD2021. In addition, this thesis will develop a Helm chart to simplify deployment and upgrades, reducing manual configuration errors. This objective also includes building a logging infrastructure using modern, cloud-native tools to provide system-wide observability.

=== Evaluate Hades' Performance via Benchmarking
The second objective is to design, implement, and apply a benchmarking framework to evaluate Hades's performance under diverse scenarios. Since CI workflows in educational settings vary across exercises, it is crucial to understand how Hades performs under different conditions. The benchmarking suite will measure three key metrics: latency, infrastructure efficiency, and throughput.

Beyond delivering the benchmarking tool, this work will apply it to test realistic workloads and concurrency levels. The results provide concrete insights into the behavior of the system, reveal potential bottlenecks, and establish a performance baseline for future optimizations. Additionally, the suite aggregates and visualizes performance data, facilitating intuitive analysis by developers and system administrators.

=== Optimize the Kubernetes-Based Executor
This project's third objective is to optimize the Kubernetes-Based Executor, which is responsible for managing the execution environment of build jobs @jandowHadesCIScalableContinuous. Although a proof-of-concept implementation exists, this project enhances the Executor by addressing performance bottlenecks based on insights from benchmarking results. Improvements include adopting Kubernetes-native API objects to optimize build job execution and enhance the overall efficiency of Hades.

Additionally, rather than introducing a separate load balancer, this project implements scheduler-driven workload distribution using Kubernetes primitives to balance placement and scale concurrent builds. We will benchmark these policies against a baseline to quantify improvements in latency, throughput, and efficiency.

== Outline
#TODO[
  Describe the outline of your thesis
]