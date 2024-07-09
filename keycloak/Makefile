#####################################
#          KEYCLOAK: Green          #
#####################################

KEYCLOAK := keycloak

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${KEYCLOAK}-%: NAMESPACE := keycloak
${KEYCLOAK}-%: HELM_RELEASE := keycloak
${KEYCLOAK}-%: HELM_CHART := bitnami/keycloak
${KEYCLOAK}-%: HELM_CHART_VERSION := 21.3.1
${KEYCLOAK}-%: HELM_VALUES := ${KEYCLOAK}/values.yaml
${KEYCLOAK}-%: PATCH_INIT_SCRIPT := ${KEYCLOAK}/patches/keycloak-init-script.yaml
${KEYCLOAK}-%: PATCH_CERTIFICATE := ${KEYCLOAK}/patches/keycloak-cert.yaml

${KEYCLOAK}-init:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}
	sed -e 's/<NAMESPACE>/${NAMESPACE}/g' cert-manager/templates/namespace.cert.yaml > ${PATCH_CERTIFICATE}

${KEYCLOAK}-up: cert-manager-up postgresql-up
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${PATCH_INIT_SCRIPT} ${OPT_KUBECTL_APPLY}
	kubectl apply -n ${NAMESPACE} -f ${PATCH_CERTIFICATE} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, ${HELM_RELEASE}.${NAMESPACE}.svc.cluster.local)
	$(call print_url, https, keycloak.geniouslab.io)
	$(MAKE) ${KEYCLOAK}-account

${KEYCLOAK}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_CERTIFICATE} ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_INIT_SCRIPT} ${OPT_KUBECTL_DELETE}

${KEYCLOAK}-account:
	@echo Username: $(shell kubectl get -n ${NAMESPACE} cm/keycloak-env-vars -o yaml | yq '.data.KEYCLOAK_ADMIN')
	@echo Password: $(shell kubectl get -n ${NAMESPACE} secret/keycloak  -o yaml | yq '.data.admin-password' | base64 -d)
