# Stage 1: Build Angular
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build --prod

# Stage 2: Serve using Nginx
FROM nginx:alpine

COPY --from=build /app/dist/angular-15-crud/ /usr/share/nginx/html/

COPY generate-env.sh /docker-entrypoint.d/40-generate-env.sh

RUN sed -i 's/\r$//' /docker-entrypoint.d/40-generate-env.sh && chmod +x /docker-entrypoint.d/40-generate-env.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
