FROM  quay.io/sclorg/nodejs-20-c9s@sha256:605d2477a7d7004f2a1a18581ac913515170d5ccb689e83fdc8655304c3e643a AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:725341b5f16453040f2358d5de37cb757315491d3f4b65ae7f8eb5e9d233667b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run