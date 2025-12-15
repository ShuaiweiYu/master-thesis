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
      [*Environment*], [*vCPU*], [*RAM*], [*Deloyment Target*]
    ),
    
    table.hline(stroke: 0.5pt),
    
    [CI-Benchmarker], [4], [4 GB], [Ubuntu 24.04 LTS],
    [Hades Docker], [4], [4 GB], [Ubuntu 24.04 LTS],
    [Jenkins], [4], [4 GB], [Ubuntu 24.04 LTS],
    [K3s Cluster], [8], [16 GB], [Ubuntu 24.04 LTS],
    [Rancher Cluster], [100], [313 GB], [Ubuntu 24.04 LTS],
    
    table.hline(stroke: 1.5pt),
  ),
  caption: [Hardware Configuration of Evaluation Environments],
) <setup>

// todo: put the payload in the appendix
To simulate a realistic Continuous Integration workload typical of student assignments, we defined a standardized Hades payload. This job consists of a four-stage pipeline. The structure is designed not only to perform the build task but also to capture precise timestamps for latency calculation.

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
      
      // 修正点：所有的表头行都在同一个 table.header 中
      table.header(
        // 第一行
        table.cell(rowspan: 2, align: left + horizon)[*Operation Mode*],
        table.cell(colspan: 3)[*Queue Latency (s)*],
        table.cell(colspan: 3)[*Build Time (s)*],
        
        // 表头中间的细线，也要放在这里面
        table.hline(stroke: 0.5pt),
        
        // 第二行
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


== Discussion
#TODO[
  Discuss the findings in more detail and also review possible disadvantages that you found
]

== Limitations
#TODO[
  Describe limitations and threats to validity of your evaluation, e.g. reliability, generalizability, selection bias, researcher bias
]