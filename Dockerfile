FROM  quay.io/sclorg/nodejs-20-c9s@sha256:39dc3afa743635e6571171013a8c6430003cb98f7756e6fb921638d710330fa3 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:3d9059f47856b1951ae8836d4516a03cb11afb92eb12832943c0b528452ec9f7

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run