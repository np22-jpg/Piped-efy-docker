FROM  quay.io/sclorg/nodejs-20-c9s@sha256:6a254990e24373afeb664f0fea7f8172fbfd33ae8673d54c7084d09aef42a832 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:37bf071e79024305a59704ec59bae7037d47e7396ca91cb667b7bbccaf0fc09f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run