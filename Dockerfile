FROM  quay.io/sclorg/nodejs-20-c9s@sha256:315be78a50484d0338d90e4ca5b6b5afee0d13a484db8cf83fa60f31e3885e22 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b42e742ad0536a812fef61ada697126b34d601702bb93cb073af9af59df37907

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run