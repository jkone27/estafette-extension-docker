FROM google/cloud-sdk:396.0.0-alpine

# update root certificates to copy into runtime image
RUN apk --no-cache add ca-certificates \
    && rm -rf google-cloud-sdk/bin/anthoscli \
    && rm -rf /var/cache/apk/* \
    && which cat

# download trivy
ARG TRIVY_VERSION=0.30.4
RUN wget -O- https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz | \
    tar -xzf - -C / \
    && /trivy --version

# download trivy database
RUN /trivy --cache-dir /trivy-cache image --no-progress --download-db-only

COPY estafette-extension-docker /

ENV PATH="/dod:$PATH;$PATH:/google-cloud-sdk/bin" \
    ESTAFETTE_LOG_FORMAT="console" \
    DOCKER_BUILDKIT="1" \
    BUILDKIT_PROGRESS="plain" \
    GOOGLE_APPLICATION_CREDENTIALS="/key-file.json"

ENTRYPOINT ["/estafette-extension-docker"]
