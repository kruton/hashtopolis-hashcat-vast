FROM nvidia/cuda:12.9.1-devel-ubuntu20.04

# Build arguments for metadata
ARG BUILDTIME
ARG VERSION
ARG REVISION

# Add labels for better metadata
LABEL org.opencontainers.image.title="Hashtopolis Hashcat Vast.ai Client"
LABEL org.opencontainers.image.description="Docker container for deploying hashtopolis agents on vast.ai with hashcat"
LABEL org.opencontainers.image.url="https://github.com/kruton/hashtopolis-hashcat-vast"
LABEL org.opencontainers.image.source="https://github.com/kruton/hashtopolis-hashcat-vast"
LABEL org.opencontainers.image.created="${BUILDTIME}"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${REVISION}"

RUN apt update && apt install -y --no-install-recommends \
  zip \
  git \
  python3 \
  python3-psutil \
  python3-requests \
  pciutils \
  curl && \
  rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /root/htpclient

RUN git clone https://github.com/hashtopolis/agent-python.git && \
  cd agent-python && \
  ./build.sh && \
  mv hashtopolis.zip ../ && \
  cd ../ && rm -R agent-python

# Default command to start the hashtopolis client (can be overridden)
CMD ["python3", "hashtopolis.zip", "--help"]
