FROM node:lts-alpine@sha256:32427bc0620132b2d9e79e405a1b27944d992501a20417a7f407427cc4c2b672 AS build

WORKDIR /app/

RUN apk add --no-cache \
    curl

COPY . .

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm install && \
    pnpm build

FROM nginx:alpine-slim@sha256:4716bad84614d17f0159a769c337c00aae1c62100583bcf8b72b76e6861daea4

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
