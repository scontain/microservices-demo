set -e

# Images.
export SCONIFY_IMAGE="${SCONIFY_IMAGE:="registry.scontain.com:5050/sconecuratedimages/sconecli:sconify-image-scone5.7.0"}"
docker pull $SCONIFY_IMAGE &>/dev/null || echo "[ERROR] Failed to pull ""$SCONIFY_IMAGE"". Please make sure you have access."

# Common variables.
export IMAGE_REPOSITORY="$IMAGE_REPOSITORY"
[[ -n "$IMAGE_REPOSITORY" ]] || {
    echo "[ERROR] Please export IMAGE_REPOSITORY with a valid container repository to which you can push images."
    exit 1
}
export SCONE_CAS_ADDR=${SCONE_CAS_ADDR:="5-7-0.scone-cas.cf"}
export CAS_MRENCLAVE=${CAS_MRENCLAVE:="3061b9feb7fa67f3815336a085f629a13f04b0a1667c93b14ff35581dc8271e4"}
export CAS_NAMESPACE="online-boutique-$RANDOM$RANDOM"

# Deployment variables.
export K8S_NAMESPACE="${K8S_NAMESPACE:="default"}"

# Create namespace.
docker run -it --rm \
    -v $PWD/policies:/policies \
    -e SCONE_CAS_ADDR=$SCONE_CAS_ADDR \
    -e CAS_NAMESPACE=$CAS_NAMESPACE \
    -e CAS_MRENCLAVE=$CAS_MRENCLAVE \
    ${SCONIFY_IMAGE} \
    bash -c "/policies/upload_policies.sh"

# Update Helm chart for cartservice and redis-cart with updated Config ID.
sed -i 's/online-boutique-[0-9]\+/'"$CAS_NAMESPACE"'/g' release/charts/cartservice/values.yaml
sed -i 's/online-boutique-[0-9]\+/'"$CAS_NAMESPACE"'/g' release/charts/redis-cart/values.yaml

# Sconify services.
for service in adservice cartservice checkoutservice currencyservice emailservice frontend paymentservice productcatalogservice recommendationservice shippingservice ; do
        pushd "./src/""$service"
        TARGET_IMAGE="$IMAGE_REPOSITORY"":""$service""$CAS_NAMESPACE" ./sconify.sh
        popd
done

