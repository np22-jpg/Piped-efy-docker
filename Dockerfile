FROM  quay.io/sclorg/nodejs-20-c9s@sha256:1d3111df615334d213eac282fd093cab4fa1246af468064963828d483ce9117c AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:81b828a1727d8ea6fe527ba495b4baa278a3591047eab12b96f035cd127a8d77

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run