#import "/utils/todo.typ": TODO

= Architecture
// #TODO[
//   This chapter follows the System Design Document Template in @bruegge2004object. You describe in this chapter how you map the concepts of the application domain to the solution domain. Some sections are optional, if they do not apply to your problem. Cite @bruegge2004object several times in this chapter.
// ]

== Overview
// #TODO[
//   Provide a brief overview of the software architecture and references to other chapters (e.g. requirements), references to existing systems, constraints impacting the software architecture..
// ]

This chapter describes the software architecture of the Hades system, bridging the gap between the application domain concepts identified in the Analysis Chapter and the technical solution domain. Following the object-oriented design methodology outlined by Bruegge and Dutoit @bruegge2004object, we transform the functional requirements and constraints into a concrete subsystem decomposition and hardware mapping.

The architecture is fundamentally designed as a distributed, event-driven system, moving away from the monolithic patterns typical of legacy CI solutions. To satisfy the conflicting constraints of high concurrency and rigorous state management, the solution leverages the Kubernetes Operator pattern. This approach allows the system to offload complex orchestration logic to the Kubernetes control plane while maintaining a custom reconciliation loop for deterministic build management.

The system is partitioned into two primary subsystems: HadesCI, which handles the core execution and scheduling logic, and CI-Benchmarker, a diagnostic subsystem designed to evaluate and validate the performance of the infrastructure. These subsystems interact through well-defined service interfaces and asynchronous messaging queues, ensuring loose coupling and independent scalability. The chapter proceeds by establishing the design goals that drive these architectural decisions, followed by a detailed breakdown of the component interactions and physical deployment strategies across virtualized and containerized environments.

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

- * Benchmark Controller *
The Benchmark Controller serves as the central processing unit and the primary entry point for the subsystem, consolidating the responsibilities of API exposure and workflow orchestration. It directly exposes REST endpoints to external users through two key interfaces: the Run Benchmark Service, which accepts requests to trigger new tasks, and the Benchmark Result Service, which allows users to query the outcomes of tasks. Upon receiving a request, the Controller validates the input payload and parses the specific configuration details. As a dispatcher, the Controller determines the necessary action and delegates tasks to the appropriate components, invoking either the Benchmark Execution Service to run jobs or the Metrics Service for data analysis.

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
The Hades Gateway functions as the system's primary entry point for external requests. It exposes the Job Service interface, which serves as the sole channel for task submission. This service is responsible for accepting incoming build requests and validating that the job payload is legitimate. Once validated, the Gateway ensures the request is formatted correctly before passing it downstream for processing.

- * Message Queue *
Acting as the internal communication bridge, the Queue component effectively decouples the Gateway from the execution layer. It manages the flow of tasks by providing the Enqueue API for the Gateway to deposit validated jobs and the Dequeue API for consumers to retrieve them. By buffering requests, it facilitates asynchronous communication, ensuring that the ingestion of tasks remains independent of the immediate availability of execution resources.

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

The system's deployment architecture, illustrating the mapping of software subsystems onto hardware nodes and execution environments, is depicted in @mapping. The architecture is designed to be infrastructure-agnostic, with physical distribution across a dedicated client-side benchmarking node and multiple variations of server-side execution environments.

#figure( image("../figures/HadesCI-Hardware:Software Mapping.png"), caption: [Hardware Software Mapping diagram indicating how the systems developed in this work are deployed onto the hardware target], ) <mapping>

The client-side components are hosted on an Ubuntu Virtual Machine. This node is responsible for hosting the CI-Benchmarker subsystem. By isolating the benchmarking logic on a separate virtual machine, we ensure that the generation of benchmark loads and the collection of metrics do not consume the cluster's resources under test, thereby preventing skewing the performance data. This node communicates with any deployed instance of the Hades system via the REST protocol over HTTPS, sending benchmark requests directly to the Gateway.

The core logic of the HadesCI system is deployed entirely within a Kubernetes Cluster, utilizing the platform's native capabilities for container orchestration. This environment hosts the critical server-side components, including the Gateway, the Queue, the Scheduler, and the Kubernetes Operator. Within this cluster, Hades utilizes NATS Jetstream to implement the Queue component, a high-performance messaging system. Communication between the Gateway to the Queue and the Queue to the Scheduler is conducted over raw TCP connections to minimize latency. Furthermore, the Scheduler uses the Kubernetes API to interact with the  Kubernetes Operator.

To demonstrate the system's adaptability, the architecture supports multiple deployment targets on varying scales of infrastructure, ensuring flexibility across a broad spectrum of hardware capabilities:

- Standalone Docker Environment: The system can be deployed on a standard Ubuntu VM utilizing a Docker-based runtime. This mode is suitable for simplified, non-orchestrated setups where the overhead of Kubernetes is not required.

- Lightweight Edge Environment: The system is also compatible with K3s, a lightweight Kubernetes distribution, demonstrating that HadesCI can operate effectively in resource-constrained environments. 


// == Persistent Data Management
// // #TODO[
// //   Optional section that describes how data is saved over the lifetime of the system and which data. Usually this is either done by saving data in structured files or in databases. If this is applicable for the thesis, describe the approach for persisting data here and show a UML class diagram how the entity objects are mapped to persistent storage. It contains a rationale of the selected storage scheme, file system or database, a description of the selected database and database administration issues.
// // ]

// Given the architectural focus on concurrency execution, this work designs the system to be largely stateless and not persistence-heavy. The data management strategy is therefore minimalistic, utilizing lightweight storage mechanisms tailored to the specific needs of the CI engine and the benchmarking tool, respectively.

// The CI-Benchmarker requires a structured storage mechanism to track benchmark histories and analytical results, yet it remains a lightweight subsystem. Consequently, this thesis selects SQLite as the database engine due to its serverless, zero-configuration nature, which integrates seamlessly with the standalone benchmarking environment. The data schema design prioritizes simplicity, comprising two primary tables that correlate job scheduling with execution performance. The `scheduled_job` table serves as the registry for task definitions. It stores the unique job ID, the timestamp of triggering, and the target executor (e.g., Hades or Jenkins). It also stores an optional commit hash to track specific benchmarking with code versions. The `job_results` table captures the temporal metrics necessary for performance analysis. It records the pipeline execution information by storing the `start_time` and `end_time`, keyed by the job's unique ID. This relational structure allows the Metrics Service to efficiently join scheduling data with execution timestamps to calculate key performance indicators.

// Designed as a stateless architecture, HadesCI delegates persistence to the NATS JetStream middleware rather than a centralized relational database. The current implementation utilizes JetStream's in-memory storage to prioritize throughput and minimize latency, aligning with the system's performance goals. However, the architecture retains the flexibility to switch to file-based storage, allowing for durable message persistence in the future.


== Kubernetes Native Design

To address the complexity of orchestrating distributed workloads, the system adopts a Kubernetes-native architecture based on the Operator pattern. Instead of relying on an external, imperative control plane, we extend the Kubernetes API via Custom Resource Definitions to manage domain-specific logic directly within the cluster.

The primary motivation for this design choice is to leverage the robust capabilities of the Kubernetes control plane with its declarative API and level-triggered reconciliation loops. By delegating low-level orchestration concerns such as scheduling and networking to Kubernetes, the system ensures that the observed state continuously converges towards the desired state. This approach seamlessly maps CI workloads to ephemeral Kubernetes resources. It allows the build infrastructure to be as elastic as the cluster itself, providing superior scalability and integration compared to traditional CI services that rely on static build agents.

=== Design Principles

The architectural foundation of HadesCI relies on a declarative resource management model. This approach differs from the imperative execution flows common in traditional CI systems. In this paradigm, the system accepts a BuildJob Custom Resource that encapsulates the execution requirements, including container images, resource constraints, and the target build scripts. Rather than prescribing a procedural sequence of infrastructure operations, the BuildJob defines the required execution environment. The Operator's responsibility is to ensure that the cluster infrastructure converges to match this specification. Consequently, HadesCI provisions and manages the lifecycle of the build infrastructure to reach the desired state. This abstraction effectively decouples the pipeline definition from the underlying infrastructure complexity, allowing the system to dynamically adapt resource allocation to satisfy the specifications defined in the Custom Resource.

To implement the declarative model, the system utilizes a continuous control loop and reconciliation mechanism. HadesCI continuously observes the actual state of the cluster and compares it with the desired state. When a discrepancy arises, the reconciliation loop automatically applies the necessary operations to drive the system towards convergence. For a CI platform, this design ensures high reliability because the system can automatically detect pending or interrupted build jobs even if the control plane temporarily restarts or network partitions occur. This mechanism guarantees eventual consistency and ensures that the build execution state aligns with the specifications defined in the Custom Resource, regardless of transient infrastructure failures.

The Operator pattern relies on a separation between the desired and observed states, a pattern intrinsic to the Kubernetes API structure. Within the HadesCI data model, user intent is encapsulated in an immutable Spec field, while the current reality of the system is reflected in a distinct Status subresource. The controller asynchronously updates the Status to reflect real-time metrics, Pod lifecycles, and error conditions, while never modifying the user's original intent. This separation prevents race conditions during concurrent updates and provides a native, high-fidelity observability interface. It enables external tools and users to query the exact progress of a pipeline directly through the Kubernetes API, eliminating the need for a separate status database.

=== Custom Resource Model

The core abstraction of the HadesCI architecture is the `BuildJob` Custom Resource Definition (CRD), which can be found in #link(<crd>)[Custom Resource Definition]. Instead of coupling the pipeline logic with the raw complexity of Kubernetes primitives, such as volume mounting, init containers, and networking. The `BuildJob` resource provides a simplified, domain-specific abstraction. This resource acts as the contract between the CI orchestration layer and the underlying infrastructure, encapsulating the entire lifecycle of a build task into a single, atomic object.

The design of the `BuildJob` follows a "Pipeline-as-Code" philosophy but is strictly typed to ensure structural validity. The schema focuses on defining the execution topology: a linear sequence of atomic units defined in the `spec.steps` array. Each step is an isolated execution environment characterized by a container image, a specific script, and strict resource boundaries indicated with cpuLimit and `memoryLimit`. By formalizing the pipeline steps as an ordered list with unique identifiers, the CRD effectively serializes the build process. This abstraction allows the system to handle data persistence implicitly; the Operator automatically provisions shared storage volumes between these steps, allowing artifacts produced in Step $N$ to be consumed by Step $N+1$ without requiring explicit user configuration.

The data model strictly adheres to the Kubernetes pattern of separating configuration from state:

* The Spec (`spec`) *: Serves as the immutable blueprint of the desired state, encapsulating the complete execution context required to instantiate a build pipeline. It defines the execution topology, which comprises the sequence and composition of steps, along with operational boundaries such as timeouts and retry policies. By aggregating the logical workflow with infrastructure constraints, the spec acts as the Single Source of Truth, allowing the Operator to execute the workload deterministically without relying on external configuration sources.
* The Status (`status`) *: Functions as a dynamic state machine for the Operator, whose subresource maintains a granular record of execution progress, including the `currentStep` pointer and the specific phase, which contains `Pending`, `Running`, `Succeeded`, and `Failed`. This detailed tracking is essential for the reconciliation loop: if a controller crashes and restarts, it can examine the `status.currentStep` to resume monitoring exactly where it left off, rather than restarting the pipeline from scratch.

The `BuildJob` does not execute logic itself. Instead, it serves as a blueprint that the Operator translates into native Kubernetes resources. A single `BuildJob` maps to a Kubernetes Pod, where each logical step defined in the CRD is realized as a container within the Pod. The system utilizes Owner References to bind the lifecycle of the generated Pods to their parent `BuildJob`. This ensures cascading deletion: when a BuildJob is deleted through retention policy, the underlying Pods and volumes are automatically garbage-collected by the Kubernetes control plane, preventing resource leaks. This mapping allows HadesCI to leverage the mature scheduling capabilities of Kubernetes while presenting a simplified API surface.

=== Operator Architecture

The operator controller acts as the authoritative orchestrator within the system, primarily responsible for continuously monitoring the lifecycle of `BuildJob` resources and ensuring their execution requirements are met. To achieve this, the controller executes three synchronized functions: it performs lifecycle translation by converting high-level CI definitions into executable Kubernetes workloads. Then it enforces admission control through concurrency limits and priority scheduling before execution begins, and it manages state aggregation by reflecting the granular status of low-level Pod containers back onto the high-level `BuildJob` status while propagating these events to the external NATS messaging system.

#figure( image("../figures/k8s-reconcile.png"), caption: [Activity diagram indicating the reconcile internal workflow.], ) <reconcile>

The reconciliation loop inside the controller is triggered whenever a `BuildJob` is created, updated, or when its underlying resources change. The logic follows a structured workflow designed to ensure consistency and correctness as detailed in @reconcile.

+ * Mapping BuildJob to Kubernetes Primitives: * To enforce the strict sequential execution requirement of CI steps defined in the `BuildJob` Spec, the controller employs the init container of Kubernetes.

  - Each logical `Step` in the `BuildJob` is mapped one-to-one to an init Container in the underlying Kubernetes Job. Since Kubernetes guarantees that init Containers execute strictly in order and to completion before the next one starts, this natively enforces the pipeline's dependency graph without requiring a complex internal scheduler.
  - A shared EmptyDir volume is automatically mounted across all containers, establishing a shared workspace where artifacts from previous steps are persisted and accessible to subsequent ones.
  - The Script defined in the CRD is injected as the container's entrypoint command, transforming the container image into an ephemeral build agent.

+ * Concurrency Control and Priority Scheduling: * Instead of relying on an external queue, the controller implements in-cluster admission control using the Kubernetes Job `Suspend` feature.

  - * Admission Gate: * Upon receiving a new `BuildJob`, the controller calculates the current cluster load. If the number of active jobs exceeds the configured `MaxParallelism` threshold, the controller creates the underlying Kubernetes Job in a Suspended state. This effectively queues the workload in the API server without consuming compute resources.
  - * Priority-Based Admission: * When a running job completes and frees up a concurrency slot, the controller scans all suspended jobs to determine which one to resume. It employs a Priority Queue algorithm to select the next job with the highest priority for execution. This ensures that critical build tasks are processed ahead of standard submissions.

+ * State Propagation and Observability: * The controller maintains a continuous feedback loop by monitoring the status of the generated Kubernetes Job and its associated Pods. As containers transition through various states, the controller aggregates this information to update the `BuildJob` status. Finally, upon the confirmation of a terminal state, the controller enforces resource hygiene by automatically triggering the deletion of the `BuildJob` Custom Resource. Utilizing Kubernetes' foreground cascading deletion, this ensures that all associated underlying artifacts, including Pods, Jobs, and volumes, are gracefully garbage-collected, thereby preventing resource exhaustion in the cluster.





== Access Control
// #TODO[
//   Optional section describing the access control and security issues based on the quality attributes and constraints. It also de- scribes the implementation of the access matrix based on capabilities or access control lists, the selection of authentication mechanisms and the use of en- cryption algorithms.
// ]

The HadesAPI implements HTTP Basic Authentication to secure the public-facing endpoints. As the primary gateway for triggering builds, the HadesAPI requires all incoming requests to include valid credentials encoded in the HTTP header. This mechanism ensures that only authorized clients can invoke the Job Service. By validating identity at the HadesAPI side, the system effectively prevents unauthorized users from dispatching malicious workloads or consuming cluster resources.

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
        [R], // CM: No Update
        [-],       // Secrets: None
        [R], // Pods: No Update
        [-],       // Logs: None
        [-],       // Events: None
        [-], // Jobs: No Update
        [C], // BuildJobs: Full
      )
    ],

    text(size: 9pt, style: "italic")[
      Legend: R = Read, W = Write (Update/Patch), C = Create (No Update), D = Delete.
    ]
  ),
  caption: [Kubernetes RBAC access matrix showing the separation of responsibilities between the Hades scheduler and operator components.],
) <access_matrix>

Internal access control within the cluster is governed by Kubernetes Role-Based Access Control (RBAC), which strictly limits the capabilities of the system's microservices based on the Principle of Least Privilege. As detailed in the @access_matrix, the architecture enforces a strict separation of duties between the scheduling logic and the execution logic, ensuring that each component possesses only the permissions necessary for its specific function.

The Hades Scheduler operates under a restrictive security policy focused exclusively on task submission. Its primary responsibility is to translate abstract job requests into concrete Kubernetes Custom Resource (CR) definitions. Consequently, its permissions are narrowly scoped to the Creation of BuildJob objects, allowing it to submit new tasks to the cluster without the ability to modify or delete them. While it retains read access to ConfigMaps and Pods for self-configuration and capacity checking, the Scheduler is explicitly denied access to sensitive resources such as Secrets.

In contrast, the Hades Operator necessitates elevated privileges to fulfill its role as the central system controller responsible for end-to-end lifecycle management. To execute the reconciliation loop, the Operator holds comprehensive Read, Write, and Delete permissions across Pods, ConfigMaps, Secrets, and Batch Jobs. These privileges are operationally essential: the Operator must create Pods to execute builds, mount Secrets for repository authentication, write events to the Kubernetes event stream for observability, and patch the status of BuildJob CRs to reflect real-time progress. Furthermore, the Delete permission enables the Operator to perform garbage collection, automatically cleaning up ephemeral resources once a build concludes.

// == Global Software Control
// #TODO[
//   Optional section describing the control flow of the system, in particular, whether a monolithic, event-driven control flow or concurrent processes have been selected, how requests are initiated and specific synchronization issues
// ]

// == Boundry Conditions
// #TODO[
//   Optional section describing the use cases how to start up the separate components of the system, how to shut them down, and what to do if a component or the system fails.
// ]
