FROM  quay.io/sclorg/nodejs-20-c9s@sha256:7e234584719a7a9e3c1c945285c45fd96e67da3b1201fde15bb3f3f1b47a4b65 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6a87e9af342f4a10d16caf1b44e008d4849a9e0edd552a74c7a5ca1a69e2d8e3

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run