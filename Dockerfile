FROM  quay.io/sclorg/nodejs-20-c9s@sha256:5c129be6a92681172d0714910f9f1ab4f609d9a026f1a759e4770b3ed92e69f9 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c35de63b09211950166cc442d7da9900ad82f85a892fbdd47d8578952d3de4ed

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run