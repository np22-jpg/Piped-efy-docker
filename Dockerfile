FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4b6e4919a58eb2fa4bbcca5c42edb0df54e37eec04048bcf8f43a840c5fde947 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:f258fc814342da2f527ac541ae2bb6c7e523861799307e343033f60fa9c3399a

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run