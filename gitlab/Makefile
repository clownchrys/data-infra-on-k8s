###################################
#          GITLAB: Green          #
###################################

GITLAB := gitlab

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

# TODO: HOST due to SSL Cert
# https://docs.gitlab.com/charts/advanced/internal-tls/index.html
# https://velog.io/@wkfwktka/k8s-gitlab%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-%EC%9C%84%EC%97%90%EC%84%9C-gitlab-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0

${GITLAB}-%: NAMESPACE := gitlab
${GITLAB}-%: HELM_RELEASE := gitlab
${GITLAB}-%: HELM_CHART := gitlab/gitlab
${GITLAB}-%: HELM_CHART_VERSION := 7.11.0
${GITLAB}-%: HELM_VALUES := ${GITLAB}/values.yaml

${GITLAB}-init:
	helm repo add gitlab https://charts.gitlab.io/
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${GITLAB}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, gitlab.geniouslab.io)
	$(MAKE) ${GITLAB}-account

${GITLAB}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${GITLAB}-account:
	@echo "\n[SYSTEM] GitLab Accout:\n"
	@echo "\tusername: root"
	@echo "\tpassword: $(shell kubectl get secret -n ${NAMESPACE} gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d ; echo)"

