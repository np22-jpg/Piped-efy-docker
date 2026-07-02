FROM  quay.io/sclorg/nodejs-20-c9s@sha256:530075841e1fe5353ff27fa6e5fac3b833767b3dfc03f9316db4246fa1b1e97e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:c7bd200f029307a37ebf3dec2fbecd83a832896bc9a9ef0978a6d9c9f2419c75

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run