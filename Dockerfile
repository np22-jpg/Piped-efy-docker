FROM  quay.io/sclorg/nodejs-20-c9s@sha256:052e11a3d5fedfb7562a0dcda9905d7e7a8c7bd59ef1f05a498e72205fbfab5b AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:aada6fbd5ab146b6df8579426bb868d96393c59405766efe6bee3ebf9cec895d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run