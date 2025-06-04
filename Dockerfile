FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4f1da5d46ae3c87ad2a0355a1e4b2f20c47e4af3bca28c4bc62b638827bd6117 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:fc0516b9bc9dbcab9ab735e643e8016cee719ac9bb1c53f6a89b1bf36a07abe0

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run