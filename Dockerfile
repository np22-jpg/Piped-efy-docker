FROM  quay.io/sclorg/nodejs-20-c9s@sha256:e21fde8279d4e34b3e4bf1a9e62b869119d8bf01004a73b00836ade36f98dafe AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:61e5107ac30b610bd555becf8104f0e1816e6ddf007472ec8926b835838f6251

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run