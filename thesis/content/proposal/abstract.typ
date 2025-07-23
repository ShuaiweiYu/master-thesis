= Abstract

Continuous Integration and Continuous Deployment automate key stages of modern software engineering. Hades is a scalable build execution system for programming exercise environments, such as Artemis. While Hades uses Kubernetes to manage build jobs, it is deployed outside the Kubernetes cluster. This implementation limits Hades's scalability and observability, increasing manual maintenance efforts.

This project migrates Hades into the Kubernetes cluster and introduces a custom operator along with a Helm chart to simplify deployment and upgrades. This work enhances the current logging system within the cluster to improve observability and implements a benchmarking suite to evaluate performance under varying conditions and identify optimization opportunities.