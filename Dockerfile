FROM  quay.io/sclorg/nodejs-20-c9s@sha256:43a602d96d59954fa5204b5caa333bed96439fa021e0a0c7529858e3e54bc9d2 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:7e15be9a1f00343822e4ab0617e4df4b97ba851302b41f899f8ccae74143cd8b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run