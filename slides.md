---
marp: true
theme: default
paginate: true
size: 16:9
title: Valutazione delle Capacità di Ragionamento dei Large Language Model
description: Discussione tesi magistrale
style: |
  section {
    font-family: "Aptos", "Helvetica", "Arial", sans-serif;
    padding: 40px 56px;
    background: #ffffff;
    color: #1f2937;
  }
  h1 {
    color: #0f172a;
    font-size: 1.9em;
    margin-bottom: 0.25em;
  }
  h2 {
    color: #0f172a;
    font-size: 1.45em;
    margin-bottom: 0.3em;
  }
  h3 {
    color: #334155;
    margin-bottom: 0.2em;
  }
  p, li {
    font-size: 0.95em;
    line-height: 1.35;
  }
  small {
    color: #475569;
  }
  .two-cols {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 28px;
    align-items: center;
  }
  .three-cols {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 20px;
    align-items: start;
  }
  .center {
    text-align: center;
  }
  .big {
    font-size: 1.2em;
  }
  .metric {
    background: #f8fafc;
    border-left: 6px solid #2563eb;
    padding: 14px 16px;
    border-radius: 10px;
  }
  .highlight {
    background: #eff6ff;
    border: 1px solid #bfdbfe;
    border-radius: 12px;
    padding: 14px 18px;
  }
  .warn {
    background: #fff7ed;
    border: 1px solid #fdba74;
    border-radius: 12px;
    padding: 14px 18px;
  }
  .success {
    background: #ecfdf5;
    border: 1px solid #86efac;
    border-radius: 12px;
    padding: 14px 18px;
  }
  img {
    max-width: 100%;
    max-height: 72vh;
    display: block;
    margin: 0 auto;
  }
  table {
    font-size: 0.82em;
  }
  th {
    background: #e2e8f0;
  }
  code {
    font-size: 0.9em;
  }
---

# Valutazione delle Capacità di Ragionamento dei Large Language Model

## la risoluzione di labirinti

**Leonardo Randacio**  
Corso di Laurea Magistrale in Ingegneria e Scienze Informatiche  
Relatore: **Prof. Matteo Ferrara**

<br>

**Idea chiave:** valutare ragionamento e pianificazione dei LLM in un compito **sequenziale**, **parzialmente osservabile** e **verificabile automaticamente**.

---

# Il problema in una slide

<div class="two-cols">
<div>

## Task

- Il modello è posto in una cella del labirinto
- Riceve solo una **descrizione locale testuale**
- Deve scegliere una mossa tra  
  **North / East / South / West**
- Vince solo se raggiunge e **attraversa l’uscita**

<br>

<div class="highlight">

### Perché è interessante?

- azioni discrete
- successo oggettivo
- memoria necessaria
- pianificazione multi-step

</div>

</div>
<div>

![width:520px](./images/lattice_example.png)

<small>Esempio di labirinto reticolare quadrato</small>

</div>
</div>

---

# Perché questo benchmark?

<div class="three-cols">
<div class="metric">

### 1. Verificabile

Ogni risposta viene trasformata in un’azione e controllata automaticamente.

</div>

<div class="metric">

### 2. Non basta “parlare bene”

Un output ben scritto può comunque essere:

- illegale
- incoerente
- strategicamente fallimentare

</div>

<div class="metric">

### 3. Misura memoria e pianificazione

Con osservazione locale il modello deve:

- ricordare
- evitare cicli
- fare backtracking

</div>
</div>

<br>

<div class="center big">

**Obiettivo della tesi:** separare la **conformità dell’output** dalla vera **capacità di navigazione**

</div>

---

# Come sono generati i labirinti

<div class="two-cols">
<div>

## Generazione

- griglia inizialmente chiusa
- apertura dei corridoi con **DFS randomizzata**
- uscita unica sul bordo

<br>

## Proprietà utili

- labirinti **sempre risolvibili**
- molti **vicoli ciechi**
- percorso soluzione **unico**
- struttura adatta a valutare esplorazione e memoria

</div>
<div>

![width:620px](./images/selection_example.png)

<small>Selezione delle istanze: scarto dei casi troppo facili</small>

</div>
</div>

---

# Osservazione parziale: profondità di vista

<div class="two-cols">
<div>

## Setup

Il modello **non** vede la mappa globale.

Vede solo:

- muri
- corridoi
- diramazioni laterali
- eventuale uscita osservabile
- eventuali celle colorate

entro una profondità di vista **d**.

<br>

<div class="warn">

Più **d** è piccolo, più il problema dipende da:

- memoria delle osservazioni
- coerenza temporale
- strategia di esplorazione

</div>

</div>
<div>

![width:620px](./images/sight_depth.png)

<small>Esempio con differenti valori di profondità di vista</small>

</div>
</div>

---

# Celle colorate come ancore percettive

<div class="two-cols">
<div>

## Idea

Alcune celle hanno un colore univoco.

Questo permette al modello, in principio, di:

- riconoscere posizioni già visitate
- ridurre cicli
- migliorare orientamento locale

<br>

## Vincolo

- massimo **8** colori
- ogni colore compare **al più una volta**

</div>
<div>

![width:620px](./images/colored_example.png)

<small>Le celle colorate introducono riferimenti spaziali univoci</small>

</div>
</div>

---

# Dal labirinto al prompt testuale

<div class="two-cols">
<div>

## Prompt = 2 parti

### 1. Preambolo

- obiettivo
- dimensione griglia
- profondità di vista
- vincoli di output

### 2. Descrizione del passo

- osservazione locale corrente
- eventuale ultima mossa
- eventuali mosse legali
- eventuale storico mosse

<br>

## Scelta importante

Tutto è espresso in **linguaggio naturale**, non in JSON.

</div>
<div>

![width:620px](./images/prompt_example.png)

<small>Esempio di prompt generato a partire dallo stato del labirinto</small>

</div>
</div>

---

# Output vincolato e parsing automatico

<div class="two-cols">
<div>

## Vincolo

L’ultima parte della risposta deve contenere una direzione valida:

- `north / east / south / west`
- oppure `n / e / s / w`

<br>

## Parsing

- si cercano i token direzionali
- si prende **l’ultima occorrenza**
- si normalizza a una delle 4 azioni

<br>

<div class="highlight">

Questo permette di distinguere:

- **risposta illegale** → nessuna azione estraibile
- **azione illegale** → azione estraibile ma contro un muro

</div>

</div>
<div>

| Output del modello                              | Azione estratta |
| ----------------------------------------------- | --------------- |
| I want to move East!                            | east            |
| I should move NORTH!                            | north           |
| My next move is: s                              | south           |
| Let's move north, before exploring west better. | west            |

<br>

![width:520px](./images/prompt_step_example.png)

</div>
</div>

---

# Varianti di prompting valutate

## Flag principali

- **HIST**: storia conversazionale attiva
- **SYS**: preambolo come system prompt
- **OF**: suggerimento sul formato di output
- **SA**: spatial awareness
- **AR**: anti-repetition
- **DE**: evitare vicoli ciechi
- **MS**: riassunto mosse
- **LM**: mosse ammissibili esplicitate
- **RR**: reminder di ragionamento
- **COL**: colori inclusi nel prompt

<br>

<div class="center big">

La tesi confronta **modelli diversi** e **configurazioni diverse** dello stesso task

</div>

---

# Metriche di valutazione

<div class="three-cols">
<div class="metric">

### Risposte illegali

Il modello non produce un output parsabile in una direzione.

</div>

<div class="metric">

### Direzioni illegali

La direzione è parsabile, ma punta contro un muro.

</div>

<div class="metric">

### Successo sul task

Il modello raggiunge e attraversa l’uscita entro  
\(T\_{\max} = 10n^2\)

</div>
</div>

<br>

<div class="three-cols">
<div class="success">

### Passi medi sui successi

Misurano l’efficienza **condizionata** al successo.

</div>

<div class="warn">

### Lettura importante

Conformità dell’output e capacità di navigazione  
**non coincidono**.

</div>

<div class="highlight">

### Fallimenti distinti

- interfaccia
- reattivi
- strategici

</div>
</div>

---

# Risultati 3×3: il quadro generale

| ID      | Modello             | Configurazione                             | % resp illegali | % dir illegali |  Risolti |
| ------- | ------------------- | ------------------------------------------ | --------------: | -------------: | -------: |
| E1      | llama3              | HIST                                       |            0.11 |          12.91 |      60% |
| E5      | deepseek-r1         | SYS, HIST                                  |            0.00 |       **1.21** |      70% |
| E6      | mistral             | SYS, HIST                                  |            0.00 |          33.33 |      70% |
| E10     | deepseek-r1:32b     | SYS, HIST, OF, AR, c=4                     |            0.11 |           8.76 |      80% |
| **E11** | **deepseek-r1:70b** | **SYS, HIST, OF, SA, AR, DE, MS, RR, c=4** |        **0.00** |           2.34 | **100%** |

<br>

<div class="success center big">

Su labirinti **3×3**, la configurazione migliore arriva a **10/10 episodi risolti**

</div>

---

# Insight chiave dai risultati 3×3

<div class="three-cols">
<div class="metric">

### 1. La sola conformità non basta

Alcuni modelli hanno quasi zero risposte illegali, ma successo ancora basso.

</div>

<div class="metric">

### 2. La scala del modello conta

Le varianti più grandi della famiglia **DeepSeek-R1** sono nettamente migliori.

</div>

<div class="metric">

### 3. Il prompting aiuta

Output format, anti-ripetizione, awareness e memory cues migliorano il comportamento.

</div>
</div>

<br>

<div class="warn center big">

**Morale:** un modello può rispettare bene l’interfaccia e fallire comunque nella strategia di navigazione

</div>

---

# Effetto della scala del labirinto

| Dimensione | Miglior configurazione osservata     | % risolti |
| ---------- | ------------------------------------ | --------: |
| **3×3**    | deepseek-r1:70b + prompt completo    |  **100%** |
| **4×4**    | deepseek-r1:32b + SYS,HIST,OF,AR,c=4 |   **50%** |
| **5×5**    | deepseek-r1 + HIST                   |    **0%** |
| **6×6**    | deepseek-r1 + HIST                   |   **10%** |

<br>

## Messaggio principale

All’aumentare di \(n\), il task richiede sempre più:

- memoria affidabile
- prevenzione dei cicli
- backtracking coerente
- pianificazione su orizzonti lunghi

---

# Andamento complessivo: dove emerge il limite

<div class="two-cols">
<div>

## Osservazione

Su istanze piccole i modelli migliori mostrano buone capacità locali.

## Ma...

Appena il labirinto cresce:

- aumentano esplorazioni ridondanti
- aumenta la difficoltà nel mantenere uno stato coerente
- il successo cala rapidamente

<br>

<div class="highlight">

Il collo di bottiglia non sembra essere solo “capire il testo”, ma **gestire memoria e pianificazione multi-step**.

</div>

</div>
<div>

| Dimensione | Esito                     |
| ---------- | ------------------------- |
| 3×3        | task spesso risolvibile   |
| 4×4        | prestazioni già instabili |
| 5×5        | collasso quasi completo   |
| 6×6        | successi sporadici        |

<br>

<div class="center big">

**Da ragionamento locale**  
a  
**ragionamento spaziale persistente**

</div>

</div>
</div>

---

# Due traiettorie qualitative

![width:1100px](./images/maze_exp_example.png)

<small>Da sinistra a destra: un episodio risolto e un episodio fallito. In arancione il percorso del modello.</small>

---

# Lettura qualitativa degli errori

<div class="three-cols">
<div class="metric">

### Fallimenti di interfaccia

Il modello non termina con una direzione valida.

</div>

<div class="metric">

### Fallimenti reattivi

Il modello propone mosse illegali nonostante i muri siano esplicitati.

</div>

<div class="metric">

### Fallimenti strategici

Il modello gira in cicli, esplora male o non gestisce il backtracking.

</div>
</div>

<br>

<div class="center big">

La parte più difficile non è “dire una direzione”,  
ma **costruire una strategia coerente nel tempo**

</div>

---

# Conclusioni

<div class="three-cols">
<div class="success">

### Contributo

Benchmark semplice, controllato e verificabile per testare ragionamento sequenziale dei LLM.

</div>

<div class="warn">

### Risultato centrale

Buona performance su casi piccoli **non** implica pianificazione robusta su casi più complessi.

</div>

<div class="highlight">

### Messaggio finale

La navigazione in labirinti con osservazione locale evidenzia limiti attuali di:

- memoria
- coerenza temporale
- pianificazione

</div>
</div>

<br>

## Sviluppi futuri

- confronto con modelli proprietari
- più set di istanze
- varianti con strumenti o memoria esterna
- benchmark più ampi ma sempre verificabili

---

# Grazie per l’attenzione

## Domande?

<br>

**Tesi:** _Valutazione delle Capacità di Ragionamento dei Large Language Model: la Risoluzione di Labirinti_
