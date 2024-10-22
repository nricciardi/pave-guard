# PaveGuard

Sistema distribuito per il monitoraggio delle strade urbane.


## Rete di dispositivi

PaveGuard si compone di due differenti tipologie di dispositivi fisici:

- **Static Guard**
- **Dynamic Guard**



### Static Guard 

**Static Guard** sono dispositivi montati su lampioni o pali per monitorare le *condizioni ambientali* 
(es. meteo) e il *livello di traffico* di un breve tratto di strada.


### Dynamic Guard 

**Dynamic Guard** positivi installati su auto che muovendosi nell'ambiente urbano catturano informazioni sulle 
reali condizioni stradali grazie a 3 parametri:

- **Velocità**
- **Vibrazione** (per individuare tratti stradali a pelle di coccodrillo)
- **Videocamera** (per individuare tratti stradali con buche evidenti)

L'unione dei dati dei guard mobili, dei guard fissi e meteo dei giorni/mesi successivi su un tratto di strada forniscono i dati per fare **previsioni** su eventuali futuri interventi da effettuare per il rifacimento del tratto stradale o eventuale manutenzione predittiva.

#### Bridge

Nel prototipo il **bridge** è vincolato ad essere un dispositivo mobile (Android!) che abbia:

- GPS
- Connessione a Internet

Lo smartphone invia i dati al server tramite la connessione dati

TODO: ogni quanto mandare i dati al server?

TODO: bluetooth o cavo per connettere lo smartphone con micro-controllore + sensori.  

TODO: come fare (flutter, nativa?), cosa mettere (dashboard)?


#### Sensori

TODO: utilizzare solo il telefono con tutti sensori "interni" oppure un dispositivo a parte?

##### Velocità

La **velocità** viene ottenuta tramite i sensori presenti sul bridge (smartphone) quali:

- GPS
- Accelerometro
- ...

TODO: come fare?


##### Telecamera

TODO: fotocamera telefono?

TODO: foto frequency in base alla velocità

TODO: dataset e modello (yolo)


## Cose da chiedere:

- Comunicazione dei dati? Guard mobili -> guard fissi -> server?
- I dataset?
- altre aggiunte? es. soccorso stradale sui guard fissi



## Risorse

Per capire il traffico e se la strada è bagnata: https://acoustics.org/assessment-of-road-surfaces-using-sound-analysis/

Esempio rudimentale sistema rilevazione buche: https://github.com/anantSinghCross/pothole-detection-system-using-convolution-neural-networks

Photole detection più studiato con dati: https://github.com/tamagusko/pothole-detection 

https://github.com/noorkhokhar99/Pothole-Detection-Pothole-Detection-using-python-and-deep-learning

https://github.com/biodatlab/learnai-potholes-detection