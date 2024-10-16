# PaveGuard

Sistema distribuito per il monitoraggio delle strade urbane.


## Rete di dispositivi

PaveGuard si compone di due differenti tipologie di dispositivi fisici:

- **Guard fissi** [TBD]
- **Guard mobili** [TBD]

I **guard fissi** sono dispositivi montati su lampioni o pali per monitorare le *condizioni ambientali* 
(es. meteo) e il *livello di traffico* di un breve tratto di strada.

I **guard mobili** sono dispositivi installati su auto che muovendosi nell'ambiente urbano catturano informazioni sulle 
reali condizioni stradali grazie a 3 parametri:

- Velocità
- Vibrazione (per individuare tratti stradali a pelle di coccodrillo)
- Videocamera (per individuare tratti stradali con buche evidenti)


L'unione dei dati dei guard mobili, dei guard fissi e meteo dei giorni/mesi successivi su un tratto di strada forniscono i dati per fare **previsioni** su eventuali futuri interventi da effettuare per il rifacimento del tratto stradale o eventuale manutenzione predittiva.



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