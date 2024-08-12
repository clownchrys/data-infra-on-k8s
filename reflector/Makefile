######################################
#          REFLECTOR: Green          #
######################################

# https://artifacthub.io/packages/helm/emberstack/reflector

# Annotations
# [REQUIRED]
# reflector.v1.k8s.emberstack.com/reflection-allowed: "true" 
# [OPTIONAL]
# reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" # 다른 네임스페이스에 자동으로 생성
# reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "namespace-1,namespace-2,namespace-[0-9]*" # 네임스페이스 제한

# Example:
# kubectl annotate -n minio secret/minio \
# reflector.v1.k8s.emberstack.com/reflection-allowed=true \
# reflector.v1.k8s.emberstack.com/reflection-auto-enabled=true \
# reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces=mlflow,default

# Example:
# kubectl annotate -n minio secret/minio reflector.v1.k8s.emberstack.com/reflection-allowed=true
# kubectl create secret generic mirror-secret
# kubectl annotate secrets/mirror-secret reflector.v1.k8s.emberstack.com/reflects=minio/minio

REFLECTOR := reflector

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${REFLECTOR}-%: NAMESPACE := kube-system
${REFLECTOR}-%: HELM_RELEASE := reflector
${REFLECTOR}-%: HELM_CHART := emberstack/reflector
${REFLECTOR}-%: HELM_CHART_VERSION := 7.1.288
${REFLECTOR}-%: HELM_VALUES := ${REFLECTOR}/values.yaml

${REFLECTOR}-init:
	@helm repo add emberstack https://emberstack.github.io/helm-charts
	@helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@touch ${HELM_VALUES}

${REFLECTOR}-up:
	@helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${REFLECTOR}-down:
	@helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
