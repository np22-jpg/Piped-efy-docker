FROM  quay.io/sclorg/nodejs-20-c9s@sha256:1208aefe39d48ad0b29ed83c9c2ef6ec6718ba4386d0b6556b12e3ace9ac1eed AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:f473fd2b4b8c0c418c67685335d212614b30b705486f81ad46e5b0115a20c7ab

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run