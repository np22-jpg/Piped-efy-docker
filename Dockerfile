FROM  quay.io/sclorg/nodejs-20-c9s@sha256:4fb4597023510d4392b73cbe94964754cf7e16e05301cbd62e773b95e4c07dd1 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:7728839c48ed41ed56a8b6eb27d4b737027735ff65f4efcc270038555d8abfc7

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run