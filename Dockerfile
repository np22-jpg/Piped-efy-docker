FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b3ca0effda786aae042b23920f2085b603d81b263d0d25879713657f2caba76b AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:e8d43d2854aac6e3543e65f76b5b06752f6e5a0e7b0a1b5a55904b38a076a1be

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run