FROM  quay.io/sclorg/nodejs-20-c9s@sha256:5bf5f8025349caaa77e351c6e8b2ddb279a998e04e8c974c240b37bc11b6f102 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:bb23ff9a1c7c49327b18db4438c3aae446c484b3a80cd63f32faadd4af0697df

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run