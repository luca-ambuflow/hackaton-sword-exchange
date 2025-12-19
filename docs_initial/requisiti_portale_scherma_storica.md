# Requisiti Portale Scherma Storica (Italia → Europa → mondo)

## 1) Visione e obiettivi
- Ecosistema frammentato (molte realtà piccole, poco coordinamento).
- Obiettivo: portale “centro nevralgico” per:
  1) **Anagrafica** di associazioni/scuole/società  
  2) **Calendario eventi** unico, facile da popolare velocemente  
  3) **Programma Erasmus** (allenamenti ospitati con garanzie minime su tessera/certificato)
- Il prodotto deve **autoalimentarsi**: più eventi → più traffico → più incentivo a caricare eventi.
- Priorità: **frizione minima** nell’inserimento eventi (niente approvazione preventiva).

---

## 2) Perimetro, internazionalizzazione e SEO

### 2.1 Scalabilità geografica
- Si parte dall’Italia ma il sistema deve essere pronto per **Europa** e potenzialmente **America**.

### 2.2 Multi-lingua
- **i18n obbligatorio**: supporto a molte lingue fin da subito (anche se inizialmente ne userete 1–2).

### 2.3 SEO (requisito forte)
- “Super ottimizzazione SEO”:
  - pagine eventi e pagine società indicizzabili e facili da trovare per ricerche su “eventi scherma storica”.
  - architettura URL e contenuti pensati per SEO.

---

## 3) Utenti, ruoli e permessi

### 3.1 Ruoli
- **Visitatore** (non loggato): consulta anagrafica e calendario (tutto pubblico).
- **Utente registrato (persona)**:
  - può **creare eventi**
  - può richiedere affiliazione a una società (stato “non verificato” finché non approvato)
  - può usare funzioni “social” (es. cuoricino) se le attivate
  - può partecipare a Erasmus **solo se verificato e in regola**
- **Gestore società (admin ente)**:
  - gestisce profilo ente, eventi (come chiunque registrato), e soprattutto:
  - gestisce **Erasmus Program** della società e gli slot
  - gestisce **affiliazioni utenti** (approva/rigetta) + attesta tessera/certificato
  - gestisce amministratori della società
- **Admin piattaforma**:
  - può **cancellare/rimuovere** eventi rapidamente
  - può moderare contenuti e gestire abusi
  - validazione gestori società rimane **manual review**

### 3.2 Registrazione e stati utente
- Utente persona può registrarsi subito come “persona”.
- Stato utente rispetto a una società:
  - **Non verificato** (default)
  - **Verificato** (dopo approvazione società e attestazioni)
  - **Sospeso/non in regola** (tessera o certificato scaduti → blocco Erasmus)

### 3.3 Società: gestione e validazione gestori
- Un utente può richiedere di essere gestore di una società o crearne una.
- Il gestore diventa tale solo dopo **manual review admin** (unico modo).
- Le società possono essere anche “seedate” nel DB direttamente da voi.

---

## 4) Modulo Anagrafica Società (Directory)

### 4.1 Dati minimi società (obbligatori/opzionali)
**Obbligatori**
- Ragione sociale
- Codice fiscale
- Sede
- Almeno 1 account amministratore collegato

**Opzionali**
- Partita IVA
- Contatti
- Sito web

**Da valutare (tendenza a non complicarsi)**
- Discipline praticate: forse campo libero, o rimando al sito
- Orari/giorni: tendenza a **non gestirli** (difficili da tenere aggiornati)

### 4.2 UI directory
- **MVP**: elenco + filtri
- **Bonus**: mappa (non ora)
- **Coordinate**: **non gestite** in MVP (coerente col fatto che non avete mappa)

---

## 5) Modulo Calendario Eventi Globale

### 5.1 Event creation (decisione finale)
- **Chiunque sia registrato può creare eventi**:
  - gestori società
  - utenti persona registrati
- Non c’è approvazione preventiva: serve velocità per creare valore.

### 5.2 Moderazione e rimozione eventi (admin)
- Gli admin devono poter **cancellare rapidamente** eventi:
  - idealmente direttamente dalla vista calendario con un pulsante “cancella”
  - con conferma forte (es. reinserire il titolo o conferma esplicita)
- Se esiste un sistema notifiche, inviare al creatore evento un messaggio tipo:
  - “Evento rimosso per questo motivo: …”
  - (requisito “desiderato”, dipende dal modulo notifiche)

### 5.3 Dati evento: MVP (minimo indispensabile)
Obiettivo: “ti dico che c’è l’evento” → poi vai sul link e decidi.

**Campi MVP**
- Titolo
- Tipo evento (enum fissata da voi)
- Data/ora
- Luogo
- Organizzatore (società, se applicabile / o autore evento)
- Descrizione breve
- Link esterno all’evento (fonte dettagli)

**Fuori MVP (almeno inizialmente)**
- costo
- regolamenti
- capienza evento
- iscrizioni evento / lista partecipanti (no)

### 5.4 Tassonomia “tipo evento”
- Lista **fissata** (non campo libero).
- Lista attuale dichiarata: **gare**, **sparring**, **seminari**.

### 5.5 Filtri calendario (MVP + desiderata)
- Regione + provincia: **sì**
- Organizzato da (società): **sì**
- Filtro distanza in km: **idealmente sì**
- Disciplina/arma:
  - in generale era “difficile”
  - ma per le competizioni “sì, proviamo a gestirla”
  - lista non super definita → va progettata con attenzione

---

## 6) Modulo “Erasmus” (feature principale)

### 6.1 Concetto e pagina dedicata
- Pagina Erasmus con spiegazione accattivante.

### 6.2 Erasmus Program a livello società (config unico)
- Gli slot Erasmus di una società condividono impostazioni comuni definite **una volta** a livello “Programma Erasmus” della società:
  - “cosa aspettarti” (descrizione)
  - regole generali
  - eventuale requisito certificato (agonistico/non agonistico)
  - modalità conferma prenotazioni (auto o manuale)

**Multi-sede**: non supportato in MVP.
- Quindi: una sola sede implicita per il programma Erasmus della società.

### 6.3 Slot Erasmus (entità)
- Ogni slot è caratterizzato da:
  - data
  - ora inizio
  - ora fine
- Generazione massiva da ricorrenza + gestione puntuale:
  - es. “tutti i giovedì 19–21 dal 1 settembre 2025 a giugno 2026”
  - poi rimozione singole date (vacanze)
  - possibilità di aggiungere altri giorni/orari (incrementale)
  - modificabile nel tempo

### 6.4 Conferma ospitante (preferenza società)
- La società decide nelle preferenze:
  - **autoconferma** oppure **conferma manuale**
- In caso di rifiuto:
  - inviare un **motivo testuale** (preferibilmente sì)

### 6.5 Capienza (MVP)
- **Capienza generale** per la società (non per slot).
- Quando pieno:
  - lo slot risulta pieno
  - l’utente può lasciare “vorrei venire lo stesso”
  - la società gestisce manualmente contatto/deroghe
  - può anche rifiutare esplicitamente (così l’utente lo sa)

---

## 7) Verifica “burocratica” (tessera, EPS, certificato) e privacy

### 7.1 Modello scelto (A): attestazione da società
- L’utente sceglie una società di appartenenza.
- La società **approva** l’affiliazione e inserisce/attesta:
  - EPS (dropdown con autocomplete + opzione “Altro”)
  - numero tessera
  - data validità tessera (le tessere hanno scadenza)
  - certificato medico-sportivo:
    - tipo: agonistico / non agonistico
    - scadenza
- Non si caricano documenti/scansioni.

### 7.2 Multi-affiliazione
- Decisione finale: **si parte con affiliazione singola** (niente multi-affiliazione in MVP).

### 7.3 Audit e responsabilità
- Tracciare **chi** (quale gestore) ha attestato tessera/certificato e **quando**: **sì**.
- Dichiarazione legale:
  - checkbox con testo “legalese” in cui la società dichiara che i dati sono veritieri.
  - Obiettivo: “solidità” per rivalersi su chi fornisce dati falsi.

### 7.4 Stati e blocchi
- Se scade tessera o certificato:
  - l’utente **non può partecipare a Erasmus** finché non viene riabilitato dalla società
- L’utente può chiedere cambio società:
  - parte una nuova richiesta all’altra società
  - finché non approvata rimane non verificato / limitato

### 7.5 Visibilità dati
- Dati tessera/certificato visibili a:
  - utente (privato)
  - società di appartenenza
  - società ospitante **solo quando c’è una prenotazione**
- Mai in profilo pubblico.

### 7.6 Consensi
- Consenso privacy: **ovvio**
- Termini Erasmus separati: **sì, desiderati** (da scrivere/validare)

---

## 8) Incentivi e gamification (MVP vs bonus)

### 8.1 Incentivi “core”
- **SEO fortissimo** (requisito core).
- Inserimento eventi velocissimo, con:
  - duplicazione evento / “copia evento precedente”
  - template

### 8.2 Incentivi per società (accettati / scartati)
- Export ICS/feed calendario: “pochi lo sanno usare” ma **potrebbe starci** (opzionale).
- Widget embeddabile “prossimi eventi” sui siti società: **NO** (per ora).
- Analytics semplici: **NO** (troppa complessità/valore basso per amatori).
- Form “contatta la società” passando da voi: **NO** (non passa da voi).

### 8.3 Incentivi per persone
- Preferiti / sync calendario personale: valore percepito basso.
- Alert salvati (notifiche): **bonus point** (da decidere).
- “Erasmus badge/pass” (badge con logo società visitate ultimo anno + livello per quanto gira): **bonus point**.
- Feedback/recensioni ospitalità Erasmus: “carino ma delicato” → **bonus point**.

---

## 9) Timezone (requisito tecnico-funzionale)
- Gestire timezone **assolutamente sì**.
- Regola desiderata:
  - chi inserisce evento/slot lo inserisce nella sua timezone locale (assunta come locale di inserimento)
  - chi visualizza dall’estero vede l’orario convertito nella **sua** timezone di navigazione/utente

---

# Punti in tensione / criticità
1) **Filtro distanza in km** vs **niente coordinate**  
   - Vuoi filtro km, ma non vuoi coordinate e non hai mappa.  
   - Con solo “provincia/regione/indirizzo testo” il filtro km è poco affidabile.

2) **Discipline/armi**: vuoi provarci ma “non c’è una lista super definita”.  
   - Serve tassonomia minima, altrimenti i filtri diventano incoerenti.

---

# Domande aperte (ultime)

## A) Distanza in km (bloccante per il filtro)
1) Per fare il filtro km, accetti di:
   - A) aggiungere **CAP + comune** obbligatori e usare geocoding (anche senza mostrare mappa), oppure
   - B) rinviare il filtro km a “bonus”, lasciando regione/provincia come MVP, oppure
   - C) salvare coordinate **solo internamente** (non esposte) per calcolo distanza?

## B) Luogo evento (minimo standard)
2) Qual è lo standard minimo per il luogo evento?
   - solo città + provincia?
   - indirizzo completo?
   - sede di una società selezionabile (se l’organizzatore è una società)?

## C) Eventi creati da utenti (moderazione)
3) Gli utenti registrati che creano eventi devono:
   - selezionare una società organizzatrice (se l’evento è “di società”), oppure
   - possono creare eventi “indipendenti” con solo autore?
4) Vuoi un pulsante “segnala evento” per aiutare moderazione spam?

## D) Tipi evento e discipline
5) Confermi che i soli tipi evento iniziali sono esattamente:
   - gare / sparring / seminari
   oppure vuoi aggiungere “workshop” separato da “seminari”?
6) Disciplina/arma: vuoi una lista vostra (enum) con “Altro”, oppure tag liberi controllati?

## E) Notifiche (minimo)
7) Se non fate notifiche subito: quando admin cancella un evento, ti basta loggare il motivo senza inviarlo, oppure vuoi comunque inviare un’email “transazionale” minima?

## F) Feedback Erasmus (bonus delicato)
8) Se introduci feedback ospitalità Erasmus:
   - solo rating numerico?
   - rating + commento testuale?
   - visibile a tutti o solo alle società coinvolte?
