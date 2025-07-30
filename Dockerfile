FROM  quay.io/sclorg/nodejs-20-c9s@sha256:923d52116dbd0ced0def024151a43dc18a217ab071364ae28cf65ba7b5fe617d AS build

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