# Bridge for Dynamic Guard

## Setup

For Linux: [Start building Flutter Android apps on Linux](https://docs.flutter.dev/get-started/install/linux/android)
For Windows: [Start building Flutter Android apps on Windows](https://docs.flutter.dev/get-started/install/windows/mobile)

Flutter docs: [Flutter docs](https://docs.flutter.dev/get-started/fundamentals)

## App

L'app che funge da bridge per il Dynamic Guard si compone di diverse componenti. Le sue funzionalità principali sono:

1. Permettere agli utenti di effettuare il login al servizio;
2. Effettuare una connessione al dispositivo Dynamic Guard;
3. Raccogliere i dati dal dispositivo ed elaborarli;
4. Inviare i dati già aggregati al servizio.

### Views

Le views - ossia, le schermate - sono principalmente:
1. **Login**: permette agli utenti di effettuare il login o il sign-up;
2. **Dashboard**: la schermata principale;
3. **Settings**: dove gestire le impostazioni;
4. **Profile**: dove visualizzare le informazioni dell'utente loggato.

#### Login

[Docs](https://pub.dev/packages/flutter_login)

La schermata di login permette di svolgere due funzionalità.

##### Sign-up

Dove un utente può registrarsi. In una prima schermata viene chiesto di inserire la propria mail e la propria password, confermandola. Nel caso in cui la mail non sia già stata usata, l'utente può procedere ad inserire il proprio nome, cognome e codice fiscale.

##### Login

L'utente può effettuare il login nell'applicazione, fornendo la mail e la password usati al tempo di sign-up. Per un certo periodo, i dati vengono mantenuti in memoria affinchè l'utente possa rientrare senza inserire ancora i propri dati.

#### Dashboard

Nella dashboard, l'utente può vedere due informazioni principali: lo stato di connessione ai sensori e la detrazione delle tasse fino a quel momento. Se vi è un errore nella connessione ai sensori così come scelti nelle impostazioni, questo viene mostrato.

#### Settings

Nei settings si può scegliere quale fotocamera utilizzare (quella built-in del dispositivo o quella del Dynamic Guard) e quale GPS utilizzare (quello built-in del dispositivo o quello del Dynamic Guard). Le impostazioni vengono salvate nel dispositivo e rimangono tali fino a una nuova modifica dell'utente.

#### Profile

Mostra i dati dell'utente loggato.
