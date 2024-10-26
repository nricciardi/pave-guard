# PaveGuard WebServer

**NodeJS** con la libreria **NestJS** per la creazione delle API. Python (Flask, Django) è stato scartato perché Nest permette tipizzazione tramite integrazione con TypeScript e una buona integrazione con MongoDB.

## Quick start

Create `.env` file:

```
DB_HOST=mongo
DB_PORT=27017
DB_USER=paveguard-webserver
DB_PASS=PaveGuardWebserverPsw123!
DB_NAME=paveguard

GRAPHQL_PLAYGROUND_ENABLED=true
GRAPHQL_PATH=/graphql
```

To start server, run in the directory of `compose.yml` file:

```bash
docker compose up       # ...or docker-compose 
```

To use `npm` or `nest` commands:

```bash
docker run -u $(id -u ${USER}):$(id -g ${USER}) --rm -it -v $(pwd)/paveguard-webserver:/usr/src/app nestjs-cli {command}
```


## Docker

Creare un nuovo progetto (da fare una tantum):

```bash
docker run -it --rm -v $(pwd):/usr/src/app nestjs-cli nest new pave-guard-webserver
```


Per usare un endpoint di un altro container l'hostname è `nome-container:port`


# Database

**MongoDB** per via della sua flessibilità (i dati in arrivo dai diversi dispositivi sono eterogenei). Inoltre supporta timeseries (anche InfluxDB, ma Mongo permette di gestire collection per dati più tradizioni come utenti).

## MongoDB

Credenziali admin:

- `root`
- `root`


Credenziali webserver su database `paveguard`:

- `paveguard-webserver`
- `PaveGuardWebserverPsw123!`


## Mongo Express

Client per utilizzare il database.

Credenziali:

- `admin`
- `pass`




