# Pre-requisite
- kind
- istioctl
- kubectl
- kustomize
- helm
- kubens
- kubectx

# Setup
``` bash
export K8S_PROJECT_DIR=$(pwd)

make <STH>-init
make <STH>-up
make <STH>-down
```