FROM  quay.io/sclorg/nodejs-20-c9s@sha256:09b998858343e9ec7522bcf604b431061a7485b2263372b5f7327c0cc13574e1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0b34e028f0223c266ecee045d381f5f4c38253637a5157632e5c5adb11a52c4c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run