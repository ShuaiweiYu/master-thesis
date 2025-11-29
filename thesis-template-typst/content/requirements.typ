#import "/utils/todo.typ": TODO

= Requirements
// #TODO[
//   This chapter follows the Requirements Analysis Document Template in @bruegge2004object. Important: Make sure that the whole chapter is independent of the chosen technology and development platform. The idea is that you illustrate concepts, taxonomies and relationships of the application domain independent of the solution domain! Cite @bruegge2004object several times in this chapter.

// ]

== Overview
// #TODO[
//   Provide a short overview about the purpose, scope, objectives and success criteria of the system that you like to develop.
// ]

== Existing System
// #TODO[
//   This section is only required if the proposed system (i.e. the system that you develop in the thesis) shall replace an existing system.
// ]


The current Hades system comprises three main conceptual components: HadesAPI, the Queue, and HadesScheduler. Each component contributes to a distinct stage of the build-job processing workflow and follows the principles of a loosely coupled service system. Together, these components enable users and external systems to submit build requests, prioritize them, and dispatch them for execution @jandowHadesCIScalableContinuous.

The HadesAPI acts as the request-intake component of the system. It accepts build requests from multiple trigger sources, such as learning platforms or automated benchmarking tools. Upon receiving a request, it validates the structure and completeness of the payload and assigns a priority level explicitly defined by the triggering party. The validated and prioritized request is then forwarded to the next subsystem for ordered processing.

The Queue is responsible for organizing and storing pending build jobs according to their assigned priority. It maintains multiple logical queues, each corresponding to a priority category, ensuring that high-priority jobs are always eligible for retrieval before lower-priority ones. The queueing subsystem provides persistence and ordering guarantees but does not maintain additional lifecycle state beyond job submission.

The HadesScheduler retrieves jobs from these priority-ordered queues using a priority-descending selection strategy. Conceptually, it functions as a scheduling and delegation component rather than an execution engine. After selecting a job, HadesScheduler interprets its specification and delegates its execution to an appropriate external execution environment. Depending on the system configuration, this may involve initiating isolated build processes, preparing build steps, or coordinating multiple operations required to complete the job. The scheduler itself does not perform the build but orchestrates the required execution activities.

While this architecture enables lightweight processing of build jobs, several limitations remain. The system does not maintain a unified lifecycle representation of build jobs, offers only limited observability into the execution process, lacks sophisticated workload-distribution strategies, and provides no standardized mechanism to evaluate performance. These limitations motivate the requirements and improvements described in the following sections.

== Proposed System
// #TODO[
//   If you leave out the section “Existing system”, you can rename this section into “Requirements”.
// ]
 
The proposed system introduces new capabilities aimed at improving the management, execution, and evaluation of build jobs within Hades. This section summarizes the functional requirements derived from the system objectives and the limitations identified in the existing architecture. The requirements are grouped into two categories: core system capabilities, which describe the essential functions needed to manage and operate build jobs in a structured and scalable manner; and benchmarking capabilities, which outline the system’s ability to generate workloads, measure performance, and support comparative evaluation across different configurations. These functional requirements collectively define the scope of the proposed enhancements and guide the system’s architectural design.


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

- * Developer * — responsible for implementmenting new requiremnts and functionalities into hades and evaluating the permance changes Hades through the CI-Benchmarker.

Unlike many user-facing systems, Hades is not directly used by end-users such as students or instructors; instead, it operates as an internal infrastructure component whose functionality is primarily accessed by external systems or by developers performing evaluation tasks. As a result, the functional requirements focus on the capabilities enabling systematic deployment, controlled execution of benchmark workloads, and performance assessment.

To reflect the different responsibilities and objectives of each actor, the functional requirements are organized into two categories:
- * Core System Capabilities * — requirements addressing how system administrators interact with Hades to deploy and manage it in a consistent and reproducible manner.

- * Benchmarking Capabilities * — requirements addressing how developers use the CI-Benchmarker to generate workload scenarios, measure system performance, and analyze execution outcomes across different configurations.

Together, these requirements define the externally observable behavior of the extended Hades architecture and establish the foundation for evaluating its performance, maintainability, and scalability.

==== Core System Capabilities

- * FR1 Manage Packaged Deployment of the Hades System *

As a system administrator, I would like to deploy, configure, upgrade, and roll back the Hades system using a structured, package-based deployment mechanism so that the system can be installed and maintained consistently across different environments. The deployment process shall support versioned updates and minimize manual configuration effort, enabling administrators to efficiently manage different Hades versions and system configurations.

==== Benchmarking Capabilities

- * FR2 Generate Configurable Benchmark Workloads *

As a developer, I want to generate configurable benchmark workloads so that I can simulate different usage scenarios of Hades and evaluate how the system behaves under varying conditions. The CI-Benchmarker shall enable the creation of workloads that vary in the number of build jobs, submission rate, priority distribution, and composition of build steps. These parameters allow developers and system administrators to reproduce realistic situations, such as exam-time submission peaks or continuous background usage, and to study system performance across a range of operational conditions.

- * FR3 Collect End-to-End Performance Metrics *

As a developer, I want to collect end-to-end performance metrics for submitted build jobs so that I can analyze how different system configurations affect latency, throughput, and overall execution behavior. To support this goal, the CI-Benchmarker shall measure key indicators such as the time from submission to completion, waiting time before execution, and the number of jobs processed over a given interval. In addition, it shall allow identical workloads to be executed against different Hades configurations or execution modes, and record their performance results in a comparable form. These capabilities enable systematic comparison between alternative architectural designs, tuning strategies, or operator versions, providing a data-driven foundation for performance evaluation and optimization.

- * FR4 Produce Benchmark Reports for Analysis *

As a developer, I want to obtain structured benchmark reports so that I can interpret performance results efficiently and identify potential bottlenecks in the system. To support this goal, the CI-Benchmarker shall aggregate the collected performance data and generate reports that summarize key metrics, such as latency distributions, throughput over time, and comparative outcomes across different system configurations. These reports shall be suitable for manual inspection by developers and system administrators and provide actionable insights that guide further optimization and architectural evaluation.

=== Quality Attributes
// #TODO[
//   List and describe all quality attributes of your system. All your quality attributes shall fall into the URPS categories mentioned in @bruegge2004object. Also mention requirements that you were not able to realize.

//   - QA1 Category: Short Description. 
//   - QA2 Category: Short Description. 
//   - QA3 Category: Short Description.

// ]

This section describes the quality attributes of the proposed system following the URPS categories outlined by Bruegge and Dutoit @bruegge2004object. Unlike functional requirements, which specify what the system shall do, quality attributes specify how the system shall behave under a variety of conditions.

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

The benchmarking subsystem shall be easy for developers and system administrators to learn and operate. It shall expose a simple and well-documented interface that allows benchmark runs to be triggered using familiar tools such as HTTP clients or command-line utilities. Developers shall be able to initiate benchmarking activities without requiring detailed knowledge of Hades’s internal execution architecture.

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

=== Scenarios
// #TODO[
//   If you do not distinguish between visionary and demo scenarios, you can remove the two subsubsections below and list all scenarios here.

//   *Visionary Scenarios*
//   Describe 1-2 visionary scenario here, i.e. a scenario that would perfectly solve your problem, even if it might not be realizable. Use free text description.

//   *Demo Scenarios*
//   Describe 1-2 demo scenario here, i.e. a scenario that you can implement and demonstrate until the end of your thesis. Use free text description.
// ]

=== Use Case Model
// #TODO[
//   This subsection shall contain a UML Use Case Diagram including roles and their use cases. You can use colors to indicate priorities. Think about splitting the diagram into multiple ones if you have more than 10 use cases. *Important:* Make sure to describe the most important use cases using the use case table template (./tex/use-case-table.tex). Also describe the rationale of the use case model, i.e. why you modeled it like you show it in the diagram.

// ]

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