FROM  quay.io/sclorg/nodejs-20-c9s@sha256:928a09fb9ed24fd8983f68fc667a645766793b1a7b61f215a7a36175dd57a657 AS build

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