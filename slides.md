---
marp: true
theme: gaia
paginate: true
size: 16:9
title: Valutazione delle Capacità di Ragionamento dei Large Language Model
description: Discussione tesi magistrale
---

<!-- _class: lead -->

# Valutazione delle Capacità di Ragionamento dei Large Language Model:

## la risoluzione di labirinti

**Leonardo Randacio**

---

<!-- _class: lead -->

#### Capacità LLM in un compito:

- **sequenziale**
- **parzialmente osservabile**
- **verificabile automaticamente**

---

## Task

- Il modello è posto in una cella del labirinto
- Riceve solo una **descrizione locale testuale**
- Deve scegliere una mossa tra:
  **North / East / South / West**
- Vince solo se raggiunge e **attraversa l’uscita**

---

### Motivazioni

- azioni discrete
- successo oggettivo
- memoria necessaria
- pianificazione multi-step

---

# Generazione dei labirinti

- algoritmo DFS
- partenza e uscita scelti casualmente
- filtraggio labirinti 'facili':

$$
	S(L) \;\ge\; \operatorname{round}\!\left(\alpha n^2\right),
	\qquad \alpha = 0.5
$$

---

<!-- _class: lead -->

![width:400px](./assets/selection_example.png)

---

# Generazione dei labirinti

- sempre risolvibili
- persenza di vicoli ciechi
- unico percorso ideale

---

<!-- _class: lead -->

### Profondità di vista

![width:300px](./assets/sight_depth.png)

---

<!-- _class: lead -->

# Celle Colorate

![width:320px](./assets/colored_example.png)

Le celle colorate introducono riferimenti spaziali univoci

---

# Generazione del prompt

- Deterministico
- Linguaggio naturale (inglese)
- Preambolo/Step

---

# Informazioni nel preambolo

- Descrizione del task
- Dimensione del labirinto e profondità di vista
- Consigli strategici
- Invito a 'riflettere'

---

# Informazioni nello step prompt

- Ultima mossa eseguita
- Direzioni laterali
- Celle colorate
- Ultime mosse svolte
- Mosse disponibili

---

# Parsing dell'output

| Output del modello                                  | Azione estratta |
| --------------------------------------------------- | --------------- |
| I want to move **East**!                            | east            |
| I should move **NORTH**!                            | north           |
| My next move is: **s**                              | south           |
| Let's move north, before exploring **west** better. | west            |

---

# Risultati 3×3

| Modello             | % resp illegali | % dir illegali |   # passi | Risolti   |
| ------------------- | --------------: | -------------: | --------: | --------- |
| llama3:8b           |            0.11 |          12.91 |     17.33 | 6/10      |
| mistral:7b          |            0.00 |          33.33 |     36.86 | 7/10      |
| deepseek-r1:8b      |            0.00 |       **1.21** |     17.29 | 7/10      |
| deepseek-r1:32b     |            0.11 |           8.76 | **12.25** | 8/10      |
| **deepseek-r1:70b** |        **0.00** |           2.34 |     14.90 | **10/10** |

---

<!-- _class: lead -->

# Esempi di risoluzioni

![width:900px](./assets/maze_exp_example.png)

---

# Risultati nxn

| Dimensione | Miglior configurazione osservata | % risolti |
| ---------- | -------------------------------- | --------: |
| **3×3**    | deepseek-r1:70b                  |  **100%** |
| **4×4**    | deepseek-r1:32b                  |   **50%** |
| **5×5**    | deepseek-r1                      |    **0%** |
| **6×6**    | deepseek-r1                      |   **10%** |

---

# Osservazioni

| Dimensione | Esito                     |
| ---------- | ------------------------- |
| 3×3        | task spesso risolvibile   |
| 4×4        | prestazioni già instabili |
| 5×5-6x6    | collasso quasi completo   |

---

# Osservazioni

- Buoni risultati su labirinti 3x3
- Rilevanza dimensione del modello
- Limiti:
  - memoria
  - pianificazione
  - comprensione spaziale

---

# Contributo

Benchmark:

- semplice
- controllato
- verificabile

---

## Sviluppi futuri

- confronto con modelli proprietari
- più set di istanze
- varianti con strumenti o memoria esterna
- benchmark più ampi ma sempre verificabili

---

<!-- _class: lead -->

## Ringraziamenti

---

<!-- _class: lead -->

# Grazie per l’attenzione
