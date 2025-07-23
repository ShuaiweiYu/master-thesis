= Problem

We identified four major problems in the current Hades setup that this work aims to address. The goal is to enhance Hades using native Kubernetes and improve its maintainability and observability.

First, Hades is deployed manually and externally from the Kubernetes cluster. This setup requires administrators to manage deployment and upgrades, increasing the risk of human error. The current architecture has no self-recovery mechanisms and is prone to single points of failure. During periods of high usage, such as exams, the gateway may become overloaded, leading to higher latency and a degraded user experience.

Second, the Kubernetes integration of Hades does not follow cloud-native best practices. It does not leverage native Kubernetes API objects and lacks a load-balancing mechanism. This will lead to imbalanced resource allocation, causing resource contention and impacting the user experience. 

Third, Hades lacks the monitoring and logging support for the Kubernetes Operator. It is difficult to trace the system status without a robust monitoring and logging system. Moreover, build logs are not propagated to external trigger systems, making it hard for those systems to understand the outcome of submitted build jobs, especially in failure cases.

Fourth, Hades currently provides no benchmarking framework, which limits the ability to measure and analyze system performance. Without standardized benchmarks, it is difficult to evaluate Hades's behavior under varying workloads, which hinders optimization for high concurrency and makes bottlenecks harder to identify.
