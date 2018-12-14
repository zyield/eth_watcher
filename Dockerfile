# docker build -t kube_native:builder --target=builder .
FROM elixir:1.7.3-alpine as builder
RUN apk add --no-cache \
    gcc \
    git \
    make \
    musl-dev
RUN mix local.rebar --force && \
    mix local.hex --force
WORKDIR /app
ENV MIX_ENV=prod

# docker build -t kube_native:deps --target=deps .
FROM builder as deps
COPY mix.* /app/
RUN mix do deps.get --only prod, deps.compile , deps.clean mime --build

# docker build -t kube_native:releaser --target=releaser .
FROM deps as releaser
COPY . /app/
RUN mix do release --env=prod --no-tar

# docker run -it --rm elixir:1.7.3-alpine sh -c 'head -n1 /etc/issue'
FROM alpine:3.8 as runner
RUN addgroup -g 1000 eth_watcher && \
    adduser -D -h /app \
      -G eth_watcher \
      -u 1000 \
      eth_watcher
RUN apk add -U bash libssl1.0 postgresql-client
USER eth_watcher
WORKDIR /app
COPY --from=releaser /app/_build/prod/rel/eth_watcher /app
EXPOSE 4000
ENTRYPOINT ["/app/bin/eth_watcher"]
CMD ["foreground"]
