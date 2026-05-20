FROM  quay.io/sclorg/nodejs-20-c9s@sha256:66f202bfc33d67756a3fae560a88fd8323f0f36d69996618126eedcddc723a65 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c20a0eb24e80b8520a3b49ca9b911c063dd395705678bac532dba91d3a25bf29

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run