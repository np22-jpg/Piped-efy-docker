FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4fb4597023510d4392b73cbe94964754cf7e16e05301cbd62e773b95e4c07dd1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:935ee18203a50c1a61e405ff91626c8a68daf15cb520ae8be714c5e343b34950

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run