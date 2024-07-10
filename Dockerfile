FROM  quay.io/sclorg/nodejs-20-c9s@sha256:7f09362c1715a23c1b831afe7aa25fbb48b186745f58abaca605694e0d0c2aae AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:b6bcc2818d84570b44041dcdcd2edce30bebaf5fe5bcd0f0dcd8bd677c7e4a2d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run