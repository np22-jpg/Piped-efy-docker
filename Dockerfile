FROM  quay.io/sclorg/nodejs-20-c9s@sha256:84aaa81445c10a080374251afc347fc4323cdcee14ed0eaeb634edcaea78ab5f AS build

WORKDIR /app/

COPY . .

USER 0
RUN npm install -g pnpm && \
    chown -R 1001:0 /app/

USER 1001
RUN pnpm install && \
    pnpm build

FROM quay.io/sclorg/nginx-122-micro-c9s@sha256:7f7a1709649ee6cc68f44b71d599a26f1c5f5b23b83abdc81fde66a94005918f

COPY --from=build --chown=nginx /app/dist /tmp/src
ADD --chown=nginx docker/nginx.conf  /tmp/src/nginx.conf

# Let the assemble script to install the dependencies
RUN /usr/libexec/s2i/assemble

# Run script uses standard ways to run the application
CMD /usr/libexec/s2i/run