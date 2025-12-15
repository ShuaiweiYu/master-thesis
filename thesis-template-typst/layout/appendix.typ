-- Supplementary Material --

```
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