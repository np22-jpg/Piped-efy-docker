FROM  quay.io/sclorg/nodejs-20-c9s@sha256:5bf5f8025349caaa77e351c6e8b2ddb279a998e04e8c974c240b37bc11b6f102 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:13ec6344ae0d7fb6612a75756ac5daf51146a106f46b1896732351f69a4814b8

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run