###################################
#          HARBOR: Green          #
###################################

HARBOR := harbor

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${HARBOR}-%: NAMESPACE := harbor
${HARBOR}-%: HELM_RELEASE := harbor
${HARBOR}-%: HELM_CHART := harbor/harbor
${HARBOR}-%: HELM_CHART_VERSION := 1.14.2
${HARBOR}-%: HELM_VALUES := ${HARBOR}/values.yaml

${HARBOR}-init:
	helm repo add harbor https://helm.goharbor.io
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}
	docker login https://harbor.geniouslab.io --username admin

${HARBOR}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, harbor.geniouslab.io)
	$(MAKE) ${HARBOR}-account

${HARBOR}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${HARBOR}-account:
	@echo Username: admin
	@echo Password: $(shell kubectl get -n ${NAMESPACE} secrets/harbor-core -o yaml | yq '.data.HARBOR_ADMIN_PASSWORD' | base64 -d)

# : %3A
# / %2F
# library/hello-world
# 2024-05-24T23:30:39.892978993Z stdout F 10.0.1.164 - admin [24/May/2024:23:30:39 +0000] "GET /service/token?account=admin&scope=repository%3Alibrary%2Fhello-world%3Apush%2Cpull&service=harbor-registry HTTP/1.1" 200 710 "-" "docker/23.0.5 go/go1.19.8 git-commit/94d3ad6 kernel/5.15.49-linuxkit os/linux arch/amd64 UpstreamClient(Docker-Client/25.0.4-rd \x5C(darwin\x5C))" 401 0.013 [harbor-harbor-core-80] [] 10.0.0.36:8080 710 0.013 200 a950772cb0f1c14e722b9c944491e481
# hello-world
# 2024-05-24T23:44:19.818137930Z stdout F 10.0.1.164 - admin [24/May/2024:23:44:19 +0000] "GET /service/token?account=admin&scope=repository%3Ahello-world%3Apush%2Cpull&service=harbor-registry HTTP/1.1" 200 683 "-" "docker/23.0.5 go/go1.19.8 git-commit/94d3ad6 kernel/5.15.49-linuxkit os/linux arch/amd64 UpstreamClient(Docker-Client/25.0.4-rd \x5C(darwin\x5C))" 391 0.013 [harbor-harbor-core-80] [] 10.0.0.36:8080 683 0.014 200 0f2bf5860f495d6fd1de4b7b066f1b41
${HARBOR}-test:
	docker pull hello-world
	docker tag hello-world:latest harbor.geniouslab.io/library/hello-world:latest
	docker login harbor.geniouslab.io --username admin --password admin
	docker push harbor.geniouslab.io/library/hello-world
	docker push harbor.geniouslab.io/hello-world
