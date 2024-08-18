####################################
#          AIRFLOW: Green          #
####################################

AIRFLOW_PREFIX := airflow
AIRFLOW_HOME := airflow

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${AIRFLOW_PREFIX}-%: NAMESPACE := airflow
${AIRFLOW_PREFIX}-%: HELM_RELEASE := airflow
${AIRFLOW_PREFIX}-%: HELM_CHART := apache-airflow/airflow
${AIRFLOW_PREFIX}-%: HELM_CHART_VERSION := 1.13.1
${AIRFLOW_PREFIX}-%: HELM_VALUES := ${AIRFLOW_HOME}/values.yaml

${AIRFLOW_PREFIX}-%: PATCH_PVC := ${AIRFLOW_HOME}/patches/pvc.yaml

${AIRFLOW_PREFIX}-init:
	helm repo add apache-airflow https://airflow.apache.org
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${AIRFLOW_PREFIX}-up:
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${PATCH_PVC} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, airflow.geniouslab.io)
	$(MAKE) ${AIRFLOW_PREFIX}-account

${AIRFLOW_PREFIX}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_PVC} ${OPT_KUBECTL_DELETE}

${AIRFLOW_PREFIX}-account:
	@echo "\n[SYSTEM] Airflow Accout:\n"
	@echo "\tUSERNAME: $$(cat airflow/values.yaml | yq '.webserver.defaultUser.username')"
	@echo "\tPASSWORD: $$(cat airflow/values.yaml | yq '.webserver.defaultUser.password')"