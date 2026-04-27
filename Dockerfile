FROM crystallang/crystal:1.20.0-alpine AS builder
RUN mkdir /build
WORKDIR /build
# Add build dependencies.
# RUN apk add --no-cache sqlite-static yaml-static
# Copying and install dependencies.
COPY shard.yml shard.lock ./
RUN shards install --production
# Copy the rest of the code.
COPY src/ src/
COPY view/ view/
COPY public/ public/
RUN shards build --release --production --static golurker

FROM alpine:3
# Don't run as root. This is the core user on delta.
USER 1000:1000
# Copy only the app from the build stage.
COPY --from=builder /build /
# Install a CA store.
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/
COPY --from=builder /usr/share/zoneinfo/Europe/Copenhagen /usr/share/zoneinfo/Europe/
VOLUME /storage

EXPOSE 80

ENV BNF_USER=""
ENV BNF_PASS=""

ENTRYPOINT ["/bin/golurker", "--port", "80"]
