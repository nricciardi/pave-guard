# PaveGuard WebServer

**NodeJS** con la libreria **NestJS** per la creazione delle API. Python (Flask, Django) è stato scartato perché Nest permette tipizzazione tramite integrazione con TypeScript e una buona integrazione con MongoDB.

## TODO

- [ ] Capire come autenticare gli static guard nell'invio delle telemetrie

## Quick start

Creare `.env` file in `paveguard-webserver` directory:

```
APP_KEY=dacambiare
APP_ENV=local

DEBUG=true

DB_PROT=mongodb
DB_HOST=mongo
DB_PORT=27017
DB_USER=paveguard-webserver
DB_PASS=PaveGuardWebserverPsw123!
DB_NAME=paveguard

GRAPHQL_PLAYGROUND_ENABLED=true
GRAPHQL_PATH=/graphql
```

> [!IMPORTANT]
> Change password, this is an example.

In production, `DB_PROT=mongodb+srv`


Installa i moduli node in locale:

```bash
# build util image
docker image build -t nestjs-cli -f nestjs-cli.dockerfile .

# Linux:
docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -it -v $(pwd)/paveguard-webserver:/usr/src/app nestjs-cli npm install
# Windows:
docker run --rm -it -v .\paveguard-webserver:/usr/src/app nestjs-cli npm install
```

> [!TIP]
> Se dà errori di permessi: `sudo chown -R <tuo-utente> paveguard-webserver` 

Avvia tutti i servizi lanciando nella directory di `compose.yml` file:

```bash
docker compose up
```

Problemi:

- impossibile leggere undefined => manca `.env`
- errore di autenticazione => manca il db e/o utente mongo (guarda la sezione [database](#database) su come creare un utente)

Apollo server (per fare le query delle API graphql): `http://127.0.0.1:3000/graphql`


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
query {
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
  "Authorization": "Bearer <token>" 
}
```

## Device

Esempio di creazione di un device tramite API (serva autorizzazione):

```gpl
mutation {
  createDynamicGuard(
    serialNumber:"test2",
    userId:"6723a183c409ba66f35f57fd"
  ) {
    id
  }
}
```

## Telemetrie

Esempio di aggiunta di una telemetria:

```gql
mutation {
  createTemperatureTelemetry(
    temperature: 50,
    timestamp:"2024-11-08 23:44:00",
    deviceId:"672e8d9704b74a2a2971c5e5",
    latitude:100,
    longitude:100
  ) {
    id
  }
}
```

Ottenimento dati telemetrie:

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




