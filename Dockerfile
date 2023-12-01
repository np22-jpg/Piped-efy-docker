FROM node:lts-alpine@sha256:32427bc0620132b2d9e79e405a1b27944d992501a20417a7f407427cc4c2b672 AS build

WORKDIR /app/

RUN apk add --no-cache \
    curl

COPY . .

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm install && \
    pnpm build

FROM nginx:alpine-slim@sha256:6af140b2ad5a495d3d9e1293a0b4dc74f2a14f6425f9e3faafe0c87b12097d7c

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
