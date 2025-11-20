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
//   This section is only required if the proposed system (i.e. the system that you develop in the thesis) should replace an existing system.
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
//   List and describe all functional requirements of your system. Also mention requirements that you were not able to realize. The short title should be in the form “verb objective”

//   - FR1 Short Title: Short Description. 
//   - FR2 Short Title: Short Description. 
//   - FR3 Short Title: Short Description.
// ]

// TODO: Add some words here

==== Core System Capabilities

- * FR1 Manage and Orchestrate Build Job Execution *

The system shall provide a dedicated orchestration component that manages the lifecycle of build jobs once they enter the execution phase. This includes maintaining explicit job states, coordinating the transition between these states, and initiating the actions required to advance a job toward completion. The orchestration component ensures that build jobs progress in a controlled and consistent manner within the execution environment.

- * FR2 Support Automated Deployment of System Components *

The system shall offer a structured and repeatable method for deploying and configuring its components. This includes initializing required services, applying consistent configurations, and minimizing manual steps during setup or upgrade. The objective is to reduce configuration drift, lower operational overhead, and improve reliability during system evolution.

- * FR3 Provide System-Wide Observability *

The system shall collect, aggregate, and expose log data and operational information generated throughout the build-job lifecycle. This includes recording execution outputs, error conditions, and relevant runtime metadata. The purpose is to enhance transparency, support debugging, and allow administrators and developers to gain clearer insights into system behavior.

- * FR4 Distribute Workload Across Execution Resources *

The system shall assign build jobs to available execution resources in a manner that reflects current system load and capacity. This includes preventing resource hotspots, avoiding unnecessary queuing delays, and supporting efficient concurrent execution. The objective is to improve system scalability and maintain stable performance under varying workloads.

==== Benchmarking Capabilities

- * FR5 Support Multi-platform Benchmarking *

The system shall enable benchmarking across different execution configurations or system variants. This includes submitting identical workloads to different platform setups and recording comparable performance outcomes. The purpose is to evaluate how architectural or environmental differences impact system behavior.

- * FR6 Conduct and Analyze Performance Benchmarking *

The system shall generate representative workloads, submit them at controlled rates, and measure key performance indicators such as latency, throughput, and resource efficiency. It shall further compile these measurements into structured reports to support systematic analysis of performance trends and identification of bottlenecks.

=== Quality Attributes
// #TODO[
//   List and describe all quality attributes of your system. All your quality attributes should fall into the URPS categories mentioned in @bruegge2004object. Also mention requirements that you were not able to realize.

//   - QA1 Category: Short Description. 
//   - QA2 Category: Short Description. 
//   - QA3 Category: Short Description.

// ]

This section describes the quality attributes of the proposed system following the FURPS+ categorization recommended by @bruegge2004object . These attributes specify how the system should behave rather than what functionality it should provide. They define the expected levels of usability, reliability, performance, and supportability for the extended Hades architecture, including both the orchestration subsystem and the benchmarking subsystem. Attributes that could not be fully realized in the current work are also documented for completeness.

Usability
QA1 Provide Accessible Operational Insights

The system shall present execution information—such as job status, lifecycle transitions, and benchmarking summaries—in a manner that is easy for developers and system administrators to interpret. The goal is to enable users to understand system behavior without requiring detailed knowledge of internal mechanisms.

Reliability
QA2 Ensure Robust Lifecycle Management

The system shall maintain the integrity of job lifecycle information even under high load or partial failures. This includes ensuring that job states are updated consistently and that failures in execution environments do not lead to inconsistent or undefined system states.

QA3 Support Stable Execution Behavior

The system shall ensure that job orchestration and workload distribution behave deterministically under equivalent conditions, reducing variance in execution outcomes and increasing trust in system behavior during high-load scenarios.

Performance
QA4 Maintain Scalable Job Throughput

The system shall support the concurrent processing of multiple build jobs without significant degradation in response time or scheduling latency. The goal is to enable the system to function effectively during peak submission periods, such as practical examinations.

QA5 Enable Accurate Performance Measurement

The benchmarking subsystem shall measure latency, throughput, and resource utilization with sufficient fidelity to support reliable performance comparisons across system configurations.

Supportability
QA6 Facilitate Configuration and Deployment Evolution

The system shall allow its components to be deployed, upgraded, and reconfigured with minimal manual intervention. This includes supporting structured deployment workflows and reducing the likelihood of configuration drift over time.

QA7 Support Extensible Evaluation Scenarios

The benchmarking subsystem shall allow additional workload patterns or performance indicators to be incorporated with limited effort, enabling further experimentation beyond the scenarios implemented in this thesis.

Unrealized Quality Attributes
QA8 Adaptive Auto-Scaling of Execution Resources (Not Realized)

The system should automatically adjust execution capacity based on current workload intensity and predicted demand, providing elasticity under fluctuating load. This capability was not implemented due to scope limitations but remains a desirable quality attribute for future development.

=== Constraints

// #TODO[
//   List and describe all pseudo requirements of your system. Also mention requirements that you were not able to realize.

//   - C1 Category: Short Description. 
//   - C2 Category: Short Description. 
//   - C3 Category: Short Description.

// ]

== System Models
// #TODO[
//   This section includes important system models for the requirements.
// ]

// === Scenarios
// #TODO[
//   If you do not distinguish between visionary and demo scenarios, you can remove the two subsubsections below and list all scenarios here.

//   *Visionary Scenarios*
//   Describe 1-2 visionary scenario here, i.e. a scenario that would perfectly solve your problem, even if it might not be realizable. Use free text description.

//   *Demo Scenarios*
//   Describe 1-2 demo scenario here, i.e. a scenario that you can implement and demonstrate until the end of your thesis. Use free text description.
// ]

// === Use Case Model
// #TODO[
//   This subsection should contain a UML Use Case Diagram including roles and their use cases. You can use colors to indicate priorities. Think about splitting the diagram into multiple ones if you have more than 10 use cases. *Important:* Make sure to describe the most important use cases using the use case table template (./tex/use-case-table.tex). Also describe the rationale of the use case model, i.e. why you modeled it like you show it in the diagram.

// ]

=== Analysis Object Model
// #TODO[
//   This subsection should contain a UML Class Diagram showing the most important objects, attributes, methods and relations of your application domain including taxonomies using specification inheritance (see @bruegge2004object). Do not insert objects, attributes or methods of the solution domain. *Important:* Make sure to describe the analysis object model thoroughly in the text so that readers are able to understand the diagram. Also write about the rationale how and why you modeled the concepts like this.

// ]

=== Dynamic Model
// #TODO[
//   This subsection should contain dynamic UML diagrams. These can be a UML state diagrams, UML communication diagrams or UML activity diagrams.*Important:* Make sure to describe the diagram and its rationale in the text. *Do not use UML sequence diagrams.*
// ]

// === User Interface
// #TODO[
//   Show mockups of the user interface of the software you develop and their connections / transitions. You can also create a storyboard. *Important:* Describe the mockups and their rationale in the text.
// ]