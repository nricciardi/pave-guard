# PaveGuard WebServer

## Tecnologie

**NodeJS** con la libreria **NestJS** per la creazione delle API. Python (Flask, Django) è stato scartato perché Nest permette tipizzazione tramite integrazione con TypeScript e una buona integrazione con MongoDB.

**MongoDB** per via della sua flessibilità (i dati in arrivo dai diversi dispositivi sono eterogenei). Inoltre supporta timeseries (anche InfluxDB, ma Mongo permette di gestire collection per dati più tradizioni come utenti).

## Quick start

```bash

```


## Docker

Creare un nuovo progetto (da fare una tantum):

```bash
docker run -it --rm -v $(pwd):/usr/src/app nestjs-cli nest new pave-guard-webserver
```













