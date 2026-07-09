FROM  quay.io/sclorg/nodejs-20-c9s@sha256:6ceea83ec6b6beb98cf868257ea5c140fee13018fbf75b812e123893ed03f9fb AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:8df2e27d2e60a5c93fd0ea41a048f21a21a7b4c9eeec33561cf2c21cfe2f8177

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run