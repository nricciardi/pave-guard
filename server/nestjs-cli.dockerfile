FROM node:20

# Installa la CLI di NestJS globalmente
RUN npm install -g @nestjs/cli

# Imposta la directory di lavoro
WORKDIR /usr/src/app
