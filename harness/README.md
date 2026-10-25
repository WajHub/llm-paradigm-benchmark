# Harness: ewaluacja benchmarków modelami Claude

Program wysyła zadania benchmarku do modelu, uruchamia wygenerowany kod na testach w Dockerze, przy
porażce odsyła modelowi log do poprawki, ocenia idiomatyczność kodu (sędzia LLM) i składa raport.
Tło i decyzje: [PLAN_EWALUACJI_HAIKU.md](../PLAN_EWALUACJI_HAIKU.md).

## 1. Przygotowanie (raz)

1. `pip install -r harness/requirements.txt`
2. Uruchom Docker Desktop. Obrazy zbudują się same przy pierwszym uruchomieniu.
3. Skopiuj `harness/.env.example` do `harness/.env` i wpisz klucz: `ANTHROPIC_API_KEY=sk-ant-...`.
   `harness/.env` jest w `.gitignore`, więc klucz nie trafi do repo.

Wszystkie polecenia uruchamiamy z katalogu głównego repo.

## 2. Ustawienia: [`harness/config.py`](config.py)

Wszystko konfiguruje się w jednym pliku:

| Stała | Domyślnie | Co robi |
|---|---|---|
| `RUN_ID` | `haiku-v1` | nazwa przebiegu; wyniki trafiają do `results/<RUN_ID>/` |
| `LANGUAGES`, `TESTS` | wszystkie | podzbiór, np. `["C", "Haskell"]`, `[4, 5]` |
| `SAMPLES` | 1 | ile niezależnych prób na zadanie |
| `MAX_REPAIRS` | 3 | ile rund poprawek po nieudanej próbie (0 = jedna próba) |
| `GENERATOR_MODEL`, `GENERATOR_EFFORT` | `claude-haiku-5-5`, `medium` | model, który pisze kod |
| `JUDGE_ENABLED` | `True` | czy po przebiegu uruchomić sędziego idiomatyczności |
| `JUDGE_MODEL`, `JUDGE_EFFORT` | `claude-sonnet-5-5`, `high` | model sędziego |
| `JUDGE_WHICH` | `final` | który kod oceniać: `final`, `first` albo `both` |
| `REPORT_ENABLED` | `True` | czy na końcu zapisać `report.md` |
| `ASK_BEFORE_API_CALLS` | `True` | pytanie o potwierdzenie przed płatnymi wywołaniami |
| `PRICES` | Haiku, Sonnet, Opus 5.x | ceny do raportu i szacunku kosztu |

**Zmiana modelu generującego lub jego ustawień (`GENERATOR_*`, `MAX_REPAIRS`) wymaga nowego
`RUN_ID`.** Istniejący przebieg nie wznowi się z innymi ustawieniami, żeby wyniki się nie mieszały.
Dokładanie języków/testów albo sędziego do przebiegu robi się na tym samym `RUN_ID`: gotowe zadania
są pomijane. Modelu sędziego nie zmieniaj, gdy przebieg ma już oceny (albo usuń wcześniej
`results/<RUN_ID>/judge/`).

Flagi w poleceniu nadpisują config na jedno uruchomienie, np. `--no-judge`, `--model`, `--effort`,
`--samples`, `--langs C,Haskell`, `--tests 4`. Pełna lista: `python harness/run.py --help`.

## 3. Uruchamianie

| Polecenie | API (koszt) | Co robi |
|---|---|---|
| `python harness/run.py --dry-run` | nie | zapisuje wszystkie prompty do `.work/dry-run/` do przejrzenia |
| `python harness/run.py --baseline` | nie | sprawdza ewaluator: stuby muszą oblać testy, rozwiązania referencyjne przejść |
| `python harness/run.py --langs C,Haskell --tests 4` | tak, grosze | pilot na 2 zadaniach |
| `python harness/run.py` | tak | pełny przebieg: generowanie → sędzia → raport |
| `python harness/judge.py --calibrate` | tak, ~$1 | sprawdza, czy sędzia ocenia stabilnie (ten sam kod dwa razy) |
| `python harness/judge.py` | tak | tylko sędzia, dla już wygenerowanego przebiegu |
| `python harness/report.py` | nie | tylko raport z istniejących wyników |

Przed płatnymi wywołaniami program pokazuje maksymalną liczbę zapytań i szacunek kosztu, i pyta
`[y/N]`. Przerwany przebieg wznawia się tym samym poleceniem: ukończone zadania są pomijane i nie
kosztują drugi raz.

Zalecana kolejność: dry-run → baseline → pilot → `judge.py --calibrate` → pełny przebieg.

## 4. Wyniki: `results/<RUN_ID>/`

| Plik | Zawartość |
|---|---|
| `report.md` | raport: wyniki język × test, paradygmaty, samonaprawa, idiomatyczność, koszt |
| `summary.csv` | jeden wiersz na zadanie, do arkusza/pandas |
| `attempts.jsonl`, `judge.jsonl` | surowe dane: każda próba i każda ocena sędziego |
| `config.json`, `baseline.json` | ustawienia przebiegu i wynik sprawdzenia ewaluatora |
| `<Język>/test-N/sample-1/attempt-K/` | `prompt.md`, `response.json`, `solution.*`, `eval.log` każdej próby |

## 5. Pliki programu

| Plik | Rola |
|---|---|
| `config.py` | ustawienia |
| `run.py` | główny program (dry-run, baseline, przebieg + sędzia + raport) |
| `judge.py`, `rubrics.md` | sędzia idiomatyczności i jego rubryka |
| `report.py` | raport |
| `tasks.py`, `prompts.py`, `llm.py`, `evaluator.py`, `store.py` | zadania, prompty, API, Docker, zapis wyników |
