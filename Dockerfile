FROM node:16.15-alpine AS builder
USER node
RUN mkdir -p /home/node/app
WORKDIR /home/node/app
COPY --chown=node . .
# Building the production-ready application code - alias to 'nest build'
RUN yarn install --production && yarn build
FROM node:16.15-alpine
USER node
WORKDIR /home/node/app
COPY --from=builder --chown=node /home/node/app/node_modules ./node_modules
# Copying the production-ready application code, so it's one of few required artifacts
COPY --from=builder --chown=node /home/node/app/dist ./dist
COPY --from=builder --chown=node /home/node/app/public ./public
COPY --from=builder --chown=node /home/node/app/package.json .
CMD [ "yarn", "start" ]
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build 

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
