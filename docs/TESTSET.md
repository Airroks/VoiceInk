# Phase-3-Validierung: Test-Set

Ziel: Datenbasiert entscheiden, welche Konfiguration fuer Alexander gewinnt (BAUPLAN Abschnitt 4, Phase 3). Vor jeder groesseren Konfigurations- oder Feature-Aenderung wiederholbar.

## 1. Aufnahmen (je 3 pro Szenario, echte Alltags-Formulierungen)

| #   | Szenario            | Hinweise                                                             |
| --- | ------------------- | -------------------------------------------------------------------- |
| S1  | Hochdeutsch sauber  | Normale Diktier-Situation am Schreibtisch                            |
| S2  | Anglizismen-Mix     | Tool-Namen, Denglisch („das Feature deployen", „im Call besprochen") |
| S3  | Selbstkorrekturen   | Bewusst korrigieren („am Freitag — nein, warte — am Montag")         |
| S4  | Umgebungsgeraeusche | Coworking/Strasse/Musik im Hintergrund                               |
| S5  | Fluestern           | Leise Situation (Zug, Meeting-Umgebung)                              |

Empfehlung: Mit Voice Memos aufnehmen und die Dateien behalten — dann laesst sich jede Aufnahme reproduzierbar durch mehrere Konfigurationen jagen (VoiceInk → Transcribe nimmt Audio-Dateien an), statt jedes Szenario mehrfach einzusprechen.

## 2. Konfigurationen

| Kuerzel        | STT                                          | Enhancement     |
| -------------- | -------------------------------------------- | --------------- |
| K1 (Default)   | Parakeet V3                                  | Gemini (Cloud)  |
| K2 (Offline)   | Parakeet V3                                  | Ollama qwen3:4b |
| K3 (nur S4/S5) | Whisper large-v3-turbo, Sprache fest Deutsch | Gemini          |

Ablauf pro Aufnahme: Datei in Transcribe ziehen → Ergebnis notieren → Enhancement-Provider in den Settings umstellen → erneut transkribieren.

## 3. Bewertung

Skala Cleanup-Qualitaet: 1 = unbrauchbar · 3 = okay, manuelle Korrektur noetig · 5 = direkt versendbar.

### K1 — Parakeet + Gemini

| Aufnahme | Wortfehler (Raw) | Cleanup 1-5 | Latenz (s, gefuehlt/Stoppuhr) | Inhalt verfaelscht? |
| -------- | ---------------- | ----------- | ----------------------------- | ------------------- |
| S1-a     |                  |             |                               |                     |
| S1-b     |                  |             |                               |                     |
| S1-c     |                  |             |                               |                     |
| S2-a     |                  |             |                               |                     |
| S2-b     |                  |             |                               |                     |
| S2-c     |                  |             |                               |                     |
| S3-a     |                  |             |                               |                     |
| S3-b     |                  |             |                               |                     |
| S3-c     |                  |             |                               |                     |
| S4-a     |                  |             |                               |                     |
| S4-b     |                  |             |                               |                     |
| S4-c     |                  |             |                               |                     |
| S5-a     |                  |             |                               |                     |
| S5-b     |                  |             |                               |                     |
| S5-c     |                  |             |                               |                     |

### K2 — Parakeet + qwen3:4b (identische Tabelle)

| Aufnahme    | Wortfehler (Raw) | Cleanup 1-5 | Latenz (s) | Inhalt verfaelscht? |
| ----------- | ---------------- | ----------- | ---------- | ------------------- |
| S1-a … S5-c |                  |             |            |                     |

### K3 — Whisper (nur S4/S5)

| Aufnahme    | Wortfehler (Raw) | Cleanup 1-5 | Latenz (s) | Inhalt verfaelscht? |
| ----------- | ---------------- | ----------- | ---------- | ------------------- |
| S4-a … S5-c |                  |             |            |                     |

## 4. Entscheidungen ableiten

- [ ] Ist der Qualitaetsabstand K1 vs. K2 akzeptabel? (Wie oft ist Offline gut genug?)
- [ ] Bleibt Parakeet beim Anglizismen-Mix stabil, oder kippt mitten im Satz die Sprache? (Falls ja → Whisper mit fixiertem Deutsch als Default erwaegen)
- [ ] Ist Fluestern akzeptabel — und hilft Whisper (K3) messbar?
- [ ] Danach: macOS-Mikrofonmodus „Stimmisolation" aktivieren, S4-Tests wiederholen, Delta notieren

## Ergebnis-Log

| Datum | Konfiguration Sieger | Notizen |
| ----- | -------------------- | ------- |
|       |                      |         |
