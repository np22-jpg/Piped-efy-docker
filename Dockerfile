FROM  quay.io/sclorg/nodejs-20-c9s@sha256:96f1f3b4bd70841485036eb08363a36117f4faca43431fd94d26c499568c5a02 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6fe8ef8c201c8e0e4723bd2e7e9e23ebdfa7e3f3a71e03d0799ef3dfba4b9150

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run