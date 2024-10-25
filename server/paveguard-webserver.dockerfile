# Use the Node.js base image
FROM node:20

# Set working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the app source code
COPY . .

# Expose the NestJS default port
EXPOSE 3000

# Command to run the application
CMD ["npm", "run", "start:dev"]
