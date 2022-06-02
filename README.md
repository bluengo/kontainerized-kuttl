# Kontainerized-Kuttl 
This repo holds the container image and files to run kuttl tests against a remote OpenShift cluster.

---
### How to use it
The intention of this image is to be used within tekton pipelines to easily parallelize tests in multiple clusters and speed up E2E testing, but it can be used with Podman in a standalone way:

**1. Build the image**:
```bash
$ make podman-build
```
>   <font size="2">(by default it will set `quay.io/<your_username>/kontainerized-kuttl:latest` as the tag for the image. You can override that value by setting up the `$IMAGE` env var).</font>

**2. Run it**:
```bash
$ podman run -e OCP_SERVER=<ocp_api_url> -e OCP_PASS=<user_password> quay.io/<your_user>/kontainerized-kuttl
```

---
### Variables
Below you will find the variables reference:
| **Variable** | **Description**                                                | **Required** | **Default**                                             |
|--------------|----------------------------------------------------------------|--------------|---------------------------------------------------------|
| `OCP_SERVER` | OpenShift API server URL to login                              | **Yes**      | *N/A*                                                   |
| `OCP_PASS`   | OpenShift password for `$OCP_USER`                             | **Yes**      | *N/A*                                                   |
| `OCP_USER`   | OpenShift user to login                                        | No           | `kubeadmin`                                             |
| `KUTTL_REPO` | Git repository holding the kuttl tests to run                  | No           | `https://gitlab.cee.redhat.com/gitops/operator-e2e.git` |
| `REPO_DIR`   | Name of the local folder in which to clone the Kuttl test repo | No           | `operator-e2e`                                          |