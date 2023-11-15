#!/bin/bash

set -e  # Stop in case of errors

REGISTRY=excalifork

help() {
    echo "Build and push ExcaliDraw custom images."
    echo
    echo "Syntax: build_excalifork.sh [OPTIONS]"
    echo "Options:"
    echo "  --storage         Specify FQDN of backend storage. Default is 127.0.0.1:8081."
    echo "  --room            Specify FQDN of ExcaliDraw room. Default is 127.0.0.1:8082."
    echo "  -r, --registry    Specify registry where to push images. Placeholder value: excalifork."
    echo "  -d, --dev         Add -dev tag suffix to Docker images."
    echo "  -dr, --dry-run    Perform a dry run without making changes."
    echo "  -h, --help        Print this help message."
    echo
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --storage) STORAGE="$2"; shift 2 ;;
    --room) ROOM="$2"; shift 2 ;;
    --registry|-r) REGISTRY="$2"; shift 2 ;;
    --dev|-d) DEV=true; shift ;;
    -dr|--dry-run) DRY_RUN=true; shift ;;
    -h|--help) help; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done


STORAGE=${STORAGE:-127.0.0.1:8081}
ROOM=${ROOM:-127.0.0.1:8082}
EXCALIDRAW_UPSTREAM_VERSION=$(cat EXCALIDRAW_UPSTREAM_VERSION)
DRY_RUN=${DRY_RUN:-false}
DEV=${DEV:-false}
TAG_SUFFIX=""

rm -rf build
mkdir -p build

if [ "$DEV" = true ]
then
    TAG_SUFFIX="-dev"
fi

echo -e "Building ExcaliDraw images...\n"
echo "EXCALIDRAW_UPSTREAM_VERSION: ${EXCALIDRAW_UPSTREAM_VERSION}"
echo "EXCALIDRAW_STORAGE: $STORAGE"
echo "EXCALIDRAW_ROOM: $ROOM"

echo -e "\nImage name and tag will be ${REGISTRY}/excalifork:${EXCALIDRAW_UPSTREAM_VERSION}${TAG_SUFFIX}"
echo -e "Image name and tag will be ${REGISTRY}/excalifork-room:latest${TAG_SUFFIX}"
echo -e "Image name and tag will be ${REGISTRY}/excalifork-storage-backend:latest${TAG_SUFFIX}\n"

echo -e "\nCloning necessary repository..."
git clone https://github.com/excalidraw/excalidraw.git --branch ${EXCALIDRAW_UPSTREAM_VERSION} build/excalifork

export STORAGE_BACKEND=$STORAGE
export EXCALIDRAW_ROOM=$ROOM

envsubst < excalidraw.env.tmpl > build/excalifork/.env.production
cp excalidraw.dockerignore build/excalifork/.dockerignore
cp *.patch build/excalifork
cd build/excalifork
git am *.patch
cd ../..

git clone https://github.com/alswl/excalidraw-storage-backend.git --branch fork build/excalifork-storage-backend
git clone https://github.com/excalidraw/excalidraw-room.git build/excalifork-room

if [ "$DRY_RUN" = true ]
then
    echo -e "\nThis was a dry run..."
    exit 0
fi

IMAGES=("excalifork:${EXCALIDRAW_UPSTREAM_VERSION}" "excalifork-room:latest" "excalifork-storage-backend:latest")

build_image() {
  local image_with_tag="$1"
  local image_name="${image_with_tag%%:*}" # Extract the image name before ":"
  local image_tag="${image_with_tag##*:}"  # Extract the image tag after ":"
  echo "Building Docker image: ${REGISTRY}/${image_name}:${image_tag}"
  docker build \
    -t "${REGISTRY}/${image_name}:${image_tag}${TAG_SUFFIX}" \
    --progress=plain \
    -f "build/${image_name}/Dockerfile" "build/${image_name}"
}

# Build the Docker images
for image in "${IMAGES[@]}"; do
  build_image "$image"
done
