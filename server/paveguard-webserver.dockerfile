FROM node:20

WORKDIR /usr/src/app

EXPOSE 3000

CMD ["sh", "-c", "npm install && npm run start:dev"]