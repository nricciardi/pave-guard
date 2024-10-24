Riempi le sezioni vuote con ciò che hai trovato (anche solo degli spunti), quando abbiamo un'idea abbastanza matura la integriamo poi nella documentazione e nella relativa directory.

> [!IMPORTANT]
> Teniamo aggiornata la documentazione man mano, così è più semplice creare la presentazione finale.


# Sensori static guard

TODO

## Microfono

~~Per valutare l'acquisto:~~

La serie [Max****](https://www.amazon.it/AZDelivery-Max9814-Amplificatore-Microfono-compatibile/dp/B086W79GPG/ref=pd_bxgy_d_sccl_1/259-3081792-9538652?pd_rd_w=uQRoi&content-id=amzn1.sym.1dc7d97b-1a1c-458c-b144-e0e060559c6e&pf_rd_p=1dc7d97b-1a1c-458c-b144-e0e060559c6e&pf_rd_r=QS5ZDNE302C3S15YZ6G4&pd_rd_wg=8hx1s&pd_rd_r=85144c58-3992-4cec-83d1-32e8c562ce95&pd_rd_i=B086W79GPG&th=1) sono sensori più precisi (dovrebbero essere registratori a tutti gli effetti), hanno il regolatore automatico del guadagno ecc

[KY-037](https://www.amazon.it/AZDelivery-KY-037-Mikrofon-Modul-Parent/dp/B089QHGFTS?th=1) sono rilevatori di suoni (non proprio microfoni).

Dice Chat:

> KY-037 è più semplice e meno preciso rispetto al MAX9814, ma è utile per rilevare la presenza di suoni

> Max**** è comunemente usato in progetti di registrazione audio, analisi del parlato o rilevamento del livello sonoro in ambienti complessi.


TODO: capire se vogliamo approssimare il livello di traffico come il tempo in cui un tratto di strada è sopra la baseline oppure con un modello che capisce quando passa una macchina o camion


Per il codice: 
[Detecting high and low sound](https://www.circuitbasics.com/how-to-use-microphones-on-the-arduino/)


## Meteo

### Sensore di pioggia

~~Per l'acquisto:
[Sensore di pioggia e umidità](https://www.amazon.com/HiLetgo-Moisture-Humidity-Sensitivity-Nickeled/dp/B01DK29K28/ref=sr_1_3?dib=eyJ2IjoiMSJ9.W0zET8tH2yC3sMV5rPnocEFE77pi8HWfKiElvB9EU6J-Tz86BAbAo92TYWsNGQEWb0cXIbRN6sfJC9ece9UniSgQygyi1suexYdujA5Y0DUDJ9k5AfUjEnTRujcVTJYLPPi2GvKHLWbIpsk0P_XxhbhRxThuX7KcYBhYcMKwQw7HbAxtmo3A9G-KM3zPY4ZnEjF7bGsu2UFbgoC_iO22BbZFo7Y1SuPhjxC7ynOdXAQ.TNXbgymT2VCH9qdlqttv5XGsiiNnofjH3i_1KDuvMh8&dib_tag=se&keywords=rain+sensor+arduino&qid=1729622095&sr=8-3)~~

^^^ Mi pare che sia un sensore solo per il rilevamento di acqua sulla sua superficie, quindi ci dice "piove si/no" *=guarda EDIT

Chat consiglia l'unione di:

- Sensore temperatura
- Sensore di luce LDR (Light Dependent Resistor) => per sapere _quanto_ solo c'è (potrebbe essere utile (?))
- **Pluviometro (Rain Gauge)**: Se hai bisogno di misurare la quantità di pioggia accumulata, un pluviometro è essenziale. Il sensore funziona raccogliendo l'acqua in un piccolo contenitore e misura la quantità d'acqua che passa attraverso un canale. Vantaggi: ci dice quanta pioggia c'è, non solo c'è/non c'è
- Sensore umidità (da capire se opzionale visto il sensore sopra)

Non ci sono molti pluviometri su Internet mi pare... ho trovato questo:

[Pluviometro per poveri](https://www.amazon.it/MISOL-Ricambio-stazione-misurare-pluviometro/dp/B00QDMBXUA/ref=sr_1_1?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=W94OZ3KXICA9&dib=eyJ2IjoiMSJ9.Yh3USjJaLUyeJtsadYPF2hciwfMz-t8x-xCjKoUjcNxywqD7YwNcb5l1mpTyAogvbdjyP7L0wx6odAQfv-VyzNy2FVdAxInl6_Idj7pctgsMZgITZ2Qy9eBtIZQRkf8pZW6SMz7JT4a3E4hDY0p0a93ThiiEiKgV0hkwA3w-pLnVzbNgcaheC-0zNob8FX1wj-wBR0oyhM6C35wGkVJGMSXcVYNezm4ZZV9Qo__rd_GY7FPvb2swUQHL4aNRB8hbltJheLdIC_Qg_yKOCDsqf_GNA_FR1m4GEW_q_ZwFOig.0D8HeD3MNAzNTrWJ-zoe5rfHqUgcDZq2Zf8ovECkEl0&dib_tag=se&keywords=rain+gauge+arduino&qid=1729695752&sprefix=rain+gauge+arduino%2Caps%2C111&sr=8-1)

Come usarlo non lo so, c'è un cavo, bisogna indagare.

Per il codice:
[How does a rain sensor work?](https://circuitdigest.com/microcontroller-projects/interfacing-rain-sensor-with-arduino)


EDIT: se utilizzato in orizzontale è come ho scritto sopra*, se utilizzato in verticale all'interno di un contenitore (non come nel video del tutorial *How does a rain sensor work?*) allora misura il livello di acqua... campionando ad intervalli regolari si riesce a capire quanto piove... **problema**: il contenitore deve potersi svuotare una volta raggiunta una certa soglia, ossia il pluviometro. Cuculo ha detto che alla brutta lo si può "fare in casa" (ho i miei dubbi che esca una cosa decente) tramite uno di quei servomotori per aprire il fondo... bah

# Sensori dynamic guard

TODO

## Fotocamera

_Quella del cellulare?_

> Se usiamo quella del cellulare ci tocca comprare il coso con la ventosa per tenere il telefono fisso in posizione verso la strada.
> A questo punto forse conviene comprare una fotocamera esterna, almeno fa più scena, no?

[Fascia poveri](https://www.amazon.it/Hailege-OV7670-640x480-Fotocamera-Arduino/dp/B08D7DFK18/ref=sr_1_1?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=DTJZR6KVWHU2&dib=eyJ2IjoiMSJ9.nZbJHBCkzb4kcg7OX79i9DFDTbAzvj3L5NDptwBTzb0mdu3lqAnY-rnznEAtoALen-_7f48ejsU52OYGW5cctBEgnoUxX3EhNj48C3A3hHjoclUu1sNfwhwhQ9LURf7BEN5ve5ZSsu9NGqwdFbvLVo9HWat8OAC7udGHFdgCZy-TIXUovMc7qXGukyFfLSgUIaEJ77q1DLFFpr_M-F4mLlAhGCDNcJN1fPtfo3d6OM0m_kjia28RIk9zcC5s3krT_pwyF76h6fFc1PuqvHpG91Sg7vxFbuG9O6k9D5dt60s.orwjAJ3cTxj2cfwuFv9rNGAkxSS44ObjBnDNC9OaQ0c&dib_tag=se&keywords=modulo+fotocamera+1080x720+arduino&qid=1729697735&sprefix=modulo+fotocamera+1080x720+arduino%2Caps%2C89&sr=8-1)

[Fascia media](https://www.amazon.it/Videocamera-Obiettivo-Grandangolare-Interfaccia-W202012HD/dp/B08MQ43RF8/ref=sr_1_7?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=DTJZR6KVWHU2&dib=eyJ2IjoiMSJ9.nZbJHBCkzb4kcg7OX79i9DFDTbAzvj3L5NDptwBTzb0mdu3lqAnY-rnznEAtoALen-_7f48ejsU52OYGW5cctBEgnoUxX3EhNj48C3A3hHjoclUu1sNfwhwhQ9LURf7BEN5ve5ZSsu9NGqwdFbvLVo9HWat8OAC7udGHFdgCZy-TIXUovMc7qXGukyFfLSgUIaEJ77q1DLFFpr_M-F4mLlAhGCDNcJN1fPtfo3d6OM0m_kjia28RIk9zcC5s3krT_pwyF76h6fFc1PuqvHpG91Sg7vxFbuG9O6k9D5dt60s.orwjAJ3cTxj2cfwuFv9rNGAkxSS44ObjBnDNC9OaQ0c&dib_tag=se&keywords=modulo+fotocamera+1080x720+arduino&qid=1729697658&sprefix=modulo+fotocamera+1080x720+arduino%2Caps%2C89&sr=8-7)

[Alta risoluzione + gran angolo (costa di più ma forse fa più al caso nostro)](https://www.amazon.it/Fotocamera-HBV-1609-Obiettivo-Grandangolare-Milioni/dp/B0CKCTZYPB/ref=sr_1_28?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=DTJZR6KVWHU2&dib=eyJ2IjoiMSJ9.nZbJHBCkzb4kcg7OX79i9DFDTbAzvj3L5NDptwBTzb0mdu3lqAnY-rnznEAtoALen-_7f48ejsU52OYGW5cctBEgnoUxX3EhNj48C3A3hHjoclUu1sNfwhwhQ9LURf7BEN5ve5ZSsu9NGqwdFbvLVo9HWat8OAC7udGHFdgCZy-TIXUovMc7qXGukyFfLSgUIaEJ77q1DLFFpr_M-F4mLlAhGCDNcJN1fPtfo3d6OM0m_kjia28RIk9zcC5s3krT_pwyF76h6fFc1PuqvHpG91Sg7vxFbuG9O6k9D5dt60s.orwjAJ3cTxj2cfwuFv9rNGAkxSS44ObjBnDNC9OaQ0c&dib_tag=se&keywords=modulo+fotocamera+1080x720+arduino&qid=1729697407&sprefix=modulo+fotocamera+1080x720+arduino%2Caps%2C89&sr=8-28)

## Accelerometro

Per l'acquisto:
[Modulo giroscopio accelerometro a 3 assi](https://www.amazon.it/ARCELI-giroscopio-accelerometro-Accelerometer-Convertitore/dp/B07BVXN2GP/ref=sr_1_6?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=HSB2TIUYBKUF&dib=eyJ2IjoiMSJ9.RwQWIpYBctj3EU1OAr1KIGbetcU3a9flZoat59Mnw7A2TGTKYay11gy3pDtIVU5iefRais2Ye3kHpapjMLvPlkrcFoVyAnQIZSt0N50uLd0zA5wR6LwHBSd-9IaXvY8JOh672Y-MWxeuIkf65dol4BEgt1FNBw3tvXNRA3llmo6-JDtodDVhx6pAyI1E3ZPjMRzeTEzyB2ANAjMrKFfKS3P_qGDGDQHoi6wY-g8QGPMzJ0dVZ__gLioQjhcZaCt5xfsz7t6Jz8RLntvx52yUsY0X2c1lCeSdu-6M65MOpiI.WYizvD0Y5dAxm6mDaGkYok785JK6MR-9ng7LanQdi3Y&dib_tag=se&keywords=accelerometro&qid=1729622275&sprefix=accelerometro%2Caps%2C243&sr=8-6)

Per il codice:
[Tutorial](https://randomnerdtutorials.com/esp32-mpu-6050-accelerometer-gyroscope-arduino/)

## GPS 

Quello del cellulare? O esterno?

Per l'acquisto esterno:
[Modulo di controllo di volo](https://www.amazon.it/ICQUANZX-GY-NEO6MV2-Controller-ceramica-resistente/dp/B088LR3488/ref=sr_1_5?__mk_it_IT=%C3%85M%C3%85%C5%BD%C3%95%C3%91&crid=26W66PVOSH95N&dib=eyJ2IjoiMSJ9.FVqH72Lcm5HmctctPIJMbl_TA34N9G7Pl5vxoLe35uapWNhT0xCFXODz9fWMLzNsA5t4SlHzQwhUpahsZGn82hW51_46LDdjf8IPkZseukxjGPO6PwPIzgPaim1i08a0XH8_VHgjwFB-FOBcwCi-DEtxoNaDYwW1YGBqf1MBVv_f24qgM8jtk45RAQzhV1Pinx6Fb4LJyT3Y6qlPpG9YSTLGdfEjEPDSGMvgJk7s7RyWeZ59MBJ0NncS_80DV_y0gfTp2jwbxX9UmRTfM-Ohz6gtEfmtQiunLca8bwzkKZE.p2nDB0CpeUz1pOpMgzFQsfG6pOl2hQChrQxUeQmCiWk&dib_tag=se&keywords=gps+arduino&qid=1729622354&sprefix=gps+arduinp%2Caps%2C247&sr=8-5)

Per il codice:
[Guide to GPS Module Arduino](https://randomnerdtutorials.com/guide-to-neo-6m-gps-module-with-arduino/)
(P.S.: Qui parla di una libreria TinyGPS++ per il parsing dei suoi output.)


# Bridge static guard

TODO


# Applicazione/bridge dynamic guard

TODO




