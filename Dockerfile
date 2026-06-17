FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c94ce85b990f163a11ae5cbb13360943650b9c295e2208c1e48ec74bb3b79082 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:14d8b1fe84ba6b256c1fbd8a3e66931b618a26a39d7a69144910c801f38440b6

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run