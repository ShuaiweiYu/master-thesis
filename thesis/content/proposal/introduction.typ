= Introduction

Continuous Integration and Continuous Deployment (CI/CD) are essential in modern software development to streamline testing and delivery processes @elazharyUncoveringBenefitsChallenges2022. Educational platforms increasingly adopt these practices to automate the assessment of programming tasks. Artemis is an interactive learning platform that offers hands-on coding exercises and provides automatic feedback on student submissions @kruscheArTEMiSAutomaticAssessment2018d. To support Artemis's continuous assessment workflows, Jandow developed Hades, a job scheduling system that receives build requests, validates them through a Gateway, enqueues them for execution, and delegates them to Kubernetes-based Build Agents @jandowHadesCIScalableContinuous.

Hades leverages Kubernetes as Build Agents due to its scalability, automated resource allocation, and self-recovery capabilities #footnote[https://kubernetes.io/]. In its current architecture, Hades is deployed externally to the Kubernetes cluster and interacts with it through the Kubernetes API, kubectl #footnote[https://kubernetes.io/docs/reference/kubectl/]. While functional, this design contrasts with Kubernetes-native approaches and introduces certain architectural trade-offs.

#figure(
  image("../../figures/HadesCI-Stripped-Logging-Components.png"),
  caption: [HadesCI Architecture @jandowHadesCIScalableContinuous],
)

Current trends in CI/CD increasingly leverage deploying build execution systems within Kubernetes clusters to benefit from cloud-native capabilities @mustyalaCICDPIPELINES. Adapting Hades more closely to Kubernetes may lead to improvements in maintainability, deployment efficiency, and scalability.
