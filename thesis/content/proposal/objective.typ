= Objective

The current proof-of-concept implementation of Hades has demonstrated the feasibility of running build jobs using Kubernetes @jandowHadesCIScalableContinuous. This thesis builds on that foundation by migrating Hades into the Kubernetes cluster and improving its architecture according to cloud-native best practices. The goal is to enhance resource utilization, scalability, and system reliability. This work addresses three main objectives:
+ Implement a Kubernetes Operator for Hades
+ Evaluate Hades' Performance via Benchmarking
+ Refine and Optimize the Kubernetes-Based Executor

#figure(
  image("../../figures/HadesCI-Logging-Components.png"),
  caption: [Integration of HadesCI with Learning Platform and Benchmarking Suite (adapted from @jandowHadesCIScalableContinuous)],
)

== Implement a Kubernetes Operator for Hades 
This thesis intends to transition the Hades executor into the cluster. To achieve this, the project will design and implement a custom Kubernetes Operator that manages and automates the lifecycle of build jobs within the cluster. Running the executor inside Kubernetes enables direct API interactions and closer integration with native services.

To improve security, the operator will use Kubernetes Service Accounts with fine-grained permissions following the industrial best practice in IT security @mahboobKubernetesCICD2021. In addition, this thesis will develop a Helm chart to simplify deployment and upgrades, reducing manual configuration errors. This objective also includes building a logging infrastructure using modern, cloud-native tools to provide system-wide observability.

== Evaluate Hades' Performance via Benchmarking
The second objective is to design, implement, and apply a benchmarking framework to evaluate Hades's performance under diverse scenarios. Since CI workflows in educational settings vary across exercises, it is crucial to understand how Hades performs under different conditions. The benchmarking suite will measure three key metrics: latency, infrastructure efficiency, and throughput.

Beyond delivering the benchmarking tool, this work will apply it to test realistic workloads and concurrency levels. The results provide concrete insights into the behavior of the system, reveal potential bottlenecks, and establish a performance baseline for future optimizations. Additionally, the suite aggregates and visualizes performance data, facilitating intuitive analysis by developers and system administrators.

== Refine and Optimize the Kubernetes-Based Executor
This project's third objective is to refine and optimize the Kubernetes-Based Executor, which is responsible for managing the execution environment of build jobs @jandowHadesCIScalableContinuous. Although a proof-of-concept implementation exists, this project enhances the Executor by addressing performance bottlenecks based on insights from benchmarking results. Improvements include adopting Kubernetes-native API objects to optimize build job execution and enhance the overall efficiency of Hades.

Additionally, the current Kubernetes Executor implementation supports no load-balancing strategies. This project will align with the best practices in the industry to implement a load balancer to distribute the build jobs based on the cluster capacity to ensure concurrent job execution. This work will also validate the effectiveness of the load balancing strategies through comparative measurements against the performance baseline.