FROM  quay.io/sclorg/nodejs-20-c9s@sha256:25e94e96920b669218aca52bd7e5b8faf67f8eb8ec946f6d13a8626301e5da35 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c8ff408157f0c06261764dd3ecadf6fb27526b259a61852e57e30bfc5eb1614f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run