FROM  quay.io/sclorg/nodejs-20-c9s@sha256:83960db0bc14915aa4835b5a5d132a161bdc1708d3af1e667eabca8f808484b0 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:05425aa09caa5c974e5ee9845f33b070f791e645ca20e3dab93638b277918fd5

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run