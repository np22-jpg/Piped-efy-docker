FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e47418b11a52dec976d2d4109416e1f1f92777b7cca6e3dc6e72d923cf7b9d9a AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:1fde8da596307dfe74d04114dc7aaae7408d117c9873d3efdb64859fee44bb26

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run