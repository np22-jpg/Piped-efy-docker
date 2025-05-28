FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d6475bdbe46b8b2bd55a8be2793f9fb67c58c5f57351386d41eb4412fdee70fa AS build

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