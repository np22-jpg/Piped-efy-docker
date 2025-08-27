FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ff4a23013add976d58dd31265013a5d9ce71130e4fe45e5bde228772dd174c9e AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:5f8c5f746abdeb3ba64d17e519d2681018175d87ff278766bdac1acf967ab662

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run