FROM  quay.io/sclorg/nodejs-20-c9s@sha256:086a839de3e2a596231a5fe16115c01e9f5a9849a2da53c89d223583a4518c26 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d3507e26a3b074cfb54e8ebff6e08b6d4c06f1a55d62bacc46360d8a41cf2496

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run