#import "/utils/todo.typ": TODO

= Objective
// #TODO[ // Remove this block
//   *Proposal Objective*
//   - Define the main goals of your thesis clearly and concisely.
//   - Start with a short overview where you enumerate the goals as bullet points, using action-oriented phrasing (e.g., 1., 2., 3., ...).
//   - Avoid the gerund form for verbs (e.g., "Developing Feature XYZ") and noun phrases (e.g., "Feature XYZ Development"). Instead, use action-oriented language such as "Develop Feature XYZ", similar to how you would formulate use cases in UML use case diagrams.
//   - Ensure your goals are concrete and specific, avoiding generic statements. Clearly state what you aim to achieve.
//   - Expand on each goal in a dedicated subsection. Repeat the corresponding enumerated bullet point number to maintain consistency and provide at least two paragraphs explaining the goal. Focus on being precise and specific in your descriptions.
// ]


The current proof-of-concept Hades Implementation has proved the feasibility of running build jobs using Kubernetes. This work will explore the possibility of migrating the Hades system into the Kubernetes cluster and seek opportunities to improve the current setups. This work intends to follow the best practices of Kubernetes to leverage the Kubernetes native concepts to optimize build execution in Hades, ensuring better resource utilization, scalability, and reliability. There are three main objectives this thesis will address: 
+ Implement a Kubernetes Operator for Hades
+ Refine and Optimize the Kubernetes-Based Executor
+ Implement a Benchmarking Suite for Performance Evaluation

== Implement a Kubernetes Operator for Hades 
This thesis intends to transition the Hades executor into the cluster. Therefore, the project will design and implement a customized Kubernetes Operator, which manages and automates the lifecycle of build jobs within the Kubernetes environment. By migrating the Hades executor cloud-native, the work will enable direct API interactions between the operator and Kubernetes components.

To enhance the security of Hades, this work plans to integrate Kubernetes Service Accounts to provide the necessary permissions for secure execution. This implementation will provide fine-grained permissions for API interactions to ensure the communications are authentic and secure. Furthermore, to ease the deployment and configuration efforts, the work intends to design and build a Helm chart, which can help with the automatic deployment of Kubernetes native services, reduce human effort, and avoid the errors introduced by manual deployment. Finally, to offer a straightforward logging mechanism, the work will explore the possibility of leveraging state-of-the-art tools to build an adequate logging infrastructure.

== Performance Evaluation via Benchmarking
Another goal this project seeks to achieve is to design, implement, and apply a benchmarking framework to evaluate Hades's performance under various scenarios. Since the CI processes in educational settings can significantly vary across different programming exercises, it is essential for developers and administrators to understand Hades's actual performance and potential bottlenecks. The benchmarking suite will support analysis of three key metrics: Latency, Infrastructure Efficiency, and Throughput.

This work will not only deliver the benchmarking suite itself, but also utilize it to systematically measure performance metrics of Hades under realistic concurrency and workload conditions. The resulting evaluation will provide concrete insights into the behavior of the system, identify areas requiring improvement, and serve as a baseline for future optimizations. Additionally, the suite will aggregate and visualize performance data, facilitating intuitive analysis by developers and system administrators.

== Refine and Optimize the Kubernetes-Based Executor
This project's third objective is to refine and optimize the Kubernetes-Based Executor. The purpose of the Executor in Hades is to manage the creation and operation of entities for build job execution @jandowHadesCIScalableContinuous. Hades currently processes a proof-of-concept Kubernetes Executor, yet the work sees the possibility of further improvements to align with Kubernetes best practices. We will drive these enhancements by addressing performance bottlenecks and identifying opportunities through baseline metrics collected by the benchmarking suite. The improvements will use Kubernetes-native API objects to optimize build job execution and enhance the overall efficiency of Hades.

Additionally, the current component of Hades supports no load-balancing strategies. Load balancing is vital for the system's concurrency capability. This project will align with the best practices in the industry to implement a load balancer to distribute the build jobs based on the cluster capacity to ensure concurrent job execution. This work will also validates the effectiveness of the load balancing strategies through comparative measurements against the performance baseline.

#figure(
  image("../../figures/HadesCI-Logging-Components.png"),
  caption: [Integration of HadesCI with Learning Platform and Benchmarking Suite],
)