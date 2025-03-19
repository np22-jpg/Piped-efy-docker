FROM  quay.io/sclorg/nodejs-20-c9s@sha256:43c96f45799507db90d27a2fbd7bfe695ce15cb2b77b96ad30c7512ff56a6bf4 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:56ad77b97a6a3314022eae66e106cb00f8bd1b8ebb6eb9e4b1498967663a2c30

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run