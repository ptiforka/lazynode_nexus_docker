# ---- Dockerfile ----
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN curl -sSf https://cli.nexus.xyz/ | NONINTERACTIVE=1 sh

ENV PATH="/root/.nexus/bin:$PATH"
ENTRYPOINT ["nexus-network", "start", "--node-id", "USER_NODE_ID"]
