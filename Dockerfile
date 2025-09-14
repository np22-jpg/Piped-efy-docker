FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b5df17a9c3def1f63ef84f7c41b435c0ebd6df96134c4107eb58ba09bf514060 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:01a2e80c8c15e43850b91215a2fca9aff5bcf0974ea0b6a84071e57fc6501d9f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run