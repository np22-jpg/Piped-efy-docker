FROM  quay.io/sclorg/nodejs-20-c9s@sha256:96d7479bd44c047715d93168ff0b805ed7f1ebc9bb3ab647fdf3755e45a97a42 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:f7be28adda9be08eec0db4238cc66caf50184b6dc74b00fb3bf9a8746f476894

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run