##################################
#          FEAST: Green          #
##################################

FEAST := feast

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${FEAST}-%: NAMESPACE := feast
${FEAST}-%: HELM_RELEASE := feast
${FEAST}-%: HELM_CHART := ${FEAST}/feast-0.37.1.tgz
${FEAST}-%: HELM_VALUES := ${FEAST}/values.yaml

${FEAST}-init:
	helm repo add feast-charts https://feast-helm-charts.storage.googleapis.com

${FEAST}-up:
	#$(call create_ns, ${NAMESPACE})
	#kubectl create -n ${NAMESPACE} secret generic feast-postresql --from-literal=postgresql-password=pass
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} -f ${HELM_VALUES} --set global.feature_store_yaml_base64=$(base64 feast/feature_store.yaml) ${OPT_HELM_INSTALL}

${FEAST}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${FEAST}-tmp:
	helm upgrade --install feast-release feast/feast-feature-server-impl \
    --set feature_store_yaml_base64=$(shell base64 feast/feature_store.yaml) \
	--set aws.access_key_id=$(shell kubectl get -n mlflow secret/mlflow-minio -o jsonpath="{ .data.root-user }" | base64 -d) \
	--set aws.secret_access_key=$(shell kubectl get -n mlflow secret/mlflow-minio -o jsonpath="{ .data.root-password }" | base64 -d) \
	--set aws.endpoint_url=http://mlflow-minio.mlflow.svc.cluster.local \
	-n feast-tmp --create-namespace