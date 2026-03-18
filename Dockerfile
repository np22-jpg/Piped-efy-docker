FROM  quay.io/sclorg/nodejs-20-c9s@sha256:7c1ee1ca87bba8294a702decdb5efb5ecc844e874dd8e6b17f837a6e0ac89452 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:20b7d6ebcdd8a9922ca8a6e468500a0d0bc5190367d4fda92da4f467883d6d17

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run