FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ec751b1d114bae536e36d47f4bfa81c77382b8c31f544db1451e0026072b42f5 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e4dcc97017be905bd92d6ced2070d1323e6d1b63a8aa798e72185d6f7762c03b

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run