FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b7d0553c51881f1a9716442da476be26d834a3d2586c327249a8fec6cc0e813d AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:ad0dddda4345a4302d844127fbb924424037e4f1126257a02711ecf03ee17eda

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run