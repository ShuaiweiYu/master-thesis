= Introduction
// #TODO[ // Remove this block
//   *Introduction*
//   - Introduce the reader to the general setting (No Problem description yet)
//   - What is the environment?
//   - What are the tools in use?
//   - (Not more than 1/2 a page)
// ]

Continuous Integration and Continuous Deployment (CI/CD) have become essential in software development, allowing for faster integration, improving code quality, and accelerating delivery cycles @elazharyUncoveringBenefitsChallenges2022. With growing software complexity and team sizes, CI systems must efficiently manage larger workloads with increased reliability @shahinContinuousIntegrationDelivery2017a. Thus, scalable and robust CI architectures are crucial.

Artemis is an interactive learning platform offering hands-on coding exercises. Artemis automatically assesses the exercise solution submitted by students and provides instant feedback so that the students could learn from their mistakes @kruscheArTEMiSAutomaticAssessment2018d. To support Artemis's CI pipelines, Jandow developed a job scheduling system, Hades, to handle build requests, manage build jobs, and deliver detailed build logs @jandowHadesCIScalableContinuous. When Hades receives a build request, it processes and validates the request using a Gateway component, which forwards the request to a Queue for scheduling afterwards. Kubernetes-based Build Agents then execute these build jobs and collect the results.

Hades leverages Kubernetes as Build Agents due to its scalability, automated resource allocation, and self-recovery capabilities #footnote[https://kubernetes.io/]. In its current architecture, Hades is deployed externally to the Kubernetes cluster and interacts with it through the Kubernetes API, kubectl #footnote[https://kubernetes.io/docs/reference/kubectl/]. This approach will limit Hades's capability due to API call latency, deployment complexity, and security risks.

#figure(
  image("../../figures/HadesCI-Stripped-Logging-Components.png"),
  caption: [HadesCI Architecture],
)

As container orchestration systems like Kubernetes become more relevant in CI/CD workflows, aligning CI systems with cloud-native practices has become an applicable direction for improvement. In this context, adapting Hades to run within a Kubernetes environment may lead to improvements in maintainability, deployment efficiency, and scalability, particularly for use cases such as programming exercise evaluation.