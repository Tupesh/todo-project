FROM node:20-alpine AS builder
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
WORKDIR /app
COPY package*.json ./
RUN npm ci 
COPY . .
RUN npm run build

# CMD ["npm", "run", "preview", "--", "--port", "80", "--host", "0.0.0.0"]

FROM nginx:alpine

COPY --from=builder /app/dist/ /usr/share/nginx/html/

EXPOSE 80