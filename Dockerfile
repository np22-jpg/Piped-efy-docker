FROM  quay.io/sclorg/nodejs-20-c9s@sha256:3dbb1c3f58ccf3319ab71b0d779e1b1fab1a875457394d90dac147e29bdc3924 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ce9839dfd49cb5c2f20c516f1a9210c0870bbd9b85597bce0600d31b4f1cc5aa

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run