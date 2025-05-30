= Motivation
// #TODO[ // Remove this block
//   *Proposal Motivation*
//   - Outline why it is (scientifically) important to solve the problem
//   - Again use the actors to present your solution, but don't be to specific
//   - Do not repeat the problem, instead focus on the positive aspects when the solution to the problem is available
//   - Be visionary! 
//   - Optional: motivate with existing research, previous work 
// ]

Containerization and orchestration have recently become a best practice in software engineering @bernsteinContainersCloudLXC2014. Mustyala demonstrates software development and deployment acceleration using CI/CD systems with Kubernetes @mustyalaCICDPIPELINES. Although Hades now uses Kubernetes to manage build jobs, Hades' scalability still suffers from the system not being deployed inside the cluster. Transitioning Hades into a Kubernetes cluster demonstrates the possibility of a job scheduling system with Kubernetes under interactive learning contexts.

Adopting a Kubernetes-native approach can also improve Hades's scalability potential. Under high concurrency, Hades can leverage the automatic scaling potential of Kubernetes to handle more throughput. In server failures, Kubernetes can automatically recover failed Hades services; this could be helpful in exam scenarios where many build jobs are submitted by students causing potential server crash.

Furthermore, using helm chart #footnote[https://helm.sh/] to deploy and upgrade Hades's services offers many advantages. Leveraging helm charts to deploy Hades reduces the deployment and configuration errors introduced by manual deployment @mustyalaCICDPIPELINES. Helm also supports easy updates and sharing of Hades systems. In the case of a system hotfix, system administrators can leverage Helm's rollback functions to restore an older but more stable version of Hades. 

To ensure security robustness and prevent unnecessary exposure of sensitive data, this work intends to adopt the principle of least privilege when implementing the access controls of Hades. In complex distributed systems, excessive permissions can lead to security vulnerabilities and unauthorized access. By limiting each component to the minimal required permissions for its responsive tasks, Hades can minimize attack surfaces and reduce the impact of potential breaches @mahboobKubernetesCICD2021.

Implementing a benchmarking framework contributes to continuous and objective evaluation of Hades's performance. Benchmarking different Hades versions allows developers to understand the improvements and bottlenecks of each Hades version; this allows developers to understand the impact of code changes on the overall systems. Developers can also use the benchmarking framework to assess Hades's performance against other educational CI systems to learn more about the state-of-the-art educational CI system.