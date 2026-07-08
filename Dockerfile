FROM  quay.io/sclorg/nodejs-20-c9s@sha256:530075841e1fe5353ff27fa6e5fac3b833767b3dfc03f9316db4246fa1b1e97e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:0e62075e95192c69b2fb4e7bbe8f0321735afc22abc2bf882244a741acf43bf9

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run