####################################
#          ELASTIC: Green          #
####################################

ELASTIC := elastic
ELASTIC_HOME := elastic

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

include ${ELASTIC}/apps/elasticsearch/Makefile
include ${ELASTIC}/apps/fluent-bit/Makefile
include ${ELASTIC}/apps/kibana/Makefile

${ELASTICSEARCH}-% \
${FLUENT_BIT}-% \
${KIBANA}-% \
${ELASTIC}-%: NAMESPACE := elastic

${ELASTIC}-%: PATCH_CERTIFICATE := ${ELASTIC_HOME}/patches/elastic-cert.yaml

${ELASTIC}-init:
	sed -e 's/<NAMESPACE>/${NAMESPACE}/g' cert-manager/templates/namespace.cert.yaml > ${PATCH_CERTIFICATE}

${ELASTIC}-up:
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${PATCH_CERTIFICATE} ${OPT_KUBECTL_APPLY}