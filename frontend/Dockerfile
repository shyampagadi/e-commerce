# Build Stage
FROM node:18-alpine AS builder

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG REACT_APP_API_URL=http://localhost:8000
ARG REACT_APP_API_BASE_URL=http://localhost:8000/api/v1

LABEL maintainer="ecommerce-team@example.com" \
      org.opencontainers.image.title="E-Commerce Frontend" \
      org.opencontainers.image.description="React frontend for e-commerce application" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://gitlab.com/your-org/e-commerce"

WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci --silent
COPY frontend/ .
ENV REACT_APP_API_URL=$REACT_APP_API_URL \
    REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL \
    NODE_ENV=production
RUN npm run build

# Production Stage with Nginx
FROM nginx:1.25-alpine AS production

RUN apk update && apk upgrade && apk add --no-cache curl

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx configuration files
COPY docker/nginx.conf /etc/nginx/conf.d/
COPY docker/security-headers.conf /etc/nginx/conf.d/

COPY --from=builder /app/build /usr/share/nginx/html

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
