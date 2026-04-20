FROM  quay.io/sclorg/nodejs-20-c9s@sha256:5dce54e622dd8deb707f424959c3862a49b2875eaf0cd675965baed76185e624 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b9b6aa4247bd45ed894948dadf3e34da654510ba886c105c3ce93ffb4b23097c

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run