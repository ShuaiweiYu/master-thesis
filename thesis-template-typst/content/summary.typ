// #import "/utils/todo.typ": TODO

#let r = 0.35em 
#let s-stroke = 0.5pt + black

#let s-full = box(
  baseline: 20%,
  circle(radius: r, fill: black, stroke: none)
)

#let s-part = box(
  baseline: 20%,
  width: 2 * r,
  height: 2 * r,
  radius: r,
  clip: true,
  stroke: s-stroke,
  align(left, rect(width: 50%, height: 100%, fill: black, stroke: none))
)

#let s-empty = box(
  baseline: 20%,
  circle(radius: r, fill: none, stroke: s-stroke)
)

= Summary
// #TODO[
//   This chapter includes the status of your thesis, a conclusion and an outlook about future work.
// ]

This chapter summarizes the work performed in this thesis regarding the design and implementation of HadesCI. It begins by presenting the current status of the project, detailing the realized goals and acknowledging the open requirements. Subsequently, the thesis concludes by highlighting the key contributions made to the field. Finally, an outlook is provided, suggesting potential directions for future enhancements.

== Status
// #TODO[
//   Describe honestly the achieved goals (e.g. the well implemented and tested use cases) and the open goals here. if you only have achieved goals, you did something wrong in your analysis.
// ]

This section evaluates the current implementation status of the project. It covers the Functional Requirements (FRs) for both the HadesCI system and the auxiliary CI-Benchmarker. Furthermore, given the highly technical nature of this thesis, the evaluation extends beyond basic functionality to include architectural Quality Attributes (QAs). This assessment of Quality Attributes is applied exclusively to HadesCI to validate the core architectural improvements, whereas the benchmarker is evaluated solely on its functional utility.

The degree of fulfillment for each requirement is summarized in @tab:status_summary. The status is indicated using the following symbols:
- #s-full : *Fully Achieved*. The requirement has been fully implemented and verified.
- #s-part : *Partially Achieved*. The requirement is implemented but has limitations or open issues.
- #s-empty : *Not Achieved*. The requirement has not been implemented or was deferred.

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, center),
    inset: 10pt,
    
    table.header(
      [*ID*], [*Requirement / Attribute*], [*Status*],
    ),
    
    // --- Functional Requirements ---
    table.cell(colspan: 3, fill: luma(240))[*Functional Requirements*],
    
    [FR1], [Manage Packaged Deployment of the Hades System], [#s-full],
    [FR2], [Generate Configurable Benchmark Workloads], [#s-part],
    [FR3], [Collect End-to-End Performance Metrics], [#s-full],
    [FR4], [Produce Benchmark Reports for Analysis], [#s-full],

    // --- Quality Attributes ---
    table.cell(colspan: 3, fill: luma(240))[*Quality Attributes*],
    
    [QA1], [Preserve Consistent Job Lifecycle Semantics], [#s-full],
    [QA2], [Preserve Deterministic Priority-Aware Scheduling], [#s-full],
    [QA3], [Fault-Tolerant Execution Delegation], [#s-full],
    [QA4], [Scalable Concurrent Execution], [#s-part],
    [QA5], [Low-Overhead Orchestration], [#s-full],
    [QA6], [Efficient Resource Utilization], [#s-empty],
    [QA7], [Reproducible and Maintainable Deployment Process], [#s-full],
    [QA8], [Accessible Build Job Logs and Diagnostics], [#s-part],
  ),
  caption: [Status of Functional Requirements and Quality Attributes],
) <tab:status_summary>

=== Realized Goals
// #TODO[
//   Summarize the achieved goals by repeating the realized requirements or use cases stating how you realized them.
// ]

The implementation of the proposed architecture successfully addressed the core functional and architectural requirements defined for the HadesCI system. The goals that have been fully achieved are categorized below into system stability, operational supportability, and benchmarking capabilities.

==== Core System Reliability and Correctness

A primary objective of this thesis was to transition the execution model to Kubernetes without compromising the strict behavioral guarantees of the original system. This thesis fully achieved this goal. The system preserves *QA1: Consistent Job Lifecycle Semantics*, ensuring that build jobs transition through their states deterministically, mirroring the behavior of the legacy implementation. Furthermore, *QA2: Deterministic Priority-Aware Scheduling* was successfully ported, ensuring that higher-priority submissions are processed ahead of lower-priority ones, even within the distributed nature of Kubernetes. Finally, the architecture demonstrates *QA3: Fault-Tolerant Execution Delegation*, as the orchestrator is capable of detecting pod failures or node interruptions and recovering the job state correctly, ensuring no submissions are lost.

==== Deployment and Supportability

To support the operational lifecycle of the system, this work improved the management capabilities. By fulfilling *FR1: Manage Packaged Deployment*, the system now utilizes a structured Helm-based deployment strategy. This mechanism directly enables *QA7: Reproducible and Maintainable Deployment Process*, allowing system administrators to install, upgrade, and configure the Hades environment consistently across different clusters with minimal manual intervention.

==== Orchestration Performance

From a performance perspective, the architectural changes proved to be efficient for the targeted orchestration tasks. The system achieves *QA5: Low-Overhead Orchestration*, where the control logic introduces negligible latency relative to the build duration, ensuring that the orchestration layer does not become a bottleneck during job processing.

==== Benchmarking and Evaluation Tools

The development of the CI-Benchmarker served as a critical enabler for validating the system's performance metrics. The tool fully satisfies *FR3: Collect End-to-End Performance Metrics* and *FR4: Produce Benchmark Reports*. It successfully captures accurate build triggering, execution and finish timing data. CI-Benchmarker aggregates these data into structured reports, providing the empirical data needed to quantitatively compare the new Kubernetes-based architecture against the baseline.

=== Open Goals
// #TODO[
//   Summarize the open goals by repeating the open requirements or use cases and explaining why you were not able to achieve them. Important: It might be suspicious, if you do not have open goals. This usually indicates that you did not thoroughly analyze your problems.
// ]

While the project realized the core architectural objectives of HadesCI, we deferred or only partially met several requirements due to specific design trade-offs and scope prioritizations. This section analyzes these open goals, discussing the limitations alongside the rationale behind our implementation decisions.

==== Limitation in Benchmark Workload Complexity

Although *FR2 (Generate Configurable Benchmark Workloads)* allows users to target different systems and trigger concurrent builds, the scenario complexity remains limited. Currently, the system replicates the exact same workload for every concurrent instance, lacking the capability to generate heterogeneous traffic patterns, such as mixing short unit tests with long integration builds. We prioritized usability over complexity for this requirement. Enabling granular, heterogeneous workload definitions would increase the configuration overhead for the user, making the CI-Benchmarker prone to misconfiguration. Since the current uniform workload capability is sufficient to validate the system's baseline performance, we have deferred support for complex mixed scenarios to maintain a streamlined user experience.

==== Resource Management and Scalability Constraints

*QA4: Scalable Concurrent Execution* is considered partially achieved. While the system supports concurrent execution, the build duration increases noticeably when cluster resources are constrained, as the current implementation lacks advanced optimizations such as artifact caching or dynamic resource allocation. We intentionally deferred these features because we focused primarily on establishing the architectural correctness of the migration to Kubernetes. Implementing distributed caching requires introducing complex state management into the ephemeral build environments. We deemed this out of scope for the initial architectural implementation, as it represents a performance optimization rather than a fundamental architectural requirement.

Similarly, we did not achieve *QA6: Efficient Resource Utilization*, as the current design does not include a custom load balancer or an application-aware scheduling strategy. Instead, the system relies entirely on the native Kubernetes scheduler, which is based on standard CPU and memory requests. This decision aligns with cloud-native principles. We utilized the native orchestration capabilities of Kubernetes because the standard Kubernetes scheduler is sufficiently robust for general-purpose CI workloads. Creating custom scheduling logic would add unjustified maintenance debt and complexity.

==== Latency in Log Observability

Finally, *QA8: Accessible Build Job Logs and Diagnostics* faces a limitation regarding real-time feedback. The current log retrieval mechanism is not stream based, it transmits logs only after a container has fully completed its execution, meaning users receive no feedback during long-running steps. We selected this trade-off to favor architectural simplicity and resource efficiency. Implementing real-time log streaming would introduce additional continuous connection overhead to the orchestration layer. To ensure the orchestrator remains lightweight and to minimize the resource footprint per pod, we implemented a batch-transmission model as the most efficient solution for this stage of development.

== Conclusion
// #TODO[
//   Recap shortly which problem you solved in your thesis and discuss your *contributions* here.
// ]

This thesis addressed the challenge of modernizing the Continuous Integration infrastructure by designing and implementing a Kubernetes-native Operator for the HadesCI system. By transitioning the execution model from a static Docker-based approach to a dynamic, orchestrator-managed architecture, this work established a functional research prototype that serves as the foundation for future scalable integration with the Artemis education platform.

The primary contributions of this work are threefold. The core contribution of this work is the design and implementation of the Kubernetes-native Hades Operator, which transforms the legacy build execution model into a robust, orchestrator-managed architecture. By developing a custom controller that delegates build jobs to transient pods, this solution leverages Kubernetes' native reconciliation loop to ensure consistent job lifecycle management and inherent fault tolerance, effectively modernizing the system's foundation and enhancing the system's concurrency. Complementing this primary achievement, we developed the CI-Benchmarker, a specialized tool designed to validate the new architecture by generating configurable workloads and collecting high-resolution performance metrics. Finally, utilizing this framework, we provided a systematic quantitative analysis of the system's behavior under varying levels of concurrency, identifying the throughput capabilities and latency characteristics that define the operator's performance profile.

The results of this investigation demonstrate that the Kubernetes-native approach offers distinct advantages in terms of scalability and operability. The use of standard container orchestration primitives enables more efficient resource utilization and facilitates a standardized, reproducible deployment process via Helm. However, this transition is not without trade-offs; it introduces inherent architectural complexity, specifically regarding the management of custom operator logic. Ultimately, this thesis concludes that while the move to Kubernetes increases the initial complexity, it provides a robust and scalable foundation necessary for the long-term evolution of the HadesCI system.

== Future Work
// #TODO[
//   Tell us the next steps (that you would do if you have more time). Be creative, visionary and open-minded here.
// ]

The realization of the Kubernetes-native Hades operator opens several avenues for future research and engineering efforts. While the current system serves as a functional research prototype, transforming it into a production-grade infrastructure for the Artemis platform requires addressing specific challenges related to multi-tenancy, advanced scheduling, operational efficiency, and security.

=== Production-Grade Artemis Integration

To fully integrate HadesCI into Artemis's production environment, future development must address the complexities of large-scale multi-tenancy. A critical next step is implementing multi-course isolation, potentially leveraging Kubernetes Namespaces to ensure that resource-intensive courses do not degrade the performance of others. Furthermore, to prevent resource monopolization, the system requires student-level quotas and rate-limiting mechanisms. Special attention should also be given to exam burst protection, ensuring that the system reserves dedicated capacity and prioritizes stability during the critical, high-concurrency windows typical of university examinations.

=== Advanced Scheduling Strategies

Beyond basic priority queues, the orchestrator's intelligence can be significantly enhanced to support complex educational scenarios. We propose exploring deadline-aware scheduling algorithms that dynamically elevate the priority of submissions approaching a homework deadline, ensuring timely feedback for students. Additionally, distinct operational profiles could be introduced for exam-mode versus practice-mode. This would allow the system to switch strategies, enforcing strict latency guarantees during exams while maximizing overall throughput and resource packing during regular practice periods.

=== Autoscaling and Cost Awareness

To optimize operational efficiency, future work should extend the system's control over the underlying infrastructure. Integrating node autoscaling would allow the cluster to dynamically provision additional compute nodes during peak loads and scale down during quiet periods, thereby moving beyond simple pod scaling. Coupled with this, implementing a cost-per-submission analysis module would provide administrators with granular visibility into resource consumption, enabling them to make data-driven decisions that balance performance requirements with cloud infrastructure costs.

=== Security Hardening

Since the system executes arbitrary code submitted by students, strengthening the security posture is a paramount objective. Future iterations should evaluate pod sandboxing technologies to provide a stronger isolation layer between untrusted user code and the host kernel. Complementing this, the implementation of strict NetworkPolicies is essential to enforce fine-grained network access controls, effectively preventing build jobs from accessing sensitive internal services or unauthorized external networks.
