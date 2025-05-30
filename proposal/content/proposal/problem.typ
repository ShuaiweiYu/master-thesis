= Problem
// #TODO[ // Remove this block
//   *Problem description*
//   - What is/are the problem(s)? 
//   - Identify the actors and use these to describe how the problem negatively influences them.
//   - Do not present solutions or alternatives yet!
//   - Present the negative consequences in detail 
// ]

We identiﬁed four major problems in the current Hades setting this work aims to address.

First, Hades is deployed manually and externally from the Kubernetes cluster. This deployment schema requires system administrators to manually deploy and upgrade the system or recover Hades from failure, which increases the possibility of errors due to human error when deploying. Furthermore, the current Hades setup has no self-recovery mechanisms and thus faces the threat of a single point of failure. In the situation of exams, where many students invoke Hades to trigger build jobs in a short time, which will cause a high load on the Hades gateway, and resulting in higher latency. This will significantly impact the learning experience for students and bring extra maintenance work for the system administrators.

Second, the current Hades Kubernetes implementation is not optimized. Hades has not yet leveraged the benefits of Kubernetes native API objects and has no load-balancing mechanism. This will lead to imbalanced resource allocation and poor performance, impacting the user experience and becoming the bottleneck in the whole system. 

Third, Hades lacks the monitoring and logging support for the Kubernetes Operator. It is difficult to trace the system status without a robust monitoring and logging system. Furthermore, it is also crucial to deliver the build logs to the external trigger system so that the trigger system will understand the results of the build jobs in order to identify the mistakes in case of build failures.

Fourth, no benchmarking framework for Hades is available, making the measurement and analysis of Hades's performance difficult. Without standardized benchmarks, the developer and the administrators will have problems understanding Hades's performance under different circumstances. This hinders the developer from improving Hades's capability under high concurrent situations and complicates efforts to identify bottlenecks.