FROM  quay.io/sclorg/nodejs-20-c9s@sha256:b44e82ba241fccaadf1205bb71881c2c5936f9cc27ba555b332924e5bb3cce66 AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:1a6da62b99aabda378e5892ab0f497c498f2ae6bf261cf29070fbe80dffa9855

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run