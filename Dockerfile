FROM  quay.io/sclorg/nodejs-20-c9s@sha256:394af2b55cb530c815bd4ac28f0ae551ebe67e5e7b2a80796b5d1e8fd7a78188 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:63e4d75f1d1b72356bbac801b10b8b16fb9bcf10b0f7476510981b9a75cecddd

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run