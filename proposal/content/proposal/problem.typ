= Problem
// #TODO[ // Remove this block
//   *Problem description*
//   - What is/are the problem(s)? 
//   - Identify the actors and use these to describe how the problem negatively influences them.
//   - Do not present solutions or alternatives yet!
//   - Present the negative consequences in detail 
// ]

We identiﬁed four major problems in the current Hades setting this work aims to address.

First, Hades is deployed manually and externally from the Kubernetes cluster. This deployment schema requires system administrators to manually deploy and upgrade the system or recover Hades from failure, which increases error possibilities due to human error when deploying. Furthermore, the current Hades setup has no self-recovery mechanisms and thus faces the threat of a single point of failure. In the situation of exams, where many students invoke Hades to trigger build jobs in a short time, will leave tremendous pressure on Hades and may cause the server to crash. This will significantly impact the learning experience for students and bring extra maintenance work for the system administrators.

Second, the current Hades Kubernetes implementation is not optimized. Hades has not yet leveraged the benefits of Kubernetes native API objects and has no load-balancing mechanism. This will cause the build jobs to be assigned to the same node during execution, leading to imbalanced resource allocation and poor performance. 

Third, Hades lacks the monitoring and logging support. Without a robust monitoring and logging system, it is difficult to trace the system health status, resource allocation, and runtime errors, leading to unintended system downtime. This will cause extra debugging effort for the developer and decrease the reliability of the system.

Fourth, no benchmarking framework for Hades is available, making the measurement and analysis of Hades's performance difficult. Without standardized benchmarks, the developer and the administrators will have problems understanding Hades's performance under different circumstances. This hinders the developer from improving Hades's capability under high concurrent situations and complicates efforts to identify bottlenecks.