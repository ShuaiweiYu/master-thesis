#import "/utils/todo.typ": TODO

= Architecture
#TODO[
  This chapter follows the System Design Document Template in @bruegge2004object. You describe in this chapter how you map the concepts of the application domain to the solution domain. Some sections are optional, if they do not apply to your problem. Cite @bruegge2004object several times in this chapter.
]

== Overview
#TODO[
  Provide a brief overview of the software architecture and references to other chapters (e.g. requirements), references to existing systems, constraints impacting the software architecture..
]

== Design Goals
// #TODO[
//   Derive design goals from your quality attributes and constraints, prioritize them (as they might conflict with each other) and describe the rationale of your prioritization. Any trade-offs between design goals (e.g., build vs. buy, memory space vs. response time), and the rationale behind the specific solution should be described in this section
// ]

Following the methodology of Bruegge and Dutoit @bruegge2004object, this section translates the identified quality attributes and constraints in @quality_attributes and @constraints into concrete design goals. This thesis establishes a clear prioritization to guide architectural design, prioritizing design trade-offs and providing the rationale for this prioritization. 

* Deterministic Job Lifecycle. * The execution system prioritizes strict job lifecycle semantics and deterministic job scheduling (QA1, QA2, QA3). This goal has the highest priority for the Hades infrastructure because an inconsistent build state undermines fundamental trust in the CI system. This prioritization necessitates a trade-off against orchestration latency (QA5): the design employs a custom Operator that continuously queries and updates the status of all Pods, strictly managing their lifecycle and actively deleting completed instances to guarantee state consistency. This approach accepts the computational cost of continuous reconciliation to prevent status inconsistency scenarios where the system reports a job as finished while the pod is still active.

* Enhanced Observability. * Diagnostic visibility must persist independently of the ephemeral container lifecycle (QA7, QA8). Since Kubernetes pods may be garbage-collected or evicted immediately after execution, the system is designed to capture and stream logs to a persistent store in real-time. This goal ensures that triggerer can diagnose build failures without requiring direct access to the underlying cluster infrastructure or kubectl, effectively masking the complexity of the distributed environment from the end-user.

* Concurrent Execution. * The central objective of the new system design is to achieve high-scale concurrent build execution, overcoming the constrained multitasking limitations of the legacy infrastructure (QA4). To support this expanded parallelism while maximizing system responsiveness (QA6), the design explicitly leverages the Kubernetes Native API for orchestration. By directly utilizing the efficient, asynchronous mechanisms of the Kubernetes control plane to dispatch and manage jobs, the system minimizes scheduling latency. This design choice enables the system to rapidly accept and process high-volume submission bursts without the performance bottlenecks inherent in the previous architecture.

* Benchmarking Usability. * This thesis designs the CI-Benchmarker to be a diagnostic instrument to enable developers to assess the performance of the Hades system and identify execution bottlenecks (QA9, QA10). The primary objective is to abstract the complexity of distributed load generation, allowing programmers to execute reproducible execution batches and analyze system behavior under various conditions.

* Reproducible Assessment and Efficient Reporting. * The benchmarking subsystem is designed to guarantee that identical workload specifications yield consistent and reproducible results across repeated runs, providing a reliable baseline for analysis (QA11). The system also prioritizes immediate and clear feedback for the developer (QA12). It is engineered to rapidly aggregate raw execution data into key performance metrics and present them in a concise, human-readable format. This design goal ensures that programmers can obtain actionable insights and statistically valid conclusions without the need to manually parse execution data.

== Subsystem Decomposition
// #TODO[
//   Describe the architecture of your system by decomposing it into subsystems and the services provided by each subsystem. Use UML class diagrams including packages / components for each subsystem.
// ]

Subsystem decomposition is a critical phase in system design used to manage complexity by partitioning the system into manageable, independent parts known as subsystems. In this context, a subsystem is defined by the services it provides to other parts of the system, where a service encapsulates a set of related operations sharing a common purpose @bruegge2004object.

Our decomposition strategy is guided by design goals established during the analysis phase. This thesis employs architectural techniques to ensure the system we design is scalable, maintainable, and robust. The initial decomposition is based on use cases and analysis models, and it is refined iteratively to ensure that all architectural requirements are met. In the following sections, we present the refined subsystem decomposition for our system, structured in two key parts:
+ * CI-Benchmarker *: A detailed breakdown of the CI-Benchmarker subsystem, defining its internal components and the services they offer.
+ * Interaction between Hades and External Trigger* : An architectural overview of how CI-Benchmarker and the Learning Platform as external triggers, interact with the key components of the Hades ecosystem to achieve system-wide collaboration.

=== CI-Benchmarker Subsystem Decomposition
The decomposition of the CI-Benchmarker subsystem is illustrated in @hades-benchmarker. This subsystem operates as a service-oriented architecture where distinct components collaborate to handle benchmark triggering, execution, data persistence, and metrics analysis.

#figure( image("../figures/Hades-benchmarker.png", width: 80%), caption: [Subsystem decomposition for CI-Benchmarker, indicating how the internal components collaborate], ) <hades-benchmarker>

- * Benchmark Router *
The Benchmark Router serves as the primary entry point for all external interactions, functioning effectively as an API gateway. It exposes REST endpoints to external users, facilitating communication with the system. By providing the Run Benchmark Service, it accepts requests to trigger new tasks, while the Benchmark Result Service allows users to query the outcomes of these tasks. Upon receiving a request, the Router validates the input and forwards the workload to the internal logic layer, which the controller handles.

- * Benchmark Controller *
Benchmark Controller provides the Benchmark Configuration Service, which the Router uses to pass specific configuration details such as pipeline definitions and concurrency settings. Once Benchmark Controller parses the configuration, it delegates specific actions to other components. It coordinates the workflow by determining whether to invoke execution logic or analysis logic, ensuring that tasks are distributed to the appropriate services.\

- *  Benchmark Executor *
The Benchmark Executor is responsible for dispatching build commands through its Benchmark Execution Service. This component abstracts the details of the underlying build systems, translating benchmark instructions into specific commands for external build executors, such as Hades or Jenkins. By doing so, it ensures that the core benchmarking logic remains decoupled from the specific CI tool being tested, allowing for flexibility and easier integration and extension with different build environments.

- * Benchmark Database *
The Benchmark Database handled data management, serving as the persistent storage layer for the subsystem. It exposes the Benchmark Persistence Service, allowing other components to store and retrieve raw execution data. This includes historical records such as BuildJob IDs, start timestamps, and end timestamps, which form the foundation for all post-execution analysis and reporting.

- * Benchmark Metrics Service *
The Benchmark Metrics Service functions as the analytical engine of the subsystem. It provides the Metrics Service interface to process requests for data analysis. By consuming the Benchmark Persistence Service, it fetches raw historical data to calculate statistical key performance indicators, such as average build execution time and average queue waiting time. Furthermore, it is responsible for generating visual diagrams, which are then presented to the user to offer insights into system performance.

=== Hades Subsystem and External Interactions
The architecture of the HadesCI subsystem and its interactions with external components are depicted in @hades-ci. This section details the internal decomposition of Hades and how it interfaces with the Learning Platform and the CI-Benchmarker to facilitate build execution and monitoring.

#figure( image("../figures/HadesCI.png"), caption: [Subsystem decomposition for HadesCI, CI-Benchmarker, Learning Platform, and inidicating their collaboration in system level.], ) <hades-ci>

- * Hades Gateway *
The Hades Gateway functions as the system's primary entry point for external requests. It exposes three critical interfaces: the Job Service, the Job Status Service, and the Prometheus Metric Service. The Job Service is responsible for accepting incoming build requests and validating that the job payload is legitimate before processing. To track the progress of these requests, the Job Status Service allows external clients to query the current lifecycle state of submitted builds. Simultaneously, the Gateway ensures system observability by providing cluster-wide metrics through the Prometheus Metric Service, allowing for health monitoring of the infrastructure.

- * Message Queue *
Acting as the internal communication bridge, the Queue component decouples the Gateway from the execution layer. It manages the flow of tasks by providing the Enqueue API for the Gateway to deposit validated jobs and the Dequeue API for consumers to retrieve them. In addition to message passing, the queue includes a Monitoring Service. This service enables administrators and developers to inspect the current state of the queue and monitor the status of pending Build Jobs, ensuring transparency in workload distribution.

- * Build Agent *
The Build Agent component acts as the execution engine and is composed of two primary sub-components: the Scheduler and the Kubernetes infrastructure. The Scheduler operates on a pull-based model, retrieving jobs via the Queue's Dequeue API only when free build resources are available. This design prevents the Scheduler from being overwhelmed by traffic spikes, ensuring stability within the execution layer. Once a job is claimed, the Scheduler delegates the task to the Kubernetes Operator. This component invokes the Kubernetes Driver to create native Kubernetes API objects, effectively spinning up the build pipeline within the containerized environment. Furthermore, the Operator continuously monitors the execution lifecycle via the Kubernetes Driver, actively updating the status of the build job to reflect its real-time progress.

- *  Integration with Learning Platform *
The Learning Platform serves as a representative use case for the Hades ecosystem, demonstrating how external systems interact with the CI infrastructure. In this scenario, the Learning Platform's Submission Build Trigger component acts as a client to the Hades Gateway, invoking the Job Service to dispatch build commands. To close the feedback loop, a dedicated Logging Server operates independently to manage build outputs. It connects to the Logging Agent within the Build Agent by consuming the exposed Logging Service. Through this interface, the Logging Server retrieves raw logs, aggregates them accordingly, and subsequently exposes the processed data via the Log Provider Service. This service is then consumed by the Learning Platform's Submission Log component to display execution details to end-users.

- * Integration with CI-Benchmarker *
The CI-Benchmarker interfaces with Hades to perform performance testing and analysis. Similar to the Learning Platform, the CI-Benchmarker's Benchmark Executor utilizes the Hades Gateway's Job Service to send build commands. To facilitate precise performance tracking, the system integrates a Benchmarking Result Parser. This component is responsible for parsing metrics directly from the build process and exposing them via the Build Information Service. The Benchmark Metrics Service then consumes this service to calculate and record detailed performance indicators.

== Hardware Software Mapping
// #TODO[
//   This section describes how the subsystems are mapped onto existing hardware and software components. The description is accompanied by a UML deployment diagram. The existing components are often off-the-shelf components. If the components are distributed on different nodes, the network infrastructure and the protocols are also described.
// ]

The system's deployment architecture, illustrating the mapping of software subsystems onto hardware nodes and execution environments, is depicted in @mapping. The system is distributed physically across two primary computing environments: a dedicated virtual machine for benchmarking and a container orchestration cluster for core execution.

#figure( image("../figures/HadesCI-Hardware:Software Mapping.png"), caption: [Hardware Software Mapping diagram indicating how the systems developed in this work are deployed onto the hardware target], ) <mapping>

The client-side components of the system are hosted on a dedicated Ubuntu Virtual Machine. This node is responsible for hosting the CI-Benchmarker subsystem. By isolating the benchmarking logic on a separate virtual machine, we ensure that the generation of benchmark loads and the collection of metrics do not consume the cluster's resources under test, thereby preventing the observer effect from skewing the performance data. This node communicates with the Hades system via REST protocol over HTTPS, sending benchmark requests directly to the Gateway located in the Kubernetes Cluster.

The core logic of the HadesCI system is deployed entirely within a Kubernetes Cluster, utilizing the platform's native capabilities for container orchestration. This environment hosts the critical server-side components, including the Gateway, the Queue, the Scheduler, and the Kubernetes Operator. Within this cluster, Hades utilizes NATS Jetstream to implement the Queue component, a high-performance messaging system. Communication between the Gateway to the Queue and the Queue to the Scheduler is conducted over raw TCP connections to minimize latency. Furthermore, the Scheduler uses the Kubernetes API to interact with the  Kubernetes Operator.

// == Persistent Data Management
// // #TODO[
// //   Optional section that describes how data is saved over the lifetime of the system and which data. Usually this is either done by saving data in structured files or in databases. If this is applicable for the thesis, describe the approach for persisting data here and show a UML class diagram how the entity objects are mapped to persistent storage. It contains a rationale of the selected storage scheme, file system or database, a description of the selected database and database administration issues.
// // ]

// Given the architectural focus on concurrency execution, this work designs the system to be largely stateless and not persistence-heavy. The data management strategy is therefore minimalistic, utilizing lightweight storage mechanisms tailored to the specific needs of the CI engine and the benchmarking tool, respectively.

// The CI-Benchmarker requires a structured storage mechanism to track benchmark histories and analytical results, yet it remains a lightweight subsystem. Consequently, this thesis selects SQLite as the database engine due to its serverless, zero-configuration nature, which integrates seamlessly with the standalone benchmarking environment. The data schema design prioritizes simplicity, comprising two primary tables that correlate job scheduling with execution performance. The `scheduled_job` table serves as the registry for task definitions. It stores the unique job ID, the timestamp of triggering, and the target executor (e.g., Hades or Jenkins). It also stores an optional commit hash to track specific benchmarking with code versions. The `job_results` table captures the temporal metrics necessary for performance analysis. It records the pipeline execution information by storing the `start_time` and `end_time`, keyed by the job's unique ID. This relational structure allows the Metrics Service to efficiently join scheduling data with execution timestamps to calculate key performance indicators.

// Designed as a stateless architecture, HadesCI delegates persistence to the NATS JetStream middleware rather than a centralized relational database. The current implementation utilizes JetStream's in-memory storage to prioritize throughput and minimize latency, aligning with the system's performance goals. However, the architecture retains the flexibility to switch to file-based storage, allowing for durable message persistence in the future.

== Access Control
// #TODO[
//   Optional section describing the access control and security issues based on the quality attributes and constraints. It also de- scribes the implementation of the access matrix based on capabilities or access control lists, the selection of authentication mechanisms and the use of en- cryption algorithms.
// ]

#figure(
  stack(
    dir: ttb,
    spacing: 10pt,

    text(size: 9pt)[
      #table(
        columns: (auto, auto, auto, auto, auto, auto, auto, auto),
        inset: 6pt,
        align: center + horizon,
        table.header(
          [*Subject*], [*ConfigMaps*], [*Secrets*], [*Pods*], [*Logs*], [*Events*], [*Batch Jobs*], [*BuildJobs*],
        ),
        
        // Row 1: Hades Operator
        [* Hades \ Operator *],
        [R, W, D], // ConfigMaps
        [R, W, D], // Secrets
        [R, W, D], // Pods
        [R],       // Logs (Read only)
        [W],       // Events (Write only)
        [R, W, D], // Jobs
        [R, W, D], // BuildJobs

        // Row 2: Hades Scheduler
        [* Hades \ Scheduler *],
        [R, C, D], // CM: No Update
        [-],       // Secrets: None
        [R, C, D], // Pods: No Update
        [-],       // Logs: None
        [-],       // Events: None
        [R, C, D], // Jobs: No Update
        [R, W, D], // BuildJobs: Full
      )
    ],

    text(size: 9pt, style: "italic")[
      Legend: R = Read, W = Write (Update/Patch), C = Create (No Update), D = Delete.
    ]
  ),
  caption: [access matrix],
)

== Kubernetes Native Design

// == Global Software Control
// #TODO[
//   Optional section describing the control flow of the system, in particular, whether a monolithic, event-driven control flow or concurrent processes have been selected, how requests are initiated and specific synchronization issues
// ]

// == Boundry Conditions
// #TODO[
//   Optional section describing the use cases how to start up the separate components of the system, how to shut them down, and what to do if a component or the system fails.
// ]
