###################################
#          MLFLOW: Green          #
###################################

MLFLOW_PREFIX := mlflow
MLFLOW_HOME := mlflow

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${MLFLOW_PREFIX}-%: NAMESPACE := mlflow
${MLFLOW_PREFIX}-%: HELM_RELEASE := mlflow
${MLFLOW_PREFIX}-%: HELM_CHART := bitnami/mlflow
${MLFLOW_PREFIX}-%: HELM_CHART_VERSION := 1.0.5
${MLFLOW_PREFIX}-%: HELM_VALUES := ${MLFLOW_HOME}/values.yaml

${MLFLOW_PREFIX}-%: PATCH_MINIO_REFLECTS := ${MLFLOW_HOME}/patches/minio-reflects.yaml
${MLFLOW_PREFIX}-%: PATCH_VIRTUAL_SERVICE := ${MLFLOW_HOME}/patches/virtual-service.yaml

${MLFLOW_PREFIX}-init:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

# https://artifacthub.io/packages/helm/community-charts/mlflow
${MLFLOW_PREFIX}-up: reflector-up postgresql-up minio-up
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${PATCH_MINIO_REFLECTS} ${OPT_KUBECTL_APPLY}
	kubectl apply -n ${NAMESPACE} -f ${PATCH_VIRTUAL_SERVICE} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, mlflow.geniouslab.io)
	$(MAKE) ${MLFLOW_PREFIX}-account

${MLFLOW_PREFIX}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${MLFLOW_PREFIX}-account:
	@echo "\nMLFlow Tracking Server:\n"
	@echo "\tUsername: $(shell kubectl get -n ${NAMESPACE} secret/mlflow-tracking -o jsonpath="{ .data.admin-user }" | base64 -d)"
	@echo "\tPassword: $(shell kubectl get -n ${NAMESPACE} secret/mlflow-tracking -o jsonpath="{ .data.admin-password }" | base64 -d)"
