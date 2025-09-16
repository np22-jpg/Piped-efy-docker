FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b5df17a9c3def1f63ef84f7c41b435c0ebd6df96134c4107eb58ba09bf514060 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3ef84a1c619b0d411175dab9dd032430b317c15c7852a998b71388f263106769

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run