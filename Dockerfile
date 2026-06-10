FROM  quay.io/sclorg/nodejs-20-c9s@sha256:9df8ec855ffa33cf1eabf182e6c4203c6d8f48fcc2811ab19d2045b76148f584 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3c87d24f942ffecf2e22aa34c6ecc5c720c75a6a5c05855b7b9415bc16ed0028

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run