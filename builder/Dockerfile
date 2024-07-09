FROM gcr.io/kaniko-project/executor AS kaniko
FROM alpine:3.19

ENV DOCKER_CONFIG=/kaniko/.docker
ENV DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json
ENV SSL_CERT_DIR=/kaniko/ssl/certs

COPY --from=kaniko /kaniko /kaniko
COPY ./assets/config.json ${DOCKER_CONFIG}/config.json

RUN apk update && apk add git

ENTRYPOINT ["/bin/sh"]