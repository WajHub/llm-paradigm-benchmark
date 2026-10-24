# Plan: ewaluacja benchmarków modelem Claude Haiku przez API

> Status: plan zaakceptowany (2026-10-24). Implementacja (katalog `harness/`) jeszcze nie rozpoczęta,
> następny krok to punkt 1 z sekcji „Kroki realizacji”.

## Kontekst

Repo ma 6 zadań benchmarkowych (`test-1` … `test-6`) w 7 językach i 4 paradygmatach.
Każde zadanie ma 20 testów: 10 dla algorytmu A i 10 dla B. Do tego są szablony promptów
(`<Lang>/README.md` + `test-N.md`) i środowiska testowe w Dockerze. Brakuje automatu,
który wyśle prompty do modelu, wstawi kod w miejsce stuba, uruchomi testy, w razie
porażki odeśle logi do poprawki i zbierze wyniki. Celem jest pierwszy rzetelny pomiar
Haiku na wszystkich 42 zadaniach: poprawność, zdolność do samonaprawy i idiomatyczność
per paradygmat.

## Podjęte decyzje

| Kwestia | Decyzja |
|---|---|
| Model | `claude-haiku-5-5` (Haiku 5.5, $0.10 / $0.50 za 1M tokenów), thinking adaptive, `effort: "medium"` ustawione jawnie. `temperature` nie da się ustawić (API zwraca 400) |
| Protokół | one-shot + **maks. 3 rundy naprawcze** (prompt follow-up z README), rozmowa wieloturowa (append-only) |
| Widoczność testów | testy **ukryte**; w poprawce model dostaje **nazwy oblanych testów + log** (kompilator / valgrind / wyjście testów) |
| Powtórzenia | **1 próba** na parę (język, test); harness od razu obsługuje `--samples N` |
| Metryki | poprawność + metryki automatyczne + **LLM-as-judge idiomatyczności** (`claude-opus-5-5`) |
| Infrastruktura | Python 3.12 + SDK `anthropic`; testy w istniejących obrazach Docker (lokalnie nie ma toolchainów, Docker jest) |
| Wyniki | `results/<run_id>/` commitowane (małe pliki tekstowe, odtwarzalność); katalog roboczy `.work/` w `.gitignore` |

## Ustalenia z przeglądu repo

Poniższe problemy znalezione podczas przeglądu zostały **już naprawione w repo** (przed implementacją harnessu):

1. ✔ **CRLF**: przy `core.autocrlf=true` pliki w working tree miały CRLF. Dodany `.gitattributes`
   (`* text=auto eol=lf`) wymusza LF. Harness i tak zapisuje kopie w `.work/` z LF (na wypadek starych klonów).
2. ✔ **test-1 miał gotowe rozwiązania**: w C, Java, Pascal i Smalltalk zamiast stubów leżały pełne implementacje.
   Teraz są tam stuby jak w test-2…6. Pascal/test-1 ma układ jednego unitu, a `spatial_logic_impl.pas` został usunięty.
   - Runnery testów w Java/test-1 i Pascal/test-1 nie łapały wyjątków (stub lub błąd modelu kładł cały przebieg).
     Teraz wyjątek oznacza FAIL jednego testu.
   - Stare implementacje są w historii gita (commit `a9f0372`), np. `git show a9f0372:C/test-1/spatial_logic.c`.
     Zweryfikowane w Dockerze: **C i Pascal 20/20** (czysty valgrind), więc nadają się do walidacji ewaluatora (krok 3).
     **Java 15/20 i Smalltalk 18/20** (tak samo z oryginalnymi testami), więc nie są wzorcem poprawności.
3. ✔ **Commitnięte artefakty kompilacji** (`test_runner`, `.ppu`): usunięte, `test_runner` dopisany do `.gitignore`.
4. ✔ **Różne nazwy testów**: starsze testy w Haskell/Scala (t1–3, t5) i Prolog (t1) wypisywały
   `test_algo_a_01_...`, a Smalltalk/t1 miał `Nil` zamiast `Null`. Teraz wszystkie 7 języków ma identyczne nazwy
   `Test A01 (Title)` w każdym teście. Parser może więc brać ID z `Test ([AB]\d{2})`.
5. ✔ **C/test-5 A06 różnił się od pozostałych języków** (`NULL` zamiast `"1 +"`). Teraz to ten sam test
   (`Dangling Operator`) we wszystkich językach.
6. ✔ **Szablony promptów miały elementy z test-1**: na sztywno wpisany plik w prompcie naprawczym, `free_polygon`
   w C, klasa `Point` i `SpatialLogic.st` w Smalltalku. Teraz prompt naprawczy ma placeholder **`[TARGET FILE NAME]`**,
   który harness podmienia na plik docelowy.
7. ✔ **Prolog nigdy nie mógł zaliczyć zadania**: pod valgrindem wątek GC SWI-Prologa się wywracał (exit 139),
   a `--leak-check=full` liczył jako błędy wycieki samego interpretera przy `halt`. `Prolog/run-tests.sh` używa teraz
   `valgrind --error-exitcode=1 swipl --no-threads …` (bez `--leak-check`): 0 błędów, a exit code zależy tylko od testów.
8. ✔ **Obraz Smalltalka przestał się budować**: Debian 11 jest po końcu wsparcia, a mirror `bullseye-security`
   zwraca 404. `gnu-smalltalk` nie ma w nowszych Debianach, więc Dockerfile instaluje pakiety z głównego archiwum bullseye.
   Gdy bullseye zniknie z `deb.debian.org`, trzeba będzie przejść na `snapshot.debian.org`/`archive.debian.org`.
9. ℹ **Testy zaliczane na stubie**: np. C/test-1 ma 6/20 PASS na stubie (oczekiwane `NULL`/`false`).
   Harness zapisuje to w `baseline.json`, a raport musi to uwzględnić.
10. ⚠ **Nadal aktualne** (cecha projektu, nie błąd): w językach jednoplikowych (Haskell, Scala, Prolog, Pascal)
   model zwraca **cały moduł z typami**, więc może „zepsuć” kontrakt. To uczciwa porażka (kompilacja),
   ale warto ją pamiętać przy interpretacji.

## Architektura: katalog `harness/`

```
harness/
├── requirements.txt     # anthropic
├── tasks.py             # wykrywanie 42 zadań + manifest: pliki kontraktu, plik docelowy
├── prompts.py           # parsowanie szablonów z <Lang>/README.md i test-N.md, renderowanie promptów
├── llm.py               # wywołania Haiku (streaming), wyciąganie kodu, zapis usage
├── evaluator.py         # przygotowanie .work/, docker run z timeoutem, parser wyniku, kategorie
├── run.py               # CLI: orkiestracja, pętla naprawcza, równoległość, wznawianie
├── judge.py             # LLM-as-judge idiomatyczności (structured outputs)
├── rubrics.md           # rubryka: kryteria wspólne + checklisty per paradygmat/język
└── report.py            # agregacja → report.md + summary.csv
```

### `tasks.py`: manifest zadania
Reguły per język (wzorowane na `.claude/skills/new-benchmark/references/languages.md`):

| Język | Kontrakt w prompcie | Plik docelowy (nadpisywany) |
|---|---|---|
| C | `<snake>.h` | `<snake>.c` (jedyny `.c` poza `tests.c`) |
| Java | `<Pascal>.java` | `<Pascal>Impl.java` |
| Smalltalk | `<Pascal>.st` | `<Pascal>Impl.st` |
| Haskell / Scala / Prolog / Pascal | moduł (kontrakt + stuby) | ten sam plik |

Wszystkie 42 zadania mają jednolity układ, więc nadpisania per zadanie nie są potrzebne.

### `prompts.py`
- Bierze pierwszy blok ``` z sekcji „### Initial prompt” i z „### Follow-up prompt” w `<Lang>/README.md`
  oraz blok ``` z `test-N.md`.
- Initial: `[TASK-SPECIFIC REQUIREMENTS]` → treść `test-N.md`; `[INSERT …]` → zawartość kontraktu.
- Follow-up: `[ERROR LOGS…]` → wycinek logu; `[FAILING TEST CASE…]` → lista nazw oblanych testów;
  `[TARGET FILE NAME]` → plik docelowy.
- Walidacja: po renderowaniu w tekście nie może zostać żaden `[INSERT`, `[ERROR`, `[FAILING`, `[TASK`, `[TARGET`.

### `llm.py`
```python
client.messages.stream(
    model="claude-haiku-5-5",
    max_tokens=32000,                      # thinking wlicza się do max_tokens
    thinking={"type": "adaptive"},
    output_config={"effort": "medium"},
    messages=history,                      # append-only: [user, assistant(response.content), user, ...]
).get_final_message()
```
- Bez `temperature` i bez prefill (oba dają 400 na Haiku 5.5).
- Do historii trafia całe `response.content` razem z blokami thinking, nie sam tekst.
- Kod = konkatenacja bloków `type == "text"`. Jeśli model mimo zakazu użył ```, wyciągamy największy
  blok i ustawiamy flagę `format_violation` (to też metryka: trzymanie się instrukcji).
- `stop_reason == "max_tokens"` → kategoria `truncated`, `"refusal"` → `refusal`.
- Zapisujemy `usage` (input/output/cache tokens) i czas.
- Retry na 429/5xx robi SDK (`max_retries`).

### `evaluator.py`
- Na starcie budujemy obrazy jednorazowo: `docker build -t llmbench-<lang> <Lang>/`.
- Dla każdej próby tworzymy `.work/<run>/<Lang>-test-N-sK-aJ/` z kopiami `Makefile`, `run-tests.sh`
  i `test-N/`. Pomijamy artefakty (`*.o *.ppu *.hi *.class test_runner`, ta sama lista co w `verify.sh`),
  normalizujemy LF i wpisujemy kod modelu do pliku docelowego.
- Uruchomienie:
  `docker run --rm --name llmb-<id> -v <workdir>:/app -w /app --entrypoint sh llmbench-<lang> run-tests.sh test-N`
  przez `subprocess.run(timeout=…)`. Domyślnie 300 s, a przy przekroczeniu `docker kill llmb-<id>`.
  To ta sama logika co w `verify.sh`, plus timeout i brak `--build` przy każdym uruchomieniu.
- **Kategorie wyniku** (heurystyka na wyjściu i exit code):

| Kategoria | Warunek |
|---|---|
| `pass` | exit 0 i 20× `[PASS]` |
| `test_failures` | są `[FAIL]` (lub brakujące wiersze testów) |
| `memory_error` | 20× `[PASS]`, ale exit ≠ 0 (valgrind w C/Pascal/Haskell/Prolog) |
| `compile_error` | brak `=== START ===` |
| `runtime_crash` | jest `START`, brak `=== BENCHMARK RESULTS ===` |
| `timeout` / `truncated` / `refusal` / `empty_output` | jak w nazwie |

- **Wycinek logu do poprawki** (maks. ~6k znaków):
  - `compile_error`: początek wyjścia kompilatora.
  - `test_failures`: wiersze `[FAIL]` i komunikaty wyjątków.
  - `memory_error`: sekcja valgrinda (`Invalid read/write`, `definitely lost`, `ERROR SUMMARY`).
  - `timeout`: informacja o przekroczeniu czasu.

### `run.py`: CLI
```
python harness/run.py --run-id haiku-v1 [--langs C,Haskell] [--tests 4,5] \
    [--samples 1] [--max-repairs 3] [--workers 4] [--model claude-haiku-5-5] [--effort medium]
python harness/run.py --dry-run      # renderuje 42 prompty do results/<run>/…/prompt.md, bez API i Dockera
python harness/run.py --baseline     # ewaluacja stubów + implementacji test-1 z historii gita, bez API
```
- Pętla na jednym zadaniu: attempt-0 (initial) → ewaluacja → jeśli nie `pass` i zostały rundy,
  to follow-up → … (maks. attempt-3).
- `ThreadPoolExecutor(workers)`: zadania idą równolegle, rundy w zadaniu po kolei.
- **Wznawianie**: zadanie z istniejącym `final.json` jest pomijane, więc po przerwaniu nie płacimy drugi raz.
- `config.json` zapisuje model, effort, max_repairs, hash commita repo i datę.

### Układ wyników
```
results/<run_id>/
├── config.json
├── baseline.json                    # wyniki stubów / implementacji referencyjnych test-1
├── attempts.jsonl                   # 1 wiersz = 1 próba (płaskie, pod pandas/Excel)
├── judge.jsonl
├── report.md, summary.csv
└── <Lang>/test-N/sample-1/
    ├── attempt-0/ prompt.md, response.json, solution.<ext>, eval.log, eval.json
    ├── attempt-1/ …
    └── final.json                   # status końcowy, rundy do sukcesu, suma tokenów
```

### `judge.py`: LLM-as-judge idiomatyczności
- Model `claude-opus-5-5`, `output_config={"effort": "high", "format": {"type": "json_schema", "schema": …}}`.
  Zgodnie z zaleceniami dla Opus 5.5 włączamy server-side fallback (`fallbacks: "default"`).
- Ocenia **kod z ostatniej próby** każdego zadania, o ile się kompiluje. Flaga `--which first|final|both`
  pozwoli później sprawdzić, czy poprawki psują idiomatyczność.
- **Ślepa ocena**: sędzia widzi `test-N.md`, kontrakt, kod i nazwę języka. Nie widzi wyniku
  testów ani informacji, który model napisał kod.
- Schemat odpowiedzi: oceny 1–5 dla `paradigm_idiomaticity`, `language_idiomaticity`, `readability`,
  `design`, do tego `anti_patterns: [str]` i krótkie `justification`.
- `rubrics.md` zawiera checklisty per paradygmat, np.:
  - Haskell: czystość, ADT, pattern matching, brak funkcji częściowych.
  - Prolog: styl relacyjny, nadużywanie `!`/`assert`.
  - C/Pascal: własność pamięci i zwalnianie.
  - Java/Smalltalk: dekompozycja obiektowa, protokoły kolekcji (`collect:`/`inject:into:`).
  - Scala: niemutowalność, `Option`.
- **Kalibracja** przed pełnym przebiegiem: oceniamy implementacje test-1 z historii gita (`a9f0372`) i 3 rozwiązania
  Haiku, każde dwukrotnie (stabilność ±1). Kilka ocen sprawdzamy ręcznie.

### `report.py` → `report.md` + `summary.csv`
1. Macierz język × test: testy zaliczone w attempt-0 oraz finalnie, np. `14/20 → 20/20 (2 rundy)`.
2. Agregacja per paradygmat (imperatywny, obiektowy, funkcyjny, logiczny) oraz algorytm A vs B.
3. Rozkład kategorii porażek per język (kompilacja, testy, pamięć, timeout…).
4. Samonaprawa: % zadań naprawionych, średnia liczba rund do sukcesu.
5. Idiomatyczność: średnie ocen per język i paradygmat, najczęstsze antywzorce.
6. Tokeny i koszt per język, flagi `format_violation`.
7. Adnotacja o testach, które przechodzą już na stubie (z `baseline.json`), żeby nie zawyżały wyników.

## Kroki realizacji (z punktami kontrolnymi)

0. ~~Zapis planu w roocie jako `PLAN_EWALUACJI_HAIKU.md`.~~ ✔
1. **Setup**: `pip install -r harness/requirements.txt`, ustawienie `ANTHROPIC_API_KEY`
   (poza repo), dopisanie `.work/` do `.gitignore`.
2. **`tasks.py` + `prompts.py` + `--dry-run`**. ✔ Kontrola: powstają 42 prompty, nie zostaje żaden
   placeholder. Przeglądamy po 1 prompcie z każdego języka.
3. **`evaluator.py` + `--baseline`** (bez API). ✔ Kontrola:
   - każdy obraz się buduje;
   - na każdym stubie parser widzi 20 wyników, a exit = 1;
   - implementacje test-1 z historii gita (`git show a9f0372:<plik>`) dają 20/20 dla C i Pascala
     (Java 15/20 i Smalltalk 18/20 to znany stan tych rozwiązań).

   Tu wychodzą ewentualne błędne testy, zanim wydamy cokolwiek na API.
4. **`llm.py` + `run.py`, pilot**: `--langs C,Haskell --tests 4`. ✔ Kontrola: ręczny przegląd
   transkryptów (czy kod jest czysty, czy follow-up ma sensowny log, czy wznawianie działa).
5. **Pełny przebieg**: 42 zadania × 1 próba × maks. 4 rundy, `--workers 4`.
6. **`judge.py` + `rubrics.md`**: najpierw kalibracja, potem wszystkie zadania.
7. **`report.py`**: `report.md`, przegląd w zespole i commit `results/haiku-v1/`.

## Szacunek kosztu i czasu

- Haiku: maks. 168 wywołań (42 × 4). Nawet przy ~10k tokenów wejścia i ~10k wyjścia na wywołanie
  to ≈ 1,7M + 1,7M tokenów, czyli **≈ $1**.
- Sędzia (Opus 5.5, $4 / $20): 42 × (~6k wejścia + ~2k wyjścia) ≈ **$3**.
- Docker: 42–168 ewaluacji po 15–60 s (najwolniejsze to kompilacja Scali/Haskella i valgrind),
  przy 4 workerach ≈ **20–45 min**.
- Batch API (−50%) nie ma tu sensu: koszt jest pomijalny, a pętla naprawcza potrzebuje szybkich odpowiedzi.

## Weryfikacja end-to-end

- `python harness/run.py --dry-run`: 42 prompty, zero placeholderów.
- `python harness/run.py --baseline`: stuby dają exit 1 i 20 sparsowanych wyników, implementacje test-1 dla C i Pascala dają 20/20.
- Pilot (krok 4): `results/<run>/C/test-4/sample-1/` zawiera komplet plików prób, a ponowne uruchomienie tej samej
  komendy niczego nie powtarza (wznawianie).
- Kontrola krzyżowa: dla 2–3 prób ręcznie podmieniamy plik w kopii i uruchamiamy
  `sh .claude/skills/new-benchmark/scripts/verify.sh . <Lang> test-N <work> <dir_z_solution>`. Wynik musi się
  zgadzać z `eval.json`.
- `report.md`: sumy w macierzy zgadzają się z `attempts.jsonl`.

## Ograniczenia i faza 2

- 1 próba daje wyniki zaszumione, więc traktujemy ten przebieg jako pilot. Następny krok to `--samples 3–5` i pass@k.
- Sędzia z tej samej rodziny modeli co oceniany (Claude ocenia Claude) może być stronniczy, dlatego ręczne spot-checki.
- Możliwe rozszerzenia (harness ma flagi `--model`/`--effort`): porównanie z Sonnet/Opus, sweep effort,
  ablacja „testy widoczne od początku”, wykresy.
