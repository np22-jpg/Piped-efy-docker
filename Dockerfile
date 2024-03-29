FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ab786b6f252b24c23820da981cea0c8b35e65cb2fb4e64bb498397d78ffcf8c8 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ea9da9665eb373e7b0525634797ca462a094697e4cd9024685fe2fed1a3c21b2

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run