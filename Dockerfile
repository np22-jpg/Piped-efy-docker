FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b92d9d7617496288676478e8a487126f50e3a6cf3da989e2e0e3c38edb4aa80e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:357fce7bca6c0d1b54d132b32cbbe9f7b8e6f0b713af4f10e55619803fcb4ea5

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run