FROM  quay.io/sclorg/nodejs-20-c9s@sha256:7c1ee1ca87bba8294a702decdb5efb5ecc844e874dd8e6b17f837a6e0ac89452 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:d334a7cfd3b98b2a61de65ee3ecedf953ffa53513d09f797c0f021ffc8ea0ea6

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run