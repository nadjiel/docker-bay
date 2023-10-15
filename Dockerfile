# syntax=docker/dockerfile:1

# Specifying base image to this image: the official Nodejs 18 alpine linux image
FROM node:18-alpine

# Setting the directory for the following instructions
WORKDIR /app

# Copying the package.json and the yarn.lock from this directory to the working directory specified at WORKDIR
COPY package.json yarn.lock ./

# Installing the dependencies on the package.json, excluding the development ones
RUN yarn install --production

# Copying all files from this directory to the working directory specified at WORKDIR
COPY . .

# Specifying the command to execute when the application starts: node src/index.js
CMD ["node", "src/index.js"]

# Exposing the port 3000 on the container
EXPOSE 3000
