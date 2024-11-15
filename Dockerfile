FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ba79f05566ac513ff1118ee6f86bcca4cc7c2ffafb23258168610eb3dc1db92b AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3b77f7a31438f0b49e15bb9efffc948e78734e86dd3da199f6d6bab3311bb5d2

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run