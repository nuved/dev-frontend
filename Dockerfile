FROM node:lts-alpine AS builder

ARG NUXT_API_BASE_URL='https://dev-panel.dev.lys.ice.global'
ARG PROJECT_NAME='LYS'
ARG SHOW_REDIS_SEARCH=true

WORKDIR /usr/src/app
RUN apk add python3 make g++ autoconf automake libtool file pkgconf build-base alpine-sdk nasm
COPY . ./
RUN yarn install
ARG NODE_ENV=production
RUN yarn generate

FROM nginx:stable-alpine AS runner

COPY --from=builder /usr/src/app/dist/ /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
