FROM  quay.io/sclorg/nodejs-20-c9s@sha256:7665661493254f2cb1a8a0082433bea0531ac57a0552a1b558a8a1fc500be19a AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d2593d7bed6ca5cac14ed02ef03e70703756eb63f449d8ece566d1e6c4378e43

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run