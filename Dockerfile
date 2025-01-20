FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b9948f0ac0edb0587ba3ee2dcaf7b048bd29762e902d8ac30b90018ed7379ff0 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ba7ffe32d5335a405a53afcc1ff16493026e49c8ed8e2e0947587f3ffa189921

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run