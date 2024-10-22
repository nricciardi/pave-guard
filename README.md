# PaveGuard

Sistema distribuito per il monitoraggio delle strade urbane.

[*TODO*](TODO.md)

## Rete di dispositivi

PaveGuard si compone di due differenti tipologie di dispositivi fisici:

- **Static Guard**
- **Dynamic Guard**



### Static Guard 

**Static Guard** sono dispositivi montati su lampioni o pali per monitorare le *condizioni ambientali* 
(es. meteo) e il *livello di traffico* di un breve tratto di strada.

#### Bridge
Nel prototipo, il **bridge** deve essere un dispositivo collegato tramite TODO ad uno o più static guard.

TODO: Collegato con cavo o collegato con rete?

#### Sensori

I sensori sono montati sullo static guard e i dati vengono gestiti tramite un microcontrollore.

##### Microfono

Tramite un microfono, lo static guard riesce a contare il numero di automobili che percorrono la strada che monitora, e quindi intuire lo stato del traffico presente.

TODO: Capire le soglie

##### Meteo

Attraverso alcuni sensori specifici, lo static guard è in grado di monitorare lo stato del meteo attuale. Questi sensori misurano:

- Umidità
- Temperatura
- ...

TODO: Altri?

TODO: Meteo=grado di pioggia (da 0 a 10)?

### Dynamic Guard 

**Dynamic Guard** sono dispositivi installati su auto che muovendosi nell'ambiente urbano catturano informazioni sulle 
reali condizioni stradali grazie a 3 parametri:

- **Velocità**
- **Vibrazione** (per individuare tratti stradali a pelle di coccodrillo)
- **Videocamera** (per individuare tratti stradali con buche evidenti)

L'unione dei dati dei dynamic guard, dei guard fissi e meteo dei giorni/mesi successivi su un tratto di strada forniscono i dati per fare **previsioni** su eventuali futuri interventi da effettuare per il rifacimento del tratto stradale o eventuale manutenzione predittiva.

#### Bridge

Nel prototipo il **bridge** è vincolato ad essere un dispositivo mobile (Android!) che abbia:

- GPS
- Connessione a Internet

Lo smartphone invia i dati al server tramite la connessione dati

TODO: ogni quanto mandare i dati al server?

TODO: bluetooth o cavo per connettere lo smartphone con micro-controllore + sensori.  

TODO: come fare (flutter, nativa?), cosa mettere (dashboard)?


#### Sensori

Alcuni sensori sono interni al bridge (sicuramente, la telecamera), mentre altri sono esterni e gestiti da un microcontrollore (come l'accelerometro).

TODO: Il GPS, interno o esterno?

##### Velocità

La **velocità** viene ottenuta tramite i sensori presenti quali:

- GPS
- Accelerometro
- ...

TODO: come fare?


##### Telecamera

Il sensore che si occupa di recupero immagini è già presente nel bridge (telefono) e monitora lo stato della strada.

TODO: foto frequency in base alla velocità

TODO: dataset e modello (yolo)


## Analisi dei dati

I dati generati e aggregati da PaveGuard sono raccolti e analizzati da due enti:

- **Server**
- **Analyser**

### Server

TODO: Protocollo HTTP, giusto?

TODO: Per il prototipo, gestiamo tutto in locale?

### Analyser

TODO: Mi fermo qui per evitare di dire carognate.

## Risorse

Per capire il traffico e se la strada è bagnata: https://acoustics.org/assessment-of-road-surfaces-using-sound-analysis/

Esempio rudimentale sistema rilevazione buche: https://github.com/anantSinghCross/pothole-detection-system-using-convolution-neural-networks

Photole detection più studiato con dati: https://github.com/tamagusko/pothole-detection 

https://github.com/noorkhokhar99/Pothole-Detection-Pothole-Detection-using-python-and-deep-learning

https://github.com/biodatlab/learnai-potholes-detection