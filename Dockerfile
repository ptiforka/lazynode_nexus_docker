# ---- Builder stage ----
FROM ubuntu:24.04 AS builder

# 1) Устанавливаем инструменты для сборки
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      curl \
      build-essential \
      pkg-config \
      libssl-dev \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 2) Устанавливаем Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 3) Клонируем и собираем nexus-cli
RUN git clone https://github.com/nexus-xyz/nexus-cli.git /build/nexus-cli
WORKDIR /build/nexus-cli/clients/cli
RUN cargo build --release

# ---- Final stage ----
FROM ubuntu:24.04

# Только runtime-зависимости
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Копируем собранные бинарники из билдера
COPY --from=builder /build/nexus-cli/clients/cli/target/release/* /usr/local/bin/

# Добавляем папку с бинарниками в PATH (если нужно)
ENV PATH="/usr/local/bin:${PATH}"

# Точка входа
ENTRYPOINT ["nexus-network", "start", "--node-id", "USER_NODE_ID"]
