# CLAUDE.md — Voice-to-Text-App (VoiceInk-Fork)

## Projektziel
Persönliche Wispr-Flow-Alternative für macOS (Apple Silicon), schneller und für Alexanders Anwendungsfall präziser als Wispr Flow. Verbindliche Referenz: `docs/BAUPLAN.md` · Projektstand: `docs/FEATURES.md`

## Fixe Entscheidungen (nicht ohne Rücksprache ändern)
- STT lokal: Parakeet TDT 0.6B v3 via FluidAudio (Default) · Whisper large-v3-turbo als Zweit-Engine, hart auf Deutsch fixiert (Flüstern/Lärm)
- LLM-Cleanup: Gemini 3.1 Flash-Lite (Cloud-Default) · Ollama + Qwen3 4B auf localhost:11434 (Offline-Backup) · Provider und Modell-IDs immer als konfigurierbare Settings, nie hartcodiert
- Hotkeys: Fn = Aufnahme (Halten oder Start/Stopp je nach Einstellung) · Esc = Abbruch
- Raw-Modus: Enhancement per Toggle überspringbar, Transkript direkt an den Cursor
- Content-Aware: Kontext nur aus dem aktiven Fenster, Toggle in den Einstellungen + Hinweis auf sensible Daten
- Fail-Open: Bei STT-/Enhancement-Fehler Notification anzeigen UND Raw-Text trotzdem einfügen — nie Textverlust
- History: raw + verarbeitet · Speicherdauer aus / 1 / 7 / 30 Tage / unbegrenzt

## Arbeitsregeln
- `main` ist immer baufähig; Arbeit nur in `feature/`-Branches bzw. Worktrees (BAUPLAN 8.2)
- Pro Session genau ein Feature; Scope-Grenzen der Feature-Matrix einhalten (BAUPLAN 8.3)
- Kein Merge ohne vollständig erfüllte Definition of Done
- Letzter Schritt jeder Session: `docs/FEATURES.md` aktualisieren (Status, DoD-Haken, Notizen, betroffene Dateien)
- Upstream (Beingpax/VoiceInk) nur gezielt mergen, nie reflexartig

## Kontext
- Zielhardware: MacBook Pro M1, macOS 14.4+
- Latenz-Ziele: BAUPLAN Abschnitt 3 · App-weite Definition of Done: BAUPLAN Abschnitt 7
