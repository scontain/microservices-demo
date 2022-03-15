#!/bin/bash

set -x

echo "Sconify: shippingservice"

# Build native image.
NATIVE_IMAGE="shippingservice"
docker build . -t "$NATIVE_IMAGE" -f gcc.Dockerfile

# Sconify native image.
TARGET_IMAGE=${TARGET_IMAGE:="shippingservice-sconify"}
SCONIFY_IMAGE=${SCONIFY_IMAGE:="registry.scontain.com:5050/sconecuratedimages/sconecli:sconify-image-scone5.7.0"}
SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-7-0.scone-cas.cf"}
CAS_NAMESPACE=${CAS_NAMESPACE:="online-boutique-$RANDOM$RANDOM"}
K8S_NAMESPACE=${K8S_NAMESPACE:="default"}

SCONE_HEAP="2G"
SCONE_ALLOW_DLOPEN="1"
GO_BINARY="/src/shippingservice"
SESSION_NAME="shippingservice"
CMD="/src/shippingservice"
SERVICE_NAME="shippingservice"

docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.docker/config.json:/root/.docker/config.json \
    -v $PWD/../../release/charts:/charts \
    $SCONIFY_IMAGE \
    sconify_image \
        --from="$NATIVE_IMAGE" \
        --to="$TARGET_IMAGE" \
        --command="$CMD" \
        --service-name="$SERVICE_NAME" \
        --binary="$GO_BINARY" \
        --namespace="$CAS_NAMESPACE" \
        --cli="$SCONIFY_IMAGE" \
        --crosscompiler="$SCONIFY_IMAGE" \
        --cas="$SCONE_CAS_ADDR" \
        --cas-debug \
        --allow-debug-mode \
        --allow-tcb-vulnerabilities \
        --heap="$SCONE_HEAP" \
        --dlopen="$SCONE_ALLOW_DLOPEN" \
        --dir="/src" \
        --host-path="/etc/resolv.conf" \
        --env="DISABLE_TRACING=1" \
        --env="DISABLE_PROFILER=1" \
        --env="DISABLE_DEBUGGER=1" \
        --env="DISABLE_STATS=1" \
        --verbose \
        --no-color \
        --push-image \
        --k8s-helm-workload-type="deployment" \
        --k8s-helm-expose="50051" \
        --k8s-helm-output="/charts" \
        --k8s-helm-set="resources.limits.memory=3G"
