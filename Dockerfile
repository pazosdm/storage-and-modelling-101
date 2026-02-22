FROM golang:1.22-alpine AS builder

WORKDIR /build
COPY auto_grader/ ./auto_grader/
RUN cd auto_grader && go build -o /grader .

FROM alpine:3.19

# Install DuckDB
RUN apk add --no-cache curl unzip bash \
    && curl -L -o duckdb.zip https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-amd64.zip \
    && unzip duckdb.zip -d /usr/local/bin \
    && rm duckdb.zip \
    && chmod +x /usr/local/bin/duckdb

# Copy grader binary
COPY --from=builder /grader /usr/local/bin/grader

# Create workspace directory
WORKDIR /workspace

# Copy exercises and solutions structure
COPY exercises/ /workspace/exercises/
COPY solutions/ /workspace/solutions/

# Entry point
CMD ["bash"]
