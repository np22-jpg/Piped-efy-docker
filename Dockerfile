FROM  quay.io/sclorg/nodejs-20-c9s@sha256:2b473a7c7fab09519c3b8295775f01c9f3141956f35b3ca9f91936c8a6082052 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:92ba892b6e41a8e95a1d167b870281afd1c851a25073864198c9e00a8d73ec7b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run