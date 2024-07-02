FROM  quay.io/sclorg/nodejs-20-c9s@sha256:dd94e4937b7d47368f6078a5e1285990de6f85eac9c71e6be224871614dbeaf3 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0c2d351574ce2dbced1f753de32cee90f35a997b6934e85de0d7f4dbd9127b8f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run