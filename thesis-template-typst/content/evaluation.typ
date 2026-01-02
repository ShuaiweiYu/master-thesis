#import "/utils/todo.typ": TODO

= Evaluation
#TODO[
  If you did an evaluation / case study, describe it here.
]

== Design 
// #TODO[
//   Describe the design / methodology of the evaluation and why you did it like that. e.g. what kind of evaluation have you done (e.g. questionnaire, personal interviews, simulation, quantitative analysis of metrics), what kind of participants, what kind of questions, what was the procedure?
// ]

To assess the performance and scalability of the Hades system, this thesis employs a quantitative analysis methodology for its evaluation. The primary objective is to empirically measure the system's behavior under controlled workload conditions, isolating the impact of different executor architectures on processing efficiency. The experimental design is structured around comparative testing of four distinct operation executors provided by Hades and Jenkins. This evaluation compares the performance of Hades' native execution engine against Jenkins, thereby quantifying potential improvements in latency and overhead offered by the Hades system. Furthermore, this evaluation assesses how the Kubernetes Operator implemented in this thesis enhances scalability and concurrency compared to basic containerization strategies. The four modes are defined as follows:

- * Hades Docker Executor *: The native, standalone execution mode. The Hades Docker Executor serves as a baseline to measure the intrinsic performance of the Hades engine, eliminating the complexity of cluster orchestration.

- * Jenkins Executor *: An executor that runs pipelines using the Jenkins CI platform, which represents one of the current market solutions. Benchmarking allows us to compare Hades with a mature, general-purpose CI tool, identifying performance gaps and advantages.

- * Hades Kubernetes Executor (K3s) *: The Operator-based implementation running on a lightweight K3s cluster. This tests the efficiency of the new architecture in a resource-constrained environment.

- * Hades Kubernetes Executor (Rancher) *: The Operator-based implementation running on a production-grade Rancher cluster. This is used to verify the scalability and concurrency improvements brought by the new Operator design under distributed load.

To provide a multifaceted view of system performance, we track the following key metrics for each job:

- * Queue Latency *: The duration from the moment a job is submitted to the system until it is scheduled and begins execution. This measures the efficiency of the dispatching mechanism.

- * Build Time *: The actual time consumed by the execution environment to compile and run the user's code.

- * End-to-End Latency *: The total wall-clock time perceived by the user, calculated as the sum of queue latency, build time, and system overheads.

- * Throughput *: The number of jobs completed per unit of time (jobs per second/minute), serving as the primary indicator of system scalability.

The evaluation is conducted using two distinct workload scenarios:
+ *  Baseline Performance (Low Concurrency) *
  - * Configuration *: Sequential execution of 5 benchmark jobs.
  - * Objective *: To establish a performance baseline for each operation mode under ideal conditions without resource contention. This helps in characterizing the intrinsic minimum overhead of each architecture.

+ *  Stress Testing (High Concurrency) *
  - * Configuration *: A burst workload of 100 jobs submitted simultaneously.
  - * Objective *: To evaluate the system's resilience under general high-concurrency conditions. Such scenarios mimic the burst traffic patterns typical of assignment deadlines or coding contests in educational environments.

By first establishing the baseline performance of different operation modes, we can determine the theoretical best-case efficiency of the Hades software design. Subsequently, the stress test reveals how each executor scales under load. This two-phase approach enables us to verify whether the system meets the latency requirements of interactive users while simultaneously identifying scalability bottlenecks within the orchestration layer. Ultimately, these insights enable us to identify specific areas for optimization, thereby enhancing the system's throughput in production environments.

== Objectives
// #TODO[
//   Derive concrete objectives / hypotheses for this evaluation from the general ones in the introduction.
// ]

Building upon the experimental design and workload scenarios detailed in the previous section, we define three concrete objectives to guide the analysis of the Hades system. These objectives clarify the specific insights we aim to derive from the performance metrics and stress tests:

=== O1: Compare Execution Engines 

To quantitatively benchmark the performance of Hades' execution engines (Docker and Kubernetes) against a standalone Jenkins CI platform. This objective aims to measure the efficiency of our custom implementation relative to an established industry standard, analyzing the performance gaps between a specialized grading system and a general-purpose CI tool.

=== O2: Assess Scalability under Concurrent Submissions 

To measure the system's capacity and stability when subjected to high-concurrency burst workloads. We aim to characterize the system's elastic behavior under stress, specifically investigating whether queue latency exhibits signs of congestion or backpressure, and determining if the system achieves linear throughput scaling or encounters resource saturation as load increases. This is crucial for verifying the system's readiness for real-world scenarios, such as the simultaneous submission of assignments by a large student cohort.

=== O3: Identify Performance Bottlenecks 

To analyze the sources of latency by decomposing the end-to-end processing time into granular phases. The goal is to isolate critical bottlenecks within the architecture, whether in the dispatching logic, container initialization, or external API interactions, to provide empirical data that will guide future optimizations and architectural refinements.


== Results
// #TODO[
//   Summarize the most interesting results of your evaluation (without interpretation). Additional results can be put into the appendix.
// ]

To ensure a fair comparison and isolate performance characteristics, the hardware resources were allocated according to the specific requirements of each executor mode. The CI-Benchmarker acts as the independent load generator and metrics collector. The specific resource allocations are detailed in @setup below:

#figure(
  table(
    columns: (auto, auto, auto, auto),
    
    align: (col, row) => (if col == 1 or col == 2 { center } else { left }),
    
    stroke: none,
    
    table.hline(stroke: 1.5pt),
    
    table.header(
      [*Environment*], [*vCPU*], [*RAM*], [*Topology*]
    ),
    
    table.hline(stroke: 0.5pt),
    
    [CI-Benchmarker], [4], [4 GB], [Single VM],
    [Hades Docker], [4], [4 GB], [Single VM],
    [Jenkins], [4], [4 GB], [Single VM],
    [K3s Cluster], [8], [16 GB], [Single Node],
    [Rancher Cluster], [100], [313 GB], [13 Nodes],
    
    table.hline(stroke: 1.5pt),
  ),
  caption: [Hardware Configuration of Evaluation Environments],
) <setup>

// todo: put the payload in the appendix
To simulate a realistic Continuous Integration workload typical of student assignments, we defined a standardized Hades payload. This job consists of a four-stage pipeline as indicated in #link(<build_script>)[Build Script]. The structure is designed not only to perform the build task but also to capture precise timestamps for latency calculation.

- * Step 1: Report Starting Time *
  - * Action *: Triggers a lightweight reporter container (hades-reporter).
  - * Purpose *: Sends a signal to the CI-Benchmarker to mark the exact timestamp when the job execution officially begins (used to calculate Queue Latency).

- * Step 2: Clone *
  - * Action *: Executes the hades-clone-container.
  - * Purpose *: Fetches the necessary repositories (test code and assignment code) from the version control system into the shared workspace.

- * Step 3: Execute (Build & Test) *
  - * Action *: Runs a Java 17 container (artemis-maven-template) to execute a Gradle build script.
  - * Purpose *: Represents the core workload. This step involves compiling the code and running unit tests, simulating the heaviest part of a grading pipeline.

- * Step 4: Result & Report End Time *
  - * Action *: Parses the JUnit XML results using junit-result-parser.
  - * Purpose *: Aggregates the test results and sends the final signal to the CI-Benchmarker, marking the completion of the job (used to calculate Total Latency).

Based on the data collected from the CI-Benchmarker using the given Hades Build Job Definition, the performance metrics are calculated as follows:

- * Queue Latency *: The duration between the Job Submission (by Benchmarker) and the Report Starting Time (Step 1). This measures the overhead of the scheduler and resource provisioning. 
$ T_"queue" = t_"step1_start" - t_"submission" $ <eq:queue_latency>

- * Build Time *: The duration required to process the pipeline logic, measured from the start of the first step to the completion of the final step. 
$ T_"build" = t_"step4_end" - t_"step1_start" $ <eq:build_time>

- * Total Latency (End-to-End) *: The total wall-clock time perceived by the user, representing the sum of queue latency and build time. 
$ T_"total" = L_"queue" + T_"build" = t_"step4_end" - t_"submission" $ <eq:total_latency>

- * Throughput *: The rate at which the system processes workloads, measured in jobs per second (JPS). It is calculated by dividing the total number of successfully completed jobs by the total duration of the experiment. 
$ R_"throughput" = N_"total" / T_"total" $ <eq:throughput>

The baseline benchmark involved the sequential execution of five standardized jobs. To isolate the intrinsic performance of each executor, each job was triggered only after the successful completion of the previous one. @baseline summarizes the average performance metrics recorded across the four operation modes.

#figure(
  text(size: 9pt)[
    #table(
      columns: (auto, auto, auto, auto, auto),
      align: (col, row) => (if col == 0 { left } else { center }),
      stroke: none,
      table.hline(stroke: 1.5pt),
      table.header(
        [*Operation Mode*], [*Queue Latency*], [*Build Time*], [*Total Latency*], [*Throughput*]
      ),
      table.hline(stroke: 0.5pt),
      
      // Data Rows
      [Hades Docker], [1.4 s], [13.6 s], [15.0 s], [0.33 JPS],
      [Jenkins], [14.2 s], [20.6 s], [34.8 s], [0.14 JPS],
      [K8S (K3s)], [2.0 s], [16.2 s], [18.2 s], [0.27 JPS],
      [K8S (Rancher)], [2.4 s], [15.6 s], [18.0 s], [0.28 JPS],
      
      table.hline(stroke: 1.5pt),
    )
  ],
  caption: [Baseline Performance Comparison (Sequential Execution of 5 Jobs)],
) <baseline>

To evaluate system scalability, a burst workload of 100 jobs was submitted. The system was configured with a concurrency limit of 10 for the Kubernetes executors to observe queue behavior. @tab:stress-results summarizes the distribution of Queue Latency and Build Time across the four operation modes.

#figure(
  text(size: 9pt)[
    #table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: none,
      table.hline(stroke: 1.5pt),
      
      table.header(
        table.cell(rowspan: 2, align: left + horizon)[*Operation Mode*],
        table.cell(colspan: 3)[*Queue Latency (s)*],
        table.cell(colspan: 3)[*Build Time (s)*],
        
        table.hline(stroke: 0.5pt),
        
        [*Avg*], [*Median*], [*Max*],
        [*Avg*], [*Median*], [*Max*]
      ),
      
      table.hline(stroke: 0.5pt),

      // Data Rows
      [Hades Docker],  [752],  [753],  [1504], [13], [14], [16],
      [Jenkins],       [1364], [1374], [2703], [20], [20], [33],
      [K8S (K3s)],     [305],  [319],  [602],  [51], [53], [68],
      [K8S (Rancher)], [133],  [134],  [278],  [17], [18], [26],

      table.hline(stroke: 1.5pt),
    )
  ],
  caption: [Performance Statistics under Stress Test (100 Jobs, 10 Concurrency for Kubernetes based executors)],
) <tab:stress-results>
== Findings
// #TODO[
//   Interpret the results and conclude interesting findings
// ]

Based on the quantitative results presented in the previous section, we derive several key findings regarding the architectural efficiency and resource behavior of the Hades system.

=== Findings from Baseline Benchmarks

The baseline comparison demonstrates that the Hades native execution engine reduces total latency by over 50% (34.8s to 15.0s) compared to the Jenkins integration, a performance gap driven by distinct factors in both phases. The most significant disparity lies in Queue Latency (1.4s vs. 14.2s), attributed mainly to Jenkins' default "quiet period" mechanism. While this feature intentionally coalesces commits in traditional workflows, it imposes an artificial delay that Hades eliminates to ensure instantaneous scheduling. Furthermore, regarding Build Time, Hades (13.6s) outperforms Jenkins (20.6s) by avoiding the initialization overhead of heavyweight Java agents and plugin hooks. By leveraging a container-native approach, Hades strips away these administrative costs, ensuring resources are utilized immediately for compiling user code rather than managing legacy CI infrastructure.

Transitioning from the standalone Hades Docker environment to a Kubernetes cluster introduces a build latency overhead of approximately 3 seconds. This increase is a characteristic inherent to distributed orchestration layers. While the native Docker mode communicates immediately with the local daemon, the Kubernetes modes require traversing the control plane, where time is consumed by operations such as API server processing and pod scheduling decisions. However, this overhead does not scale with cluster size, representing a necessary and acceptable trade-off to enable the horizontal scalability required for production environments.

Finally, the nearly identical performance of the lightweight K3s cluster and the massive Rancher cluster under baseline conditions suggests that single-job build latency is relatively insensitive to resource surplus. Despite the vast difference in available vCPUs (8 vs. 100), the total latency remained comparable. This suggests that for sequential workloads, the performance bottleneck lies in the software stack's initialization speed rather than raw computational power. Consequently, resource-constrained environments can provide a user experience identical to that of production-grade clusters when handling individual submissions.

=== Findings from Stress Tests

The stress test reveals the physical limitations inherent in the architecture of standalone execution environments. Under a burst load of 100 jobs, both the Hades Docker and Jenkins executors experienced a rapid, cumulative increase in queue latency. This phenomenon signifies a throughput bottleneck: the rate at which jobs are submitted exceeds the system's capacity to process them. As the limited execution slots become fully occupied, incoming submissions are forced into a holding phase, causing the wait time to stack up linearly for each subsequent job. Specifically, Hades Docker recorded an average wait time of 752 seconds, while Jenkins recorded an average wait time of 1,364 seconds.

Despite this severe congestion, the Build Time remained remarkably stable, averaging 13 seconds, virtually identical to the low-load baseline. This consistency indicates that the serialization strategy successfully isolates execution, ensuring that the heavy load of queued jobs does not degrade the performance of the currently running job. However, this stability is achieved at the cost of massive backpressure. While the system continues to function correctly and accept new submissions, the linear accumulation of wait time results in significant feedback latency, severely delaying the delivery of build results.

In contrast, transitioning to Kubernetes-based modes demonstrated the efficacy of the Operator Pattern in alleviating build job congestion. By leveraging Kubernetes Custom Resources (CRDs) to manage job lifecycles, the system gains the ability to dynamically schedule concurrent workloads, outperforming the standalone baselines in terms of queue throughput. The Rancher cluster reduced the average queue latency to 133 seconds, which is approximately 5.6 times faster than the standalone Docker mode. At the same time, the K3s cluster achieved a duration of 305 seconds. This validates that the Kubernetes Operator Pattern, which parallelizes execution across available pods rather than a single sequential queue, eases the burst workloads and improves system throughput.

However, a critical divergence emerges when analyzing the stability of Build Time, revealing the impact of resource saturation. The production-grade Rancher environment achieved near-linear scaling: despite the high concurrency, it maintained an average build time of 17 seconds, which is virtually identical to its baseline performance (15.6s). This confirms that with sufficient hardware resources, the system can handle high concurrency without degrading individual job performance. Conversely, the resource-constrained K3s environment, while successfully reducing queue wait times compared to Docker, suffered a degradation in execution speed. The average build time increased to 51 seconds. This phenomenon indicates that while the scheduler successfully distributed the concurrency, the limited hardware resources reached saturation, causing individual jobs to compete for processor cycles and prolonging the compilation process.

== Discussion
// #TODO[
//   Discuss the findings in more detail and also review possible disadvantages that you found
// ]

=== Divergence in Scheduling Paradigms and Execution Models

The quantitative performance gap observed in the baseline benchmarks reflects a divergence in design philosophy between traditional CI platforms and modern, container-native build systems. The significant disparity in queue latency: 1.4 seconds for Hades against 14.2 seconds for Jenkins, is primarily an artifact of the scheduling logic rather than computational throughput. Jenkins operates on a strategy of a Quiet Period. This mechanism is predicated on the observation that code submissions often occur in bursts, where minor corrections rapidly follow an initial commit #footnote[https://www.jenkins.io/blog/2010/08/11/quiet-period-feature/]. To mitigate the resource consumption of redundant builds, Jenkins enforces a mandatory buffer period to await a state of repository quiescence, thereby coalescing a series of rapid commits into a single build task.

While this strategy is theoretically sound for monolithic, high-cost build pipelines where execution time is significant, it introduces a domain mismatch for lightweight, high-frequency workflows. Hades operates on a micro-task architecture, where execution environments are ephemeral and build durations are minimal. By treating every submission as an immediate trigger, Hades prioritizes feedback granularity and real-time responsiveness over the resource conservation strategies typical of legacy CI/CD designs.

Beyond scheduling, the variation in build times (13.6s vs. 20.6s) illustrates the initialization cost inherent in different execution models. The Jenkins Master-Agent architecture requires maintaining persistent connections, instantiating the JVM, and synchronizing the workspace before pipeline execution can commence. This overhead is amortized effectively in long-duration industrial builds but becomes a dominant factor in short-lived tasks. In contrast, Hades leverages a container-native execution model, interacting directly with the container runtime API to provision isolated environments on demand. By stripping away the middleware layers associated with agent management, Hades reduces initialization overhead, demonstrating that direct container orchestration is the superior approach for workloads that require high throughput and low latency.

=== The Trade-off between Orchestration Overhead and Scalability <resource_saturation>

The transition from a Docker environment to a Kubernetes-based architecture presents a fundamental trade-off between minimizing latency and maximizing throughput. As observed in the baseline benchmarks, the Kubernetes operation modes incur a fixed orchestration overhead, resulting in a build time increase of approximately 2 seconds compared to the HadesCI Docker mode. Unlike Docker mode, which executes via direct socket interactions, the Kubernetes Operator mode relies on the asynchronous reconciliation loop, which involves watching Custom Resource Definitions, updating state, and propagating events via API Server round-trips. However, the stress tests reveal the critical necessity of this overhead. In the standalone Docker scenario, the absence of such a scheduling layer resulted in severe Head-of-line Blocking, causing wait times to scale linearly with the submission volume. Conversely, the Kubernetes operator converts this constant overhead into a capability for horizontal scaling, ensuring that the system can parallelize execution and decouple queue latency from load.

While horizontal scaling provides the mechanism for high throughput, the stress test results highlight the physical limitations imposed by resource oversubscription. A critical finding is the divergence in Build Time stability under different concurrency configurations. In the initial test, where the concurrency limit (10) exceeded the available physical cores (8), the K3s environment experienced a threefold increase in build time (from 16 seconds to 51 seconds). This degradation is a direct consequence of CPU resource saturation and the resulting context switching overhead. With the system in an overcommitted state, the operating system's scheduler is forced to aggressively timeslice limited processor cycles among competing processes, causing individual jobs to languish in a "runnable" but waiting state. This effect leads to cache thrashing and increased kernel overhead, effectively stalling execution.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header(
      [*Metric*],
      [*Over-provisioned Scenario* \ (10 Concurrent / No Limits)],
      [*Resource-Bounded Scenario* \ (6 Concurrent / Limits Applied)]
    ),
    table.hline(stroke: 0.5pt),

    [Baseline (Single Job)], [16.2 s], [29.4 s],
    [Stress Test Average],   [51.0 s], [35.0 s],
    
    table.hline(stroke: 0.5pt),
    
    [Max Build Time],        [68.0 s], [40.0 s],
    [Min Build Time],        [27.0 s], [33.0 s],

    table.hline(stroke: 1.5pt),
  ),
  caption: [Impact of concurrency limits on build time stability in an 8-CPU environment.],
) <tab:resource-optimization>

A follow-up control experiment empirically validates this hypothesis. When we reduce the concurrency limit to 6, which is strictly less than eight cores of the host VM. Furthermore, we explicitly limited CPU and memory usage by specifying the CPULimit to 1 CPU core and the MemoryLimit to 512MB for each container. As @tab:resource-optimization shows, this setup restored the performance stability. Under these resource-bounded conditions, the stress test yielded an average build time of 35 seconds, which is closely aligned with the constrained baseline of 29.4 seconds. The reduction in performance variability confirms that the earlier degradation was introduced by resource contention rather than architectural inefficiency. This demonstrates that for resource-constrained clusters, implementing strict Resource Quotas and ensuring concurrency limits remain below physical core counts are prerequisites for maintaining predictable execution latency.

=== Identifying Performance Bottlenecks in the Hades Operator

The stress tests illustrate the phenomenon of bottleneck migration from software to hardware. While the standalone HadesCI Docker mode was constrained by an architectural limitation in scheduling parallel work, transitioning to Kubernetes removed this software barrier, only to expose the physical limitations of the underlying hardware. As evidenced by the degradation in the over-provisioned K3s cluster, when the concurrency limit exceeds physical core availability, the bottleneck shifts to the CPU scheduler. The resulting context-switching overhead demonstrates that without the strict resource quotas, architectural scalability becomes ineffective due to physical saturation.

Above this physical layer lies the intrinsic architectural overhead of the distributed control plane. The benchmark data consistently demonstrates a fixed latency floor, approximately 2 to 3 seconds, for Kubernetes modes compared to the direct socket interaction of the Docker baseline. This overhead is inherent to the orchestration model, where the API Server, Scheduler, and Kubelet must coordinate asynchronously to launch a Pod. While eliminating this control plane latency is impossible, we can mitigate the implementation by optimizing the operator logic to reduce overhead.

Finally, specific implementation choices within the Hades Operator introduce necessary but measurable delays. First, to prevent the CPU resource saturation identified in @resource_saturation, the operator enforces a strict concurrency limit. Before every admission, the operator iterates through all running jobs, serializing entries to ensure that the number of active builds never exceeds the physical capacity. While this counting process adds latency, it is the primary mechanism that prevents the system from degrading into an over-committed state where build times triple. Second, creating a build requires a chain of separate actions: checking existence, creating the Job, sending logs, and updating the status. The operator performs these sequentially, waiting for the API server to confirm each step before proceeding to the next, rather than executing them in parallel. Third, during high traffic, simultaneous status updates often conflict. To prevent data corruption, the operator implements a retry mechanism that waits and retries failed updates. While these patterns introduce latency, they are deliberate design choices that ensure system stability and data consistency.

== Limitations
// #TODO[
//   Describe limitations and threats to validity of your evaluation, e.g. reliability, generalizability, selection bias, researcher bias
// ]

While this evaluation demonstrates the architectural efficiency of Hades, we acknowledge specific constraints in our experimental design that affect the generalizability and precision of the results.

The primary limitation lies in the homogeneity of the workload versus the variance found in real-world scenarios. Our stress tests utilized a uniform set of identical submission artifacts by repeating the same Maven compilation task 100 times. However, real-world continuous integration environments show high heterogeneity and complexity. A production pipeline typically processes a chaotic mix of tasks ranging from CPU-intensive compilations to I/O-heavy dependency downloads and integration tests. Consequently, the resource contention patterns observed in our benchmarking scenario may differ from those in a mixed-workload environment.

Furthermore, the methodology for recording execution metrics introduces a slight observer effect regarding measurement precision. The system relies on an instrumentation mechanism where Hades must first pull a specific parser image and issue an HTTP callback to the CI-Benchmarker to mark the exact start of build execution. Although this image is lightweight, the latency incurred by the container pull and the network round-trip for the HTTP request is inseparably included in the total reported build time. Therefore, the absolute build durations presented in the benchmarks likely contain a minor variable overhead.

Finally, the experimental scope was confined to a single Kubernetes namespace. This configuration simulates a single-tenant environment, effectively minimizing the control plane overhead associated with multi-tenancy. In a production scenario serving multiple independent teams, the operator should simultaneously reconcile events across numerous isolated namespaces. This pattern would impose a higher load on the Kubernetes API server due to the increased volume of watch events and permission checks. Thus, our results should be interpreted as a baseline for physical scalability within a unified context.
