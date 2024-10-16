FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b672069eefe162733706250390c528650549c2bcb998e0d9c37e9036c364cbf4 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:427f638f35c494d2d929834f29308e9a2e50f196c9edbd094f44d53f3f5510f8

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run