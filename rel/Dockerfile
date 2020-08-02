FROM elixir:latest AS builder

ENV MIX_ENV=dev

WORKDIR /builder/

RUN mix deps.get && \
  mix compile && \
  npm install --prefix ./assets && \
  npm run deploy --prefix ./assets && \
  mix phx.digest && \
  mix release


FROM postgres:13 AS runtime

WORKDIR /app/

RUN createdb demo_dev

ENV DATABASE_URL=postgres://postgres@localhost:demo_dev

COPY --from=builder /builder/_build/dev /app

# Release created at _build/dev/rel/prod!
#     # To start your system
#     _build/dev/rel/prod/bin/prod start
#
# Once the release is running:
#     # To connect to it remotely
#     _build/dev/rel/prod/bin/prod remote
#     # To stop it gracefully (you may also send SIGINT/SIGTERM)
#     _build/dev/rel/prod/bin/prod stop
#
# To list all commands:
#     _build/dev/rel/prod/bin/prod

CMD ["./rel/prod/bin/prod start"]
