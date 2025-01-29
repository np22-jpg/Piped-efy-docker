FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ac9e9d0e5d459376e769b9ae8365fed77a74c867b6e0c2822ef5262b689dada4 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e1148288c8120177a5bdb1097295b58c5db7d7ed2092b820ee6c2c3a66a9e38c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run