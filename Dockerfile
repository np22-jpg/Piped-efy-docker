FROM  quay.io/sclorg/nodejs-20-c9s@sha256:6c50f47d3e4ab3609c0be75e4f97c91cb8aabc7190e6e513f39255a91915f062 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:6d8efa076b565f1563770095510af60d292864bab0f40bf2c1171fcac96b70f9

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run