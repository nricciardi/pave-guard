# SLIDE

1. PROBLEMA
2. STATISCHE per problema
3. Com'era prima E PERCHè NON FUNZIONA
4. PAVEGUARD - mission
5. Panoramica di come funziona
6. Vantaggi - Automatizzato, costi (p&p), persone felici
7. Piani futuri
   
1. Schema a blocchi globale
2. Static Guard: Temperatura, umidità, pioggia, traffico, a chi manda come
3. Dynamic Guard: Vibrazioni, GPS, foto, connessione col bridge (gestione dati, computer vision, invio telemetrie)
4. Server: Gestione utenti, raccolta telemetrie, store predizioni, gestione devices e gestione planning
5. Dashboard: Visualizzazione predizioni, gestione planning, visione storico
6. Modello: Genera predizioni, in base ai dati sul Server

7. Server: mongoDB, graphQL (PERCHè HTTP e non MQTT)
8. Static Guard: SENSORI (ogni quanto misurano e come si manda (se vuoi)), MICROCONTROLLORE, protocollo comunicazione Server
9. Dynamic Guard: SENSORI (come misurano, codifica dati), MICROCONTROLLORE, come comunica, FLUTTER (multi-piattaforma)
10. Bridge Dynamic: YOLO (come acquisisce), come acquisisce dati dal Microcontrollore, come li manda (HTTP)
11. Dashboard: Flutter (perchè estensibile e multi-piattaforma), le sezioni, che dati prendono e come visualizzano
12. Container: deploy docker


Live Demo: mentre vengono presentate le slide mostriamo il relativo dispositivo/componente

Static guard: matrice led + fotocelllule per transiti + rain gauge
Dynamic guard: Aggiungere nel bridge se viene rilevata una buca e crack (mettere immagine sul pc per mostrare che le rileva?)
Dashboard: storico + planning + predizioni