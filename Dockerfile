FROM  quay.io/sclorg/nodejs-20-c9s@sha256:9f3bb6b0b5377eef1b410401b23db08e187ccef8f00d45aef23efef4364d8716 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:9b4d6a86897a02423a23ba9d29896f22ee584f8b66d884f5389ebedd041a97ed

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run