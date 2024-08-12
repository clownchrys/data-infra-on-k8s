##################################
#          ARGO-CD: Red          #
##################################

ARGOCD := argocd

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

# ArgoCD Webhhook:
# https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/

${ARGOCD}-%: NAMESPACE := argocd
${ARGOCD}-%: HELM_RELEASE := argocd
${ARGOCD}-%: HELM_CHART := argo/argo-cd
${ARGOCD}-%: HELM_CHART_VERSION := 6.7.14
${ARGOCD}-%: HELM_VALUES := ${ARGOCD}/values.yaml

${ARGOCD}-init:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${ARGOCD}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, argocd.geniouslab.io)
	$(MAKE) ${ARGOCD}-account

${ARGOCD}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${ARGOCD}-account:
	@echo "\n[SYSTEM] ArgoCD Account:\n"
	@echo "\tusername: admin"
	@echo "\tpassword: $(shell kubectl get secret -n ${NAMESPACE} argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d ; echo)"
