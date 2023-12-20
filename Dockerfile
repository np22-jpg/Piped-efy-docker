FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e63279b01fa149cfeb05cd3f49bf558df8a641bbeab1c3fc3b1c17425711ce68 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d278603f4beb00011ec9462a41c2d7dc8a5d971d7153387330ae651ea90e654d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run