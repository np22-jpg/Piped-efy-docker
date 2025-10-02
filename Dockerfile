FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4a42cb9cdb58579b7a98fd690daf86edd1f779e049dd74a4f8a5083c3bcc8fbd AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:40543bc6d4cd001fa873411de2c8d556d4db957bbe839fe8ab83fd0e55e70fbc

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run