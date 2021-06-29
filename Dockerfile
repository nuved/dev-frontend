FROM node:lts-alpine AS builder
 
WORKDIR /usr/src/app
COPY yarn.lock package.json ./

RUN yarn install
COPY . ./
RUN yarn build

FROM nginx:stable-alpine AS runner

COPY --from=builder /usr/src/app/dist/ /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
