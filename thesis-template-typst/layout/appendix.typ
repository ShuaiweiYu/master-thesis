-- Supplementary Material --

#heading(
  level: 3, 
  numbering: none
)[Build Script for CI-Benchmarker] <build_script>
```json
  {
    "name": "Example Job",
    "metadata": {
      "GLOBAL": "test"
    },
    "timestamp": "2021-01-01T00:00:00.000Z",
    "priority": 3, // optional, default 3
    "steps": [
      {
        "id": 1,
        "name": "Report Starting Time",
        "image": "ghcr.io/ls1intum/hades-reporter/hades-reporter:latest",
        "metadata": {
          "ENDPOINT": "{{start_time_url}}"
        }
      },
      {
        "id": 2, // mandatory to declare the order of execution
        "name": "Clone",
        "image": "ghcr.io/ls1intum/hades/hades-clone-container:latest", // mandatory
        "metadata": {
          "REPOSITORY_DIR": "/shared",
          "HADES_TEST_USERNAME": "{{user}}",
          "HADES_TEST_PASSWORD": "{{password}}",
          "HADES_TEST_URL": "{{test_repo}}",
          "HADES_TEST_PATH": "./example",
          "HADES_TEST_ORDER": "1",
          "HADES_ASSIGNMENT_USERNAME": "{{user}}",
          "HADES_ASSIGNMENT_PASSWORD": "{{password}}",
          "HADES_ASSIGNMENT_URL": "{{assignment_repo}}",
          "HADES_ASSIGNMENT_PATH": "./example/assignment",
          "HADES_ASSIGNMENT_ORDER": "2"
        }
      },
      {
        "id": 3, // mandatory to declare the order of execution
        "name": "Execute",
        "image": "ls1tum/artemis-maven-template:java17-18", // mandatory
        "script": "set -e && cd /shared/example && ./gradlew --status && ./gradlew clean test"
      },
      {
        "id": 4,
        "name": "Result",
        "image": "ghcr.io/ls1intum/hades/junit-result-parser:latest",
        "metadata": {
          "API_ENDPOINT": "{{end_time_url}}",
          "INGEST_DIR":"./shared/example",
          "HADES_TEST_PATH": "./example",
          "HADES_ASSIGNMENT_PATH": "./example/assignment"
        }
      }
    ]
  }
  ```


#heading(
  level: 3, 
  numbering: none
)[`BuildJob` CRD for Hades Operator Pattern] <crd>
```yaml
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.18.0
  name: buildjobs.build.hades.tum.de
spec:
  group: build.hades.tum.de
  names:
    kind: BuildJob
    listKind: BuildJobList
    plural: buildjobs
    singular: buildjob
  scope: Namespaced
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: |-
          BuildJob is the Schema for the buildjobs API in Hades operator mode.
          A BuildJob represents a multi-step CI/CD pipeline execution, where each step runs in a container.
          Steps execute sequentially in order of their ID, with shared data passed between steps via volumes.
        properties:
          apiVersion:
            description: |-
              APIVersion defines the versioned schema of this representation of an object.
              Servers should convert recognized schemas to the latest internal value, and
              may reject unrecognized values.
              More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
            type: string
          kind:
            description: |-
              Kind is a string value representing the REST resource this object represents.
              Servers may infer this from the endpoint the client submits requests to.
              Cannot be updated.
              In CamelCase.
              More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
            type: string
          metadata:
            type: object
          spec:
            properties:
              maxRetries:
                description: |-
                  Maximum number of times to retry the entire BuildJob if it fails.
                  In CI/CD scenarios, a failure typically indicates the code didn't pass tests,
                  so retrying is usually not beneficial.
                format: int32
                minimum: 0
                type: integer
              metadata:
                additionalProperties:
                  type: string
                description: |-
                  Global key-value pairs available to all steps as environment variables.
                  Use this for configuration shared across all steps, such as repository URLs,
                  Example: {"GLOBAL": "test", "ENVIRONMENT": "production"}
                type: object
              name:
                description: |-
                  Human-readable name describing this BuildJob's purpose.
                  Example: "Build and Test Assignment", "Deploy Application"
                type: string
              steps:
                description: |-
                  Ordered list of execution steps that make up this BuildJob pipeline.
                  Steps run sequentially according to their ID (1, 2, 3, ...).
                  Each step runs in its own container and can share data with other steps via mounted volumes.
                  Typical pipeline: Step 1 clones code, Step 2 builds it, Step 3 runs tests.
                items:
                  properties:
                    cpuLimit:
                      anyOf:
                      - type: integer
                      - type: string
                      description: |-
                        Maximum CPU resources this step's container can use.
                        Follows Kubernetes resource quantity format (e.g., "500m" = 0.5 CPU cores, "2" = 2 cores).
                        Prevents a single step from monopolizing cluster resources.
                        If not specified, uses cluster defaults.
                      pattern: ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      x-kubernetes-int-or-string: true
                    cpuRequest:
                      anyOf:
                      - type: integer
                      - type: string
                      description: |-
                        Minimum CPU and memory resources required for this step's container.
                        Follows Kubernetes resource quantity format (e.g., "500m" = 0.5 CPU cores, "2" = 2 cores).
                        Ensures the step has sufficient resources to run without being throttled.
                        If not specified, uses the value of cpuLimit.
                      pattern: ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      x-kubernetes-int-or-string: true
                    id:
                      description: |-
                        Unique numeric identifier determining execution order. Must start at 1 and increment by 1.
                        Steps execute in ascending ID order: step with id=1 runs first, then id=2, etc.
                        This is mandatory and must be unique within the BuildJob.
                      format: int32
                      minimum: 1
                      type: integer
                    image:
                      description: |-
                        Container image to run for this step. Must be a valid Docker image reference.
                        Can be from any registry (Docker Hub, GHCR, private registry).
                      minLength: 1
                      type: string
                    memoryLimit:
                      anyOf:
                      - type: integer
                      - type: string
                      description: |-
                        Maximum memory this step's container can use.
                        Follows Kubernetes resource quantity format (e.g., "512Mi", "2Gi", "1G").
                        Prevents out-of-memory issues and resource exhaustion.
                        If not specified, uses cluster defaults.
                      pattern: ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      x-kubernetes-int-or-string: true
                    memoryRequest:
                      anyOf:
                      - type: integer
                      - type: string
                      description: |-
                        Minimum memory required for this step's container.
                        Follows Kubernetes resource quantity format (e.g., "512Mi", "2Gi", "1G").
                        Ensures the step has minimum memory to avoid out-of-memory errors.
                        If not specified, uses the value of memoryLimit.
                      pattern: ^(\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))(([KMGTPE]i)|[numkMGTPE]|([eE](\+|-)?(([0-9]+(\.[0-9]*)?)|(\.[0-9]+))))?$
                      x-kubernetes-int-or-string: true
                    metadata:
                      additionalProperties:
                        type: string
                      description: |-
                        Step-specific key-value pairs injected as environment variables into this step's container.
                        Use for step-specific configuration like repository URLs, file paths, or credentials.
                        Variables can reference placeholders (e.g., "{{user}}") that get substituted at runtime.
                        Examples:
                        - "REPOSITORY_DIR": "/shared" (where to clone code)
                        - "HADES_TEST_URL": "{{test_repo}}" (test repository URL)
                        - "WORKDIR": "/app/build" (working directory path)
                      type: object
                    name:
                      description: |-
                        Descriptive name for this step, shown in logs and UI.
                        Should clearly indicate what the step does.
                        Examples: "Clone Repository", "Run Tests", "Build Docker Image"
                      type: string
                    script:
                      description: |-
                        Optional bash script to execute inside the container.
                        If provided, this overrides the container image's default entrypoint/command.
                        The script runs with /bin/sh -c, so you can use shell features like &&, ||, pipes, etc.
                        Common use: chaining commands like "cd /workspace && npm install && npm test"
                        Example: "set -e && cd /shared/example && ./gradlew clean test"
                      type: string
                  required:
                  - id
                  - image
                  type: object
                minItems: 1
                type: array
              timeoutSeconds:
                description: |-
                  Maximum time (in seconds) allowed for the entire BuildJob to complete.
                  If this timeout is exceeded, the BuildJob is immediately terminated and marked as Failed.
                  Useful for preventing stuck jobs from consuming resources indefinitely.
                  Example: 3600 = 1 hour, 600 = 10 minutes.
                format: int64
                minimum: 1
                type: integer
            required:
            - name
            - steps
            type: object
          status:
            properties:
              completionTime:
                description: |-
                  Timestamp when the BuildJob finished execution (either successfully or with failure).
                  Empty if the job is still running or pending.
                format: date-time
                type: string
              containerStatuses:
                items:
                  description: ContainerStatus tracks the runtime state of a single
                    container
                  properties:
                    logsPublished:
                      description: LogsPublished indicates whether logs have been
                        read and published to NATS
                      type: boolean
                    name:
                      description: Name of the container (e.g., "step-0", "step-1",
                        "buildjob-finalizer")
                      type: string
                    state:
                      description: State of the container
                      enum:
                      - Pending
                      - Running
                      - Succeeded
                      - Failed
                      - Unknown
                      type: string
                    stepId:
                      description: StepID links back to BuildStep.ID (0 for finalizer
                        container)
                      format: int32
                      type: integer
                  required:
                  - name
                  - state
                  - stepId
                  type: object
                type: array
              currentStep:
                description: |-
                  ID of the step currently being executed.
                  For example, if currentStep=2, the operator is running the step with id=2.
                  This helps track progress through the pipeline.
                format: int32
                type: integer
              message:
                type: string
              phase:
                description: |-
                  Current lifecycle phase of the BuildJob:
                  - Pending: Job created but not yet started (waiting for resources or scheduling)
                  - Running: At least one step is currently executing
                  - Succeeded: All steps completed successfully
                  - Failed: At least one step failed, or the job timed out
                enum:
                - Pending
                - Running
                - Succeeded
                - Failed
                type: string
              podName:
                description: Name of the Kubernetes Pod created by the operator to
                  execute this BuildJob.
                type: string
              retryCount:
                description: |-
                  Number of times this BuildJob has been retried after failures.
                  Increments each time the operator restarts the job due to failure.
                  When retryCount reaches maxRetries, no further attempts are made.
                format: int32
                type: integer
              startTime:
                description: Timestamp when the BuildJob starts execution
                format: date-time
                type: string
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
    ```