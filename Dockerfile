FROM  quay.io/sclorg/nodejs-20-c9s@sha256:8fff5ef50d22f52d656ebcecf51bb6b5bbeab26bf832da41d5a2f841362f3a47 AS build

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