###############################################
#          ARGOCD-IMAGE-UPDATER: Red          #
###############################################

ARGOCD_IMAGE_UPDATER := argocd-image-updater

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${ARGOCD_IMAGE_UPDATER}-%: NAMESPACE := argocd
${ARGOCD_IMAGE_UPDATER}-%: HELM_RELEASE := argocd-image-updater
${ARGOCD_IMAGE_UPDATER}-%: HELM_CHART := argo/argocd-image-updater
${ARGOCD_IMAGE_UPDATER}-%: HELM_CHART_VERSION := 0.9.7
${ARGOCD_IMAGE_UPDATER}-%: HELM_VALUES := ${ARGOCD_IMAGE_UPDATER}/values.yaml

${ARGOCD_IMAGE_UPDATER}-init:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${ARGOCD_IMAGE_UPDATER}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(MAKE) ${ARGOCD_IMAGE_UPDATER}-how-to-create-token-secret
	$(MAKE) ${ARGOCD_IMAGE_UPDATER}-how-to-annotate-app

${ARGOCD_IMAGE_UPDATER}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${ARGOCD_IMAGE_UPDATER}-how-to-create-token-secret:
	@echo "\n[SYSTEM] How to Create Image Updater Token Secret:\n"
	@echo "\t1. kubectl exec -it deployments/argocd-server -- bash"
	@echo "\t2. argocd login localhost:8080 --username admin"
	@echo "\t3. argocd account generate-token --account image-updater --id image-updater --expires-in 0s"
	@echo "\t4. exit"
	@echo "\t5. TOKEN=<GENERATED_TOKEN>"
	@echo "\t6. kubectl create secret generic argocd-image-updater-secret --from-literal argocd.token=$$TOKEN --dry-run -o yaml | kubectl -n argocd apply -f - "

${ARGOCD_IMAGE_UPDATER}-how-to-annotate-app:
	@echo "\n[SYSTEM] How to Annotate ArgoCD App for Image Updater:\n"
	@echo "\t- argocd-image-updater.argoproj.io/image-list: org/app=<REGISTRY_URL>/<REPOSITORY_NAME>"
	@echo "\t- argocd-image-updater.argoproj.io/org_app.update-strategy: latest"
	@echo "\t- argocd-image-updater.argoproj.io/org_app.allow-tags: regexp:^[0-9a-f]{7}$$"
	@echo "\t- argocd-image-updater.argoproj.io/write-back-method: argocd | git"
	@echo "\t- #argocd-image-updater.argoproj.io/org_app.pull-secret: ext:/app/aws/ecr.sh"
