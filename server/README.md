# PaveGuard WebServer

**NodeJS** con la libreria **NestJS** per la creazione delle API. Python (Flask, Django) è stato scartato perché Nest permette tipizzazione tramite integrazione con TypeScript e una buona integrazione con MongoDB.

## Quick start

Creare `.env` file in `paveguard-webserver` directory:

```
APP_KEY=dacambiare

DB_HOST=mongodb
DB_PORT=27017
DB_USER=paveguard-webserver
DB_PASS=PaveGuardWebserverPsw123!
DB_NAME=paveguard

GRAPHQL_PLAYGROUND_ENABLED=true
GRAPHQL_PATH=/graphql
```

Installa i moduli node in locale:

```bash
docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -it -v $(pwd)/paveguard-webserver:/usr/src/app nestjs-cli npm install
```

Avvia tutti i servizi lanciando nella directory di `compose.yml` file:

```bash
docker compose up
```

Problemi:

- impossibile leggere undefined => manca `.env`
- errore di autenticazione => manca il db e/o utente mongo (guarda la sezione [database](#database) su come creare un utente)

Apollo server (per fare le query delle API graphql): `http://127.0.0.1:3000/graphql`

Prova di funzionamento:

```gql
mutation {
  createTemperatureTelemetry(
    temperature: 42,
    timestamp: 1234567890,
    deviceId: "testId"
  ) {
    id
  }
}
```

```gql
query {
  temperatureTelemetries {
    id
  },
  humidityTelemetries {
    id
  }
}
```

## Doc

Creare un nuovo sensore:

1. Creare un nuovo service
2. Creare un nuovo schema
3. Creare un nuovo set di DTO
4. Aggiungere il service ai `providers` nel modulo `telemetry.module.ts`
5. Aggiungere un discriminatore a `Mongoose` e alla proprietà di `Telemetry`
6. Esportare il service
7. Creare un resolver
8. Aggiungere il resolver ai `providers`


## Docker

Per usare `npm` or `nest`:

```bash
docker build . -f nestjs-cli.dockerfile -t nestjs-cli
```

```bash
docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -it -v $(pwd)/paveguard-webserver:/usr/src/app nestjs-cli {command}
```

Creare un nuovo progetto (da fare una tantum):

```bash
docker run -it --rm -v $(pwd):/usr/src/app nestjs-cli nest new pave-guard-webserver
```

Per usare un endpoint di un altro container l'hostname è `nome-container:port`

## Authentication

Signup:

```gql
mutation {
  signup(
    email: "jd@mail.com",
    password: "psw",
    firstName: "John",
    lastName: "Doe",
    userCode: "JDCODE"
  ) {
    token
  }
}
```

Login:

```gql
mutation {
  login(
    email: "jd@mail.com",
    password: "psw"
  ) {
    token
  }
}
```

Ottenere le informazioni per l'utente corrente:

```gql
query {
  me {
    email
  }
}
```

Le informazioni vengono prese dal token JWT passato nell'**header**, ad esempio:

```js
{
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzIxZWQzNjc4MzM2MjU4YWFmM2VhMTkiLCJ1c2VyRW1haWwiOiJqZDNAbWFpbC5jb20iLCJpYXQiOjE3MzAyOTUyNjksImV4cCI6MTczMDI5ODg2OX0.1X_HC-yLUY3-9itP-d6xcuiXpfQZNKC8f5sM70p2z1Q" 
}
```

## Database

**MongoDB** per via della sua flessibilità (i dati in arrivo dai diversi dispositivi sono eterogenei). Inoltre supporta timeseries (anche InfluxDB, ma Mongo permette di gestire collection per dati più tradizioni come utenti).

## MongoDB

Credenziali admin:

- `root`
- `root`


Mantenendo il servizio `mongodb` running, accedere a Mongodb:

```bash
docker exec -it mongodb mongo -u root -p root --authenticationDatabase admin
```

Creare l'utente per il webserver:

```js
use paveguard;
```

```js
db.createUser({
  user: "paveguard-webserver",
  pwd: "PaveGuardWebserverPsw123!",
  roles: [
    { role: "readWrite", db: "paveguard" }
  ]
});
```


Credenziali webserver su database `paveguard`:

- `paveguard-webserver`
- `PaveGuardWebserverPsw123!`


## Mongo Express

Client per utilizzare il database.

Credenziali:

- `admin`
- `pass`




