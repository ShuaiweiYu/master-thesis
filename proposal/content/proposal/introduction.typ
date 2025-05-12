= Introduction
// #TODO[ // Remove this block
//   *Introduction*
//   - Introduce the reader to the general setting (No Problem description yet)
//   - What is the environment?
//   - What are the tools in use?
//   - (Not more than 1/2 a page)
// ]

Continuous Integration and Continuous Deployment (CI/CD) have become essential in software development, allowing for faster integration, improving code quality, and accelerating delivery cycles @elazharyUncoveringBenefitsChallenges2022. With growing software complexity and team sizes, CI systems must efficiently manage larger workloads with increased reliability @shahinContinuousIntegrationDelivery2017a. Thus, scalable and robust CI architectures are crucial.

Artemis is an interactive learning platform offering hands-on coding exercises. Artemis automatically assesses the exercise solution submitted by students and provides instant feedback so that the students could learn from their mistakes @kruscheArTEMiSAutomaticAssessment2018d. To support Artemis's CI pipelines, @jandowHadesCIScalableContinuous developed a job scheduling system, Hades, to handle build requests, manage build jobs, and deliver detailed build logs. When Hades receives a build request, it processes and validates the request using a Gateway component, which forwards the request to a Queue for scheduling afterwards. Kubernetes-based Build Agents then execute these build jobs and collect the results.

Hades leverages Kubernetes as Build Agents due to its scalability, automated resource allocation, and self-recovery capabilities #footnote[https://kubernetes.io/]. However, Hades is currently deployed outside the Kubernetes clusters and interacts with the clusters using the Kubernetes API, kubectl #footnote[https://kubernetes.io/docs/reference/kubectl/]. This approach will limit Hades's capability due to API call latency, deployment complexity, and security risks.

This project aims to migrate the Hades executor into the Kubernetes cluster and implement a customized Kubernetes operator. The work also aim to optimize the Kubernetes-based executor and design a load balancer to follow Kubernetes's best practices and thus enhance efficiency. Moreover, a comprehensive Benchmarking framework will be designed to assess Hades's performance and scalability. Insights from the benchmark results will reveal possible areas of improvement.