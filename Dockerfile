FROM  quay.io/sclorg/nodejs-20-c9s@sha256:9681ad9ad312300c9cdd13dbae67839cbaa825f64d32eb64ea847290ec723861 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ffa68c881002aca493da4ffbae47d3b3705d1004e83fb928b241d03ce8085ae8

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run