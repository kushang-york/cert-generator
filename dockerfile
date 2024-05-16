FROM node:alpine

# Install certbot
RUN apk add --no-cache certbot

# Install NGINX
RUN apk add --no-cache nginx

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Set up the application directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy the application code
COPY . .

# Install npm dependencies
RUN npm install
RUN sudo systemctl enable nginx
RUN sudo systemctl restart nginx

# Expose ports for Node.js and NGINX
EXPOSE 3000 80

# Start NGINX and Node.js application
CMD ["nginx", "-g", "daemon off;"]

