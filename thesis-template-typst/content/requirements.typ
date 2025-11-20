#import "/utils/todo.typ": TODO

= Requirements
#TODO[
  This chapter follows the Requirements Analysis Document Template in @bruegge2004object. Important: Make sure that the whole chapter is independent of the chosen technology and development platform. The idea is that you illustrate concepts, taxonomies and relationships of the application domain independent of the solution domain! Cite @bruegge2004object several times in this chapter.

]

== Overview
#TODO[
  Provide a short overview about the purpose, scope, objectives and success criteria of the system that you like to develop.
]

== Existing System
#TODO[
  This section is only required if the proposed system (i.e. the system that you develop in the thesis) should replace an existing system.
]

The current Hades system serves as a lightweight and scalable job-execution system to process build requests. Its architecture follows a loosely coupled microservice pattern and comprises of three primary components: HadesAPI, HadesScheduler, and NATS JetStream as the message-queue layer that interconnects them @jandowHadesCIScalableContinuous. Each component contributes to a specific stage of the build-job processing workflow, covering request validation, priority-based enqueueing, and the execution of the build steps.

HadesAPI functions as the general entry point of the system. It accepts build requests from multiple trigger sources, with Artemis being one of the potential use cases. Additional components such as the CI-Benchmarker this work implements can likewise submit build requests in batches. Upon receiving a request, HadesAPI performs syntactic and semantic validation to ensure that the payload is well-formed and complete. After validation, the API enqueues the request as a build job and assigns it a priority. This priority is explicitly defined by the triggerer in the payload and is used by downstream components to determine the jobs processing order.

To support priority-aware scheduling, HadesAPI publishes each validated job to a priority-specific NATS subject. NATS JetStream serves as the communication backbone between HadesAPI and HadesScheduler by providing a persistent and fault-tolerant queueing layer in which these subjects are maintained. This design ensures that higher-priority jobs—for example those triggered during examination scenarios—are retrieved and processed before lower-priority ones, resulting in predictable and controlled execution behavior across the system.

As a NATS consumer, the Scheduler subscribes to priority-specific subjects through a priority-descending pull model, which ensures that it always retrieves higher priority jobs before lower priority ones. Since the system does not maintain job state outside the queue, the overall design remains stateless apart from the persistence guarantees provided by NATS. After retrieving a job, HadesScheduler does not execute it directly; instead, it delegates execution to one of two build agents, DockerScheduler or K8SScheduler, depending on the configured environment.

In Docker mode, the scheduler launches a sequence of containers, each corresponding to a specific build step such as cloning, compiling, or testing. It communicates directly with the Docker API to create, run, and clean up these containers. This approach minimizes external dependencies, keeps the execution environment lightweight, and simplifies experimentation on local machines or in small scale deployments.

In Kubernetes mode, the scheduler connects to the cluster either by using a kubeconfig file or by relying on in-cluster service account credentials. In kubeconfig mode, the scheduler runs outside the target cluster and authenticates through a locally available configuration file, while in service account mode it runs inside the cluster and obtains its credentials from the mounted service account tokens. Regardless of the authentication method, the scheduler encapsulates the build steps into a Pod that contains multiple containers and communicates with the Kubernetes API to create the Pod, track its lifecycle, and retrieve basic execution output. The current implementation issues these API requests directly and manages Pods at the level of raw Kubernetes objects. It does not use higher-level abstractions such as Jobs or custom resources, and it does not incorporate any workload-distribution mechanisms, which can result in uneven Pod placement across nodes. Log retrieval remains limited to the standard Kubernetes pod logging interface. These characteristics define the current scope of the Kubernetes-based executor and motivate the need for a more Kubernetes-native design.

== Proposed System
#TODO[
  If you leave out the section “Existing system”, you can rename this section into “Requirements”.
]

=== Functional Requirements
#TODO[
  List and describe all functional requirements of your system. Also mention requirements that you were not able to realize. The short title should be in the form “verb objective”

  - FR1 Short Title: Short Description. 
  - FR2 Short Title: Short Description. 
  - FR3 Short Title: Short Description.
]

=== Quality Attributes
#TODO[
  List and describe all quality attributes of your system. All your quality attributes should fall into the URPS categories mentioned in @bruegge2004object. Also mention requirements that you were not able to realize.

  - QA1 Category: Short Description. 
  - QA2 Category: Short Description. 
  - QA3 Category: Short Description.

]

=== Constraints

#TODO[
  List and describe all pseudo requirements of your system. Also mention requirements that you were not able to realize.

  - C1 Category: Short Description. 
  - C2 Category: Short Description. 
  - C3 Category: Short Description.

]

== System Models
#TODO[
  This section includes important system models for the requirements.
]

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
#TODO[
  This subsection should contain a UML Class Diagram showing the most important objects, attributes, methods and relations of your application domain including taxonomies using specification inheritance (see @bruegge2004object). Do not insert objects, attributes or methods of the solution domain. *Important:* Make sure to describe the analysis object model thoroughly in the text so that readers are able to understand the diagram. Also write about the rationale how and why you modeled the concepts like this.

]

=== Dynamic Model
#TODO[
  This subsection should contain dynamic UML diagrams. These can be a UML state diagrams, UML communication diagrams or UML activity diagrams.*Important:* Make sure to describe the diagram and its rationale in the text. *Do not use UML sequence diagrams.*
]

// === User Interface
// #TODO[
//   Show mockups of the user interface of the software you develop and their connections / transitions. You can also create a storyboard. *Important:* Describe the mockups and their rationale in the text.
// ]