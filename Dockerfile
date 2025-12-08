FROM  quay.io/sclorg/nodejs-20-c9s@sha256:c3d5267520359a3c68d5a4b0a3f1e604ad3334bb4c02a51d17fe6942252308a1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:9f0157e8b0bc387070aa54dea2c1fb2c36d398f4d68dd147949e5333b53c3d7c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run