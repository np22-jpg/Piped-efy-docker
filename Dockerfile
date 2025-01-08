FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c6933057a2f6aa7f93a01629c6628d3d411a79ab0ea913046fccc36ff688087d AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:5a2548ce6279e1112a6448e03206d97eb452518f8cdc8d80bbbeba01e6f69e9c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run