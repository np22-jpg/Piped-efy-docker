FROM  quay.io/sclorg/nodejs-20-c9s@sha256:cfca94e9ff11b9f9cd49120d0cc8a0c346fcfd4e254c55bce60e7b026ba764d9 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:5bb2e77d709935ad0de845dece7e7d27a1003babdd2c82d30da91a4b66bc13e2

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run