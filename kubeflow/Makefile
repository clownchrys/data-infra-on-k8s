#####################################
#          KUBEFLOW: Green          #
#####################################

# Ref.
# https://github.com/kubeflow/examples

KUBEFLOW := kubeflow
KUBEFLOW_HOME := kubeflow

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif


${KUBEFLOW}-%: VERSION := v1.8.1
${KUBEFLOW}-%: KUBEFLOW_MANIFEST_DIR := ${KUBEFLOW_HOME}/manifests

${KUBEFLOW}-%: PATCH_INGRESS := ${KUBEFLOW_HOME}/patches/ingress.yaml
${KUBEFLOW}-%: TEMPLATE_CREATE_PROFILE := ${KUBEFLOW_HOME}/templates/create_profile.yaml
${KUBEFLOW}-%: TEMPLATE_JOIN_PROFILE := ${KUBEFLOW_HOME}/templates/join_profile.yaml

${KUBEFLOW}-init:
	git submodule update --init --recursive ${KUBEFLOW_MANIFEST_DIR}
	cd ${KUBEFLOW_MANIFEST_DIR} && git checkout tags/${VERSION}

${KUBEFLOW}-up:
	while ! kustomize build ${KUBEFLOW_HOME}/kustomize | kubectl apply ${OPT_KUBECTL_APPLY} -f -; do echo "Retrying to apply resources"; sleep 10; done	
	$(MAKE) ${KUBEFLOW}-create-profile ACTION=apply PROFILE_NAME=kubeflow-admin-space RAW_OWNER_EMAIL=admin@example.com
	$(MAKE) ${KUBEFLOW}-join-profile ACTION=apply PROFILE_NAME=kubeflow-admin-space RAW_USER_EMAIL=user@example.com SAFE_USER_EMAIL=user-example-com USER_ROLE=view
	$(MAKE) ${KUBEFLOW}-create-profile ACTION=apply PROFILE_NAME=kubeflow-ml-space RAW_OWNER_EMAIL=admin@example.com
	$(MAKE) ${KUBEFLOW}-join-profile ACTION=apply PROFILE_NAME=kubeflow-ml-space RAW_USER_EMAIL=user@example.com SAFE_USER_EMAIL=user-example-com USER_ROLE=edit
	kubectl apply -n istio-system -f ${PATCH_INGRESS} ${OPT_KUBECTL_APPLY}
	$(call print_url, http, kubeflow.geniouslab.io)

${KUBEFLOW}-down:
	while ! kustomize build ${KUBEFLOW_HOME}/kustomize | yq '[.]' | yq '. | reverse | .[] | split_doc' | kubectl delete ${OPT_KUBECTL_DELETE} -f -; do echo "Retrying to delete resources"; sleep 10; done	
	$(MAKE) ${KUBEFLOW}-create-profile ACTION=delete PROFILE_NAME=kubeflow-admin-space RAW_OWNER_EMAIL=admin@example.com
	$(MAKE) ${KUBEFLOW}-join-profile ACTION=delete PROFILE_NAME=kubeflow-admin-space RAW_USER_EMAIL=user@example.com SAFE_USER_EMAIL=user-example-com USER_ROLE=view
	$(MAKE) ${KUBEFLOW}-create-profile ACTION=delete PROFILE_NAME=kubeflow-ml-space RAW_OWNER_EMAIL=admin@example.com
	$(MAKE) ${KUBEFLOW}-join-profile ACTION=delete PROFILE_NAME=kubeflow-ml-space RAW_USER_EMAIL=user@example.com SAFE_USER_EMAIL=user-example-com USER_ROLE=edit
	kubectl delete -n istio-system -f ${PATCH_INGRESS} ${OPT_KUBECTL_DELETE}

# ${KUBEFLOW}-account:
# 	@kubectl get cm/dex -n auth -o yaml | yq '.data."config.yaml"' | yq '.staticPasswords[0].email'
# 	@kubectl get cm/dex -n auth -o yaml | yq '.data."config.yaml"' | yq '.staticPasswords[0].hash'

${KUBEFLOW}-create-profile:
	$(call check_defined, ACTION PROFILE_NAME RAW_OWNER_EMAIL)
	sed \
	-e 's/<PROFILE_NAME>/${PROFILE_NAME}/g' \
	-e 's/<RAW_OWNER_EMAIL>/${RAW_OWNER_EMAIL}/g' \
	${TEMPLATE_CREATE_PROFILE} \
	| kubectl ${ACTION} ${OPT_KUBECTL_$(shell echo ${ACTION} | tr '[:lower:]' '[:upper:]')} -f -

${KUBEFLOW}-join-profile:
	$(call check_defined, ACTION PROFILE_NAME RAW_USER_EMAIL SAFE_USER_EMAIL USER_ROLE)
ifeq ($(shell [ '${ACTION}' = 'apply' ] && echo 1 || echo 0), 1)
	while ! kubectl wait ns ${PROFILE_NAME} --for jsonpath='{.status.phase}=Active'; do echo 'retrying...'; sleep 10; done
endif
	sed \
	-e 's/<PROFILE_NAME>/${PROFILE_NAME}/g' \
	-e 's/<RAW_USER_EMAIL>/${RAW_USER_EMAIL}/g' \
	-e 's/<SAFE_USER_EMAIL>/${SAFE_USER_EMAIL}/g' \
	-e 's/<USER_ROLE>/${USER_ROLE}/g' \
	${TEMPLATE_JOIN_PROFILE} \
	| kubectl ${ACTION} ${OPT_KUBECTL_$(shell echo ${ACTION} | tr '[:lower:]' '[:upper:]')} -f -


############################################
#          Kubeflow Components-Up          #
############################################

# https://github.com/kubeflow/manifests/tree/v1.7.0?tab=readme-ov-file#install-individual-components


${KUBEFLOW}-cert-manager-up:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/cert-manager/cert-manager/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/cert-manager/kubeflow-issuer/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-istio-up:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-crds/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-namespace/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-install/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-dex-up:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/dex/overlays/istio | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-oidc-authservice-up:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/oidc-authservice/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	# kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/oidc-authservice/base | kubectl wait --for 'condition=established' -f -

# Knative is used by the KServe official Kubeflow component.
# error: resource mapping not found for name: "queue-proxy" namespace: "knative-serving" from "STDIN": no matches for kind "Image" in version "caching.internal.knative.dev/v1alpha1"
# ensure CRDs are installed first
${KUBEFLOW}-knative-up:
	# Install Knative Serving:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/knative/knative-serving/overlays/gateways | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/cluster-local-gateway/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-knative-eventing-up:
	# Optionally, you can install Knative Eventing which can be used for inference request logging:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/knative/knative-eventing/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

# Create the namespace where the Kubeflow components will live in. This namespace is named kubeflow.
${KUBEFLOW}-kubeflow-ns-up:
	# Install kubeflow namespace:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/kubeflow-namespace/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

# Create the Kubeflow ClusterRoles, kubeflow-view, kubeflow-edit and kubeflow-admin. Kubeflow components aggregate permissions to these ClusterRoles.
${KUBEFLOW}-kubeflow-roles-up:
	# Install kubeflow roles:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/kubeflow-roles/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

# Create the Istio resources needed by Kubeflow. This kustomization currently creates an Istio Gateway named kubeflow-gateway, in namespace kubeflow. If you want to install with your own Istio, then you need this kustomization as well.
${KUBEFLOW}-kubeflow-istio-resouce-up:
	# Install istio resources:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/kubeflow-istio-resources/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

# This installs argo with the safe-to use runasnonroot emissary executor. Please note that the installer is still responsible to analyze the security issues that arise when containers are run with root access and to decide if the kubeflow pipeline main containers are run as runasnonroot. It is strongly recommended that the pipelines main containers are installed and run as runasnonroot and without any special capabilities to mitigate security risks.
# Multi-User Kubeflow Pipelines dependencies:
# Istio + Kubeflow Istio Resources
# Kubeflow Roles
# This installs argo with the safe-to use runasnonroot emissary executor. Please note that the installer is still responsible to analyze the security issues that arise when containers are run with root access and to decide if the kubeflow pipeline main containers are run as runasnonroot. It is strongly recommended that the pipelines main containers are installed and run as runasnonroot and without any special capabilities to mitigate security risks.
# Multi-User Kubeflow Pipelines dependencies:
# Istio + Kubeflow Istio Resources
# Kubeflow Roles
# OIDC Auth Service (or cloud provider specific auth service)
# Profiles + KFAM
# error: resource mapping not found for name: "kubeflow-pipelines-profile-controller" namespace: "kubeflow" from "STDIN": no matches for kind "CompositeController" in version "metacontroller.k8s.io/v1alpha1"
# ensure CRDs are installed first
${KUBEFLOW}-kubeflow-pipelines-up:
	# Install the Multi-User Kubeflow Pipelines official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | awk '!/well-defined/' | kubectl apply ${OPT_KUBECTL_APPLY} -f -

# KFServing was rebranded to KServe
# resource mapping not found for name: "kserve-lgbserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-mlserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-paddleserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-pmmlserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-sklearnserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-tensorflow-serving" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-torchserve" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-tritonserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
# resource mapping not found for name: "kserve-xgbserver" namespace: "" from "STDIN": no matches for kind "ClusterServingRuntime" in version "serving.kserve.io/v1alpha1"
# ensure CRDs are installed first
${KUBEFLOW}-kserve-up:
	# Install the KServe component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/contrib/kserve/kserve | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	# Install the Models web app:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/contrib/kserve/models-web-app/overlays/kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-katib-up:
	# Install the Katib official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-central-dashboard-up:
	# Install the Central Dashboard official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/centraldashboard/upstream/overlays/kserve | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-admission-webhook-up:
	# Install the Admission Webhook for PodDefaults:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-notebooks-up:
	# Install the Notebook Controller official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	# Install the Jupyter Web App official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-profiles-kfam-up:
	# Install the Profile Controller and the Kubeflow Access-Management (KFAM) official Kubeflow components:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/profiles/upstream/overlays/kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-volumes-web-app-up:
	# Install the Volumes Web App official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/volumes-web-app/upstream/overlays/istio | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-tensorboard-up:
	# Install the Tensorboards Web App official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply ${OPT_KUBECTL_APPLY} -f -
	# Install the Tensorboard Controller official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-training-operator-up:
	# Install the Training Operator official Kubeflow component:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/training-operator/upstream/overlays/kubeflow | kubectl apply ${OPT_KUBECTL_APPLY} -f -

${KUBEFLOW}-user-ns-up:
	# Finally, create a new namespace for the the default user (named kubeflow-user-example-com).
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/user-namespace/base | kubectl apply ${OPT_KUBECTL_APPLY} -f -

##############################################
#          Kubeflow Components-Down          #
##############################################

${KUBEFLOW}-cert-manager-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/cert-manager/cert-manager/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/cert-manager/kubeflow-issuer/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-istio-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-crds/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-namespace/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/istio-install/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-dex-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/dex/overlays/istio | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-oidc-authservice-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/oidc-authservice/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-knative-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/knative/knative-serving/overlays/gateways | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/cluster-local-gateway/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-knative-eventing-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/knative/knative-eventing/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-kubeflow-ns-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/kubeflow-namespace/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-kubeflow-roles-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/kubeflow-roles/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-kubeflow-istio-resouce-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/istio-1-16/kubeflow-istio-resources/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-kubeflow-pipelines-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | awk '!/well-defined/' | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-kserve-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/contrib/kserve/kserve | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/contrib/kserve/models-web-app/overlays/kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-katib-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/katib/upstream/installs/katib-with-kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-central-dashboard-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/centraldashboard/upstream/overlays/kserve | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-admission-webhook-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/admission-webhook/upstream/overlays/cert-manager | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-notebooks-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-profiles-kfam-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/profiles/upstream/overlays/kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-volumes-web-app-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/volumes-web-app/upstream/overlays/istio | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-tensorboard-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-training-operator-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/apps/training-operator/upstream/overlays/kubeflow | kubectl delete ${OPT_KUBECTL_DELETE} -f -

${KUBEFLOW}-user-ns-down:
	kustomize build ${KUBEFLOW_MANIFEST_DIR}/common/user-namespace/base | kubectl delete ${OPT_KUBECTL_DELETE} -f -
