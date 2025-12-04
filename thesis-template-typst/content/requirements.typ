#import "/utils/todo.typ": TODO

= Requirements
// #TODO[
//   This chapter follows the Requirements Analysis Document Template in @bruegge2004object. Important: Make sure that the whole chapter is independent of the chosen technology and development platform. The idea is that you illustrate concepts, taxonomies and relationships of the application domain independent of the solution domain! Cite @bruegge2004object several times in this chapter.

// ]

== Overview
// #TODO[
//   Provide a short overview about the purpose, scope, objectives and success criteria of the system that you like to develop.
// ]
 
The goal of the proposed system is to enhance the reliability, scalability, and evaluability of Hades, a continuous integration system designed to execute large volumes of automated CI build jobs @jandowHadesCIScalableContinuous. In this chapter, we provide a brief overview of the current Hades system, highlighting its limitations (Section 4.2), and then describe the purpose and scope of the proposed extensions (Section 4.3). We develop functional requirements (Section 4.3.1), quality attributes (Section 4.3.2), and constraints (Section 4.3.3) that define the expected behavior of the extended system. Finally, these requirements are further translated into system models (Section 4.4), ensuring a shared understanding of the application domain.

The scope of this work develops as follows: this thesis introduces a more structured orchestration model for managing build-job execution, which provides more explicit lifecycle semantics, improved diagnostics, and reproducible deployment. Secondly, the thesis adds a benchmarking subsystem capable of generating controlled workloads, collecting end-to-end performance metrics, and producing comparative reports across different Hades configurations. Together, these enhancements aim to offer a maintainable deployment process, enable accurate and repeatable evaluation of latency and throughput, and support data-driven improvement of Hades's execution architecture.

== Existing System
// #TODO[
//   This section is only required if the proposed system (i.e. the system that you develop in the thesis) shall replace an existing system.
// ]


The current Hades system comprises three main conceptual components: HadesAPI, the Queue, and HadesScheduler. Each component contributes to a distinct stage of the build-job processing workflow and follows the principles of a loosely coupled service system. Together, these components enable users and external systems to submit build requests, prioritize them, and dispatch them for execution @jandowHadesCIScalableContinuous.

The HadesAPI serves as the request intake component of the system. It accepts build requests from multiple trigger sources, such as learning platforms or automated benchmarking tools. Upon receiving a request, it validates the structure and completeness of the payload and assigns a priority level explicitly defined by the triggering party. The validated and prioritized request is then forwarded to the next subsystem for ordered processing.

The Queue is responsible for organizing and storing pending build jobs according to their assigned priority. It maintains multiple logical queues, each corresponding to a priority category, ensuring that high-priority jobs are always eligible for retrieval before lower-priority ones. The queueing subsystem provides persistence and ordering guarantees but does not maintain additional lifecycle state beyond job submission.

The HadesScheduler retrieves jobs from these priority-ordered queues using a priority-descending selection strategy. Conceptually, it functions as a scheduling and delegation component rather than an execution engine. After selecting a job, HadesScheduler interprets its specification and delegates its execution to an appropriate external execution environment. Depending on the system configuration, this may involve initiating isolated build processes, preparing build steps, or coordinating multiple operations required to complete the job.

While this architecture enables lightweight processing of build jobs, several limitations remain. The system does not have a unified representation of build job lifecycles, provides limited visibility into the execution process, lacks advanced workload distribution strategies, and does not offer a standardized method for assessing performance. These limitations highlight the need for the improvements and requirements outlined in the following sections.


== Proposed System
// #TODO[
//   If you leave out the section “Existing system”, you can rename this section into “Requirements”.
// ]
 
The proposed system introduces new capabilities aimed at improving the management, execution, and evaluation of build jobs within Hades. This section summarizes the functional requirements derived from the system objectives and the limitations identified in the existing architecture. The requirements are grouped into two categories: core system capabilities, which describe the essential functions needed to manage and operate build jobs in a structured and scalable manner; and benchmarking capabilities, which outline the system's ability to generate workloads, measure performance, and support comparative evaluation across different configurations. These functional requirements collectively define the scope of the proposed enhancements and guide the system's architectural design.


=== Functional Requirements
// #TODO[
//   List and describe all functional requirements of your system. Also mention requirements that you were not able to realize. The short title shall be in the form “verb objective”

//   - FR1 Short Title: Short Description. 
//   - FR2 Short Title: Short Description. 
//   - FR3 Short Title: Short Description.
// ]

In this section, we describe the functional requirements of the proposed system by focusing on the interactions between the system and its external actors, following the definition of functional requirements provided by @bruegge2004object. Functional requirements specify what the system shall do from the perspective of its environment rather than how it will be implemented. They describe the externally visible behavior of the system, its services, and the way it responds to its actors.

For Hades, the primary external actors are:

- * System Administrator * — responsible for deploying, configuring, and maintaining the Hades system. This actor interacts with the system during installation, upgrades, configuration changes, and version management.

- * Developer * — responsible for implementing new requirements and functionalities into Hades and evaluating the performance changes in Hades through the CI-Benchmarker.

Unlike many user-facing systems, Hades is not directly used by end-users such as students or instructors; instead, it operates as an internal infrastructure component whose functionality is primarily accessed by external systems or by developers performing evaluation tasks. As a result, the functional requirements focus on the capabilities that enable the systematic deployment, controlled execution of benchmark workloads, and performance assessment.

To reflect the different responsibilities and objectives of each actor, the functional requirements are organized into two categories:

- * Core System Capabilities * — requirements addressing how system administrators interact with Hades to deploy and manage it in a consistent and reproducible manner.

- * Benchmarking Capabilities * — requirements addressing how developers use the CI-Benchmarker to generate workload scenarios, measure system performance, and analyze execution outcomes across different configurations.

Together, these requirements define the externally observable behavior of the extended Hades architecture and establish the foundation for evaluating its performance, maintainability, and scalability.

==== Core System Capabilities

- * FR1 Manage Packaged Deployment of the Hades System *

As a system administrator, I would like to deploy, configure, upgrade, and roll back the Hades system using a structured, package-based deployment mechanism, ensuring the system can be installed and maintained consistently across different environments. The deployment process shall support versioned updates and minimize manual configuration effort, enabling administrators to efficiently manage different Hades versions and system configurations.

==== Benchmarking Capabilities

- * FR2 Generate Configurable Benchmark Workloads *

As a developer, I want to generate configurable benchmark workloads so that I can simulate different usage scenarios of Hades and evaluate how the system behaves under varying conditions. The CI-Benchmarker shall enable the creation of workloads that vary in the number of build jobs, submission rate, priority distribution, and composition of build steps. These parameters enable developers and system administrators to reproduce realistic scenarios, such as exam-time submission peaks or continuous background usage, and to analyze system performance across a range of operational conditions.

- * FR3 Collect End-to-End Performance Metrics *

As a developer, I want to collect end-to-end performance metrics for submitted build jobs so that I can analyze how different system configurations affect latency, throughput, and overall execution behavior. To support this goal, the CI-Benchmarker shall measure key indicators, including the time from submission to completion, waiting time before execution, and the number of jobs processed over a specified interval. Additionally, it shall enable identical workloads to be executed against different Hades configurations or execution modes, and record their performance results comparably. These capabilities enable systematic comparison between alternative architectural designs, tuning strategies, or operator versions, providing a data-driven foundation for performance evaluation and optimization.

- * FR4 Produce Benchmark Reports for Analysis *

As a developer, I want to obtain structured benchmark reports so that I can interpret performance results efficiently and identify potential bottlenecks in the system. To support this goal, the CI-Benchmarker shall aggregate the collected performance data and generate reports that summarize key metrics, such as latency distributions, throughput over time, and comparative outcomes across different system configurations. These reports should be suitable for manual inspection by developers and system administrators, providing actionable insights that guide further optimization and architectural evaluation.

=== Quality Attributes
// #TODO[
//   List and describe all quality attributes of your system. All your quality attributes shall fall into the URPS categories mentioned in @bruegge2004object. Also mention requirements that you were not able to realize.

//   - QA1 Category: Short Description. 
//   - QA2 Category: Short Description. 
//   - QA3 Category: Short Description.

// ]

This section describes the quality attributes of the proposed system following the URPS categories outlined by Bruegge and Dutoit @bruegge2004object. Unlike functional requirements, which specify what the system must do, quality attributes specify how the system should behave under various conditions.

Because the proposed system consists of two distinct subsystems—the Hades execution infrastructure and the CI-Benchmarker—the relevant quality attributes differ substantially. The following subsections therefore document the quality attributes separately for each subsystem.

==== Quality Attributes for the Hades System

- * QA1 Reliability: Preserve Consistent Job Lifecycle Semantics *

The current Hades system already ensures that each build job progresses through its lifecycle in a consistent and well-defined manner. The proposed Kubernetes-based execution model must preserve this behavior by maintaining accurate and coherent job states throughout execution, even under high load or partial failures. The transition between lifecycle stages shall remain deterministic and shall not result in undefined, contradictory, or stalled states.

- * QA2 Reliability: Preserve Deterministic Priority-Aware Scheduling *

The current Hades system already provides deterministic, priority-aware scheduling by consistently selecting higher-priority jobs ahead of lower-priority ones under equivalent conditions. The proposed Kubernetes-based execution model must preserve this behavior by ensuring that job selection remains stable, predictable, and strictly aligned with user-defined priorities.

- * QA3 Reliability: Fault-Tolerant Execution Delegation *

The proposed Kubernetes-based execution model must maintain fault tolerance property by ensuring that job execution remains well-defined and recoverable in the presence of failures within the underlying container infrastructure. Failures such as container crashes, Pod restarts, node unavailability, or execution interruptions shall not lead to inconsistent or ambiguous job states. Instead, the system must detect such conditions and transition the job into a clear and correct lifecycle state, thereby preserving the robustness exhibited by the existing Docker-based implementation.

- * QA4 Performance: Scalable Concurrent Execution *

The system must support the concurrent execution of a large number of build jobs without experiencing significant degradation in throughput or scheduling responsiveness. As workload intensity increases, such as during high-volume submission bursts, the system must continue to accept, schedule, and execute jobs efficiently. Increased parallelism shall not lead to substantial delays in job initiation or excessive queuing, ensuring that overall execution performance remains stable under varying levels of concurrency.

- * QA5 Performance: Low-Overhead Orchestration *

The system shall maintain an orchestration process whose computational and coordination overhead remains small relative to the execution time of build jobs. The control logic responsible for interpreting job specifications, initiating execution, and monitoring job progress shall introduce minimal additional latency and shall not become a performance bottleneck as workload intensity increases. Orchestration activities must remain lightweight enough to ensure that the primary limiting factor of job throughput is the execution environment itself rather than the coordination mechanisms of the system.

- * QA6 Performance: Efficient Resource Utilization *

The system shall utilize available execution resources efficiently by distributing build jobs in a manner that avoids unnecessary concentration of workload and prevents idle capacity. As the number and intensity of submitted jobs vary, the orchestration logic shall assign execution tasks in a balanced way that aligns with current resource availability, minimizing bottlenecks and reducing contention. Resource allocation decisions shall support sustained throughput while preventing overload on individual execution units, ensuring that the overall system operates at an efficient and stable utilization level.

- * QA7 Supportability: Reproducible and Maintainable Deployment Process *

The system shall provide a deployment process that is predictable, repeatable, and easy for system administrators to maintain over time. The deployment mechanism shall minimize operational complexity and enable administrators to establish and restore a consistent system state with confidence, ensuring that the system remains manageable throughout its lifecycle.

- * QA8 Supportability: Accessible Build Job Logs and Diagnostics *

The system shall provide clear and accessible visibility into the execution results of each build job by exposing relevant log outputs and diagnostic information in a structured and interpretable form. System administrators shall be able to retrieve the logs associated with all execution steps without needing to inspect underlying execution resources directly. This level of observability shall support the identification of failures, misconfigurations, and unexpected execution behaviors, enabling efficient diagnosis and maintenance within the new orchestration model.

==== Quality Attributes for the CI-Benchmarker
- * QA9 Usability: Developer-Friendly Benchmarking Interface *

The benchmarking subsystem shall be easy for developers and system administrators to learn and operate. It shall expose a simple and well-documented interface that allows benchmark runs to be triggered using familiar tools such as HTTP clients or command-line utilities. Developers shall be able to initiate benchmarking activities without requiring detailed knowledge of Hades's internal execution architecture.

- * QA10 Usability: Easily Configurable Benchmark Scenarios *

The benchmarking subsystem shall enable developers to run different experiments with minimal configuration effort. Workload parameters and execution settings shall be expressed in a concise and understandable form so that modifying a small number of options is sufficient to generate new scenarios, explore alternative workload patterns, or repeat experiments under varied conditions.

- * QA11 Reliability: Reproducible Benchmark Execution *

The benchmarking subsystem shall ensure that identical workload specifications yield comparable performance results across repeated runs. This reproducibility is necessary for detecting regressions, validating optimizations, and comparing alternative system configurations.


- * QA12 Performance: Fast and Accurate Metric Computation *

The benchmarking subsystem shall compute and report performance metrics quickly and with sufficient accuracy to support reliable comparison across different Hades configurations and execution modes.


=== Constraints

// #TODO[
//   List and describe all pseudo requirements of your system. Also mention requirements that you were not able to realize.

//   - C1 Category: Short Description. 
//   - C2 Category: Short Description. 
//   - C3 Category: Short Description.

// ]

This section summarizes the constraints that shape and limit the design of the proposed system. Following the classification of pseudo requirements described by @bruegge2004object, constraints define conditions under which the system must operate but which do not themselves specify functional behavior. These include restrictions imposed by the existing Hades ecosystem, the hosting infrastructure, and the operational environment into which the new components must integrate. The constraints listed below therefore capture architectural boundaries, compatibility requirements, and operational expectations that the system must respect throughout its lifecycle.

- * C1 Implementation — Compatibility with Existing Hades Interfaces *

The system must remain compatible with the existing interfaces. This constraint limits modifications to job specifications, request semantics, and communication patterns so that the new orchestration and benchmarking subsystems can be integrated without disrupting current clients and workflows.

- * C2 Implementation — Use of a Unified Execution Environment *

The orchestration subsystem must operate within a standardized execution environment defined by the hosting infrastructure. This constraint restricts architectural choices and requires that the component conforms to existing runtime assumptions.

- * C3 Interface — Integration with External Trigger Sources * 

The system must continue to accept build requests from existing trigger sources, such as learning platforms and automated tools, without requiring changes to those external systems.

- * C4 Operations — Centralized Deployment Management *

Deployment and configuration of the system components must follow the centralized operational practices of the hosting organization. This constraint requires that installation, updates, and configuration changes can be performed using the existing operational workflows.

== System Models
// #TODO[
//   This section includes important system models for the requirements.
// ]

System models provide complementary views of the proposed system and help translate the previously defined textual requirements into visual representations, making the proposed solution more precise and understandable @bruegge2004object. In this chapter, we present four types of models. Scenarios describe concrete workflows in realistic situations, ensuring the expected behavior of the system. The use case model abstracts the system's usage and captures the key user interactions. The analysis object model identifies the essential domain concepts and structures them in relation to their relationships. The dynamic model then captures the collaborations of the system components, focusing on state transitions during the system's lifecycle. The following sections provide a detailed description of each model.

=== Scenarios
// #TODO[
//   If you do not distinguish between visionary and demo scenarios, you can remove the two subsubsections below and list all scenarios here.

//   *Visionary Scenarios*
//   Describe 1-2 visionary scenario here, i.e. a scenario that would perfectly solve your problem, even if it might not be realizable. Use free text description.

//   *Demo Scenarios*
//   Describe 1-2 demo scenario here, i.e. a scenario that you can implement and demonstrate until the end of your thesis. Use free text description.
// ]

Bob completes a programming exercise on the online learning platform and clicks Submit. The platform packages his solution and sends a build request to Hades. Hades registers the job, assigns it a lifecycle state, and places it into the priority queue. When resources are available, the scheduler selects Bob's job and triggers its execution in an isolated environment. During the process, Hades records lifecycle transitions, captures logs, and measures execution time. Once the job finishes, Hades returns the result and logs to the platform. Bob immediately sees whether his solution compiled, which tests passed, and any error messages. This scenario demonstrates how Hades processes external build requests reliably while providing clear feedback and observable execution behavior.

=== Use Case Model
// #TODO[
//   This subsection shall contain a UML Use Case Diagram including roles and their use cases. You can use colors to indicate priorities. Think about splitting the diagram into multiple ones if you have more than 10 use cases. *Important:* Make sure to describe the most important use cases using the use case table template (./tex/use-case-table.tex). Also describe the rationale of the use case model, i.e. why you modeled it like you show it in the diagram.

// ]

Use cases describe the functional behavior of a system as perceived by external entities, capturing the interactions that lead to a meaningful and observable result. Actors are those external entities interacting with the system to achieve a specific objective. The relationship between actors and use cases defines the system boundary: actors initiate or participate in use cases, while use cases represent the services the system provides in response @bruegge2004object. Based on this perspective, we identify the relevant actors for the Hades system and the CI-Benchmarker as follows: 

- * External Trigger * : represents systems such as online learning platforms, CI-Benchmarker, or CLI in terminal that initiate build jobs. Hades interacts only with these systems, not with end users directly.
- * System Administrator * : manages deployment, configuration, and monitoring of Hades, reflecting the operational nature of this subsystem.
- * Developer * : serves as the sole actor for the CI-Benchmarker, which is used exclusively for performance experiments and not by external platforms.

It is important to note that Hades and the CI-Benchmarker operate as two distinct subsystems with different responsibilities. As a result, their actors do not overlap: Hades primarily interacts with external triggering systems and administrators responsible for its operation, whereas the CI-Benchmarker is exclusively used by developers and researchers conducting performance evaluations.

The figure @usecase_1 illustrates the interactions between two primary actors and the Hades system: the External Trigger and the System Administrator. The interests of the two roles differ fundamentally, the External Trigger prioritizes the functional utilization of the platform, whereas the System Administrator focuses on the system's maintainability and deployment lifecycle.

#figure(
  image("../figures/usecase_1.png"),
  caption: [A UML use case diagram illustrating the interaction of an external trigger and a system administrator with the Hades System ],
) <usecase_1>

The External Trigger initiates the workflow through the Submit Build Job use case. In this use case, the External Trigger will transmit build configurations to the Hades system, initiating the continuous integration pipeline. Once the pipeline is active, the interaction centers on the View Build Status use case. We model the View Build Status use case via an include relationship to Live Streaming Build Logs, signifying that the retrieval of real-time logs is an obligatory and integral part of the status viewing process. These mechanisms ensure that the actor receives immediate feedback on the execution progress. We model the View Error Logs use case using an extended relationship. This extension indicates that accessing error logs is a conditional behavior, triggered explicitly when a build fails or an exception occurs. The separation between use cases ensures that the main workflow is focused on standard monitoring, while detailed diagnostic capabilities remain accessible as an optional extension for fault localization and diagnosis.

Parallel to the execution flow, the System Administrator's primary interest lies in the operational maintenance of the platform. The System Administrator interacts primarily with the Manage Hades Deployment Lifecycle use case, which serves as a high-level abstraction for system orchestration. To define the specific scope of administrative duties, this use case includes two distinct sub-routines. Deploy Hades use case handles the initial provisioning and configuration of the system environment. The Upgrade/Rollback Hades use case provides a mechanism for version control, allowing administrators to apply updates or revert to a previous stable state.

Complementing the primary execution use cases, the CI-Benchmarker subsystem operates as an independent module designed for performance evaluation and benchmarking. Figure @usecase_2 illustrates the use case model for this subsystem, focusing on the interactions between the Developer and the CI-Benchmarker.

#figure(
  image("../figures/usecase_2.png"),
  caption: [A UML use case diagram illustrating the interaction of a Developer with the CI-Benchmarker ],
) <usecase_2>

The workflow initiates through the Trigger Benchmark Execution use case. This use case serves as the primary entry point for starting performance tests. We model this interaction via an include relationship to Configure Benchmark Parameters. Developers can configure several variables, such as job batches, commit hash, or executor mode. These configurations are a necessary prerequisite for execution, allowing the Developer to choose from different benchmarking scenarios and study the performance changes, and also guaranteeing the reproducibility of the results.

Following the execution phase, the system supports the Collect Performance Metrics use case. It allows the Developer to retrieve performance data regarding system throughput, latency, and resource utilization, forming the quantitative basis for evaluating the Hades system's performance.

Together, the use cases presented above provide a comprehensive view of the interactions that define both subsystems of the platform: Hades as a build-execution service and the CI-Benchmarker as a performance evaluation module. These diagrams and descriptions clarify the responsibilities of each actor, highlight the mandatory and optional behaviors, and outline the complete interaction flows underlying build execution and benchmarking workflows. Having established these functional boundaries and actor-driven perspectives, we now turn to the structural foundations of the system. 

=== Analysis Object Model
// #TODO[
//   This subsection shall contain a UML Class Diagram showing the most important objects, attributes, methods and relations of your application domain including taxonomies using specification inheritance (see @bruegge2004object). Do not insert objects, attributes or methods of the solution domain. *Important:* Make sure to describe the analysis object model thoroughly in the text so that readers are able to understand the diagram. Also write about the rationale how and why you modeled the concepts like this.

// ]

=== Dynamic Model
// #TODO[
//   This subsection shall contain dynamic UML diagrams. These can be a UML state diagrams, UML communication diagrams or UML activity diagrams.*Important:* Make sure to describe the diagram and its rationale in the text. *Do not use UML sequence diagrams.*
// ]

// === User Interface
// #TODO[
//   Show mockups of the user interface of the software you develop and their connections / transitions. You can also create a storyboard. *Important:* Describe the mockups and their rationale in the text.
// ]