FROM  quay.io/sclorg/nodejs-20-c9s@sha256:08f3d7b96f48b15e82e1ca39fa633df4d1c1689524330927e80f2cb34071e6a8 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:14874dc99fd8efb69cf8ce08bfd3455ac477db1bb97b36cb2e77e0b03ee82320

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run