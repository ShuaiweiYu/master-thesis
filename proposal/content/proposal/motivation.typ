= Motivation
// #TODO[ // Remove this block
//   *Proposal Motivation*
//   - Outline why it is (scientifically) important to solve the problem
//   - Again use the actors to present your solution, but don't be to specific
//   - Do not repeat the problem, instead focus on the positive aspects when the solution to the problem is available
//   - Be visionary! 
//   - Optional: motivate with existing research, previous work 
// ]

Containerization and orchestration have recently become a best practice in software engineering @bernsteinContainersCloudLXC2014. Mustyala demonstrates scalable and efficient deployment of applications using CI/CD systems with Kubernetes @mustyalaCICDPIPELINES. Although Hades now uses Kubernetes to manage build jobs, Hades' scalability still suffers from the system not being deployed inside the cluster.

Improving Hades with a Kubernetes-native approach offers several benefits. Kubernetes's built-in auto-scaling and self-healing capabilities can enhance the robustness and security of the system. Moreover, adopting modern deployment practices with helm  #footnote[https://helm.sh/] can reduce human error and improve maintainability, which is beneficial in long-running scenarios where many users submit diverse build jobs, placing varying demands on the system. 

To ensure security, this work intends to adopt the principle of least privilege for Hades. In complex distributed systems, excessive permissions can lead to security vulnerabilities and unauthorized access @mahboobKubernetesCICD2021. By limiting each component to the minimal permissions for its tasks, Hades can minimize attack surfaces and reduce the impact of potential breaches.

Implementing a benchmarking framework contributes to continuous and objective evaluation of Hades's performance. Benchmarking different Hades versions allows developers to understand the improvements and bottlenecks of each Hades version; this allows developers to understand the impact of code changes on the overall systems.