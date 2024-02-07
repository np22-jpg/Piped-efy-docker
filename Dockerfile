FROM  quay.io/sclorg/nodejs-20-c9s@sha256:77dfc06487f4427fce30f945cbf7e01b62fb19da45d3a2cebae047bd529b5332 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b05dc0aa0f9cd601e0af7fdadee4195a8d9f297e1d0ed6ea409f0600bab21b46

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run