FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e9ceaac6570fb048afd13e1e5215f808e8d83f688df9bb05a8b0086e539eb047 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0e58602c3c79b9e67626a88b6d4e2e813c9b50db7995341b0b1c2de8637b3959

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run