FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c6c0e84435201e26071caff0884659e794fc62b1b5b5bffecb62fcb2cd751603 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e576e584bd5d04cbba14b838b589dc250fabfb4053b4f3d2b87dcc59e6cefc3b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run