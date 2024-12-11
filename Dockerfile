FROM  quay.io/sclorg/nodejs-20-c9s@sha256:169bb287f94072f26ca39992ca58b81ad397152d5946d8a524b7de1efcb67514 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:973626e91f6270421cb9872ffc820e9e3e1d6961219dbee174258e590666625d

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run