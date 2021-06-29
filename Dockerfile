FROM node:lts-alpine AS builder

ENV NUXT_API_BASE_URL https://web-api.projectrivers.com
ENV SHOW_REDIS_SEARCH true
ENV NODE_ENV production

WORKDIR /usr/src/app
COPY yarn.lock package.json ./

RUN yarn install
COPY . ./
RUN yarn build

FROM nginx:stable-alpine AS runner

COPY --from=builder /usr/src/app/dist/ /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
