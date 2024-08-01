#######################################
#          POSTGRESQL: Green          #
#######################################

POSTGRESQL := postgresql

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${POSTGRESQL}-%: NAMESPACE := postgresql
${POSTGRESQL}-%: HELM_RELEASE := postgresql
${POSTGRESQL}-%: HELM_CHART := bitnami/postgresql
${POSTGRESQL}-%: HELM_CHART_VERSION := 15.3.1
${POSTGRESQL}-%: HELM_VALUES := ${POSTGRESQL}/values.yaml

${POSTGRESQL}-%: PATCH_INITDB := ${POSTGRESQL}/patches/postgresql-initdb.yaml

${POSTGRESQL}-init:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${POSTGRESQL}-up:
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${PATCH_INITDB} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${POSTGRESQL}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_INITDB} ${OPT_KUBECTL_DELETE}
	# kubectl delete -n ${NAMESPACE} $$(kubectl get pvc -n ${NAMESPACE} -o name) ${OPT_KUBECTL_DELETE}
