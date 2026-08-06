# Feature-Status

Letzte Aktualisierung: 2026-08-06 · main-Stand: f85c91b (unveraendert; Projektstand auf Branch `claude/wispr-flow-alternative-b5194d`, Commit 50fc4c6) · aktive Worktrees: `.claude/worktrees/wispr-flow-alternative-b5194d`

## Phasen (BAUPLAN Abschnitt 4)

- [x] Phase 0 — Voraussetzungen: Xcode ✓ (aktives Dev-Verzeichnis via `xcode-select` gesetzt), Metal Toolchain ✓ (17F109), cmake ✓ (Homebrew 4.4.2), Ollama ✓ (0.32.5 als brew-Service) + qwen3:4b ✓ (Inferenz-Smoke-Test bestanden 2026-08-06), Gemini-API-Key ✓ (im Onboarding angelegt und verifiziert)
- [x] Phase 1 — Unveraenderter Build laeuft: **BUILD SUCCEEDED** 2026-08-06 (ad-hoc, arm64, App in `~/Downloads/VoiceInk.app`, 71 Upstream-Baseline-Warnings). Meilenstein erreicht 2026-08-06: Onboarding + Berechtigungen + Parakeet V3 + mehrere Test-Diktate, App im Alltagseinsatz
- [x] Phase 2 — Konfiguration (abgeschlossen 2026-08-06): Gemini als Enhancement-Provider ✓ · Modes + Hotkeys ✓ (Fn = Enhancement-Default mit Standard-Prompt, Fn+1 = Dictation/Raw, Fn+2 = Rewrite, Fn+3 = Assistant, Email via App-Trigger; Persoenlich/LinkedIn bewusst weggelassen — Prompts in `docs/PROMPTS.md`) · App in `/Applications` ✓ · Woerterbuch aus Wispr uebernommen ✓ · macOS-Fn-Taste auf „Keine Aktion" ✓ · Ollama als Offline-Provider ✓
- [ ] Phase 3 — Validierung mit Test-Set (15 Aufnahmen, Ergebnisse dokumentiert)

## F1 — Toggle Halten vs. Start/Stopp

Status: offen
DoD: [ ] Settings-Toggle [ ] beide Modi 10× fehlerfrei [ ] Esc-Abbruch [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Upstream bereits vorhanden (`Shortcuts/RecordingShortcutManager.swift`: toggle/pushToTalk/hybrid) — Feature = verifizieren statt bauen

## F2 — Wellenform-Indikator über Dock

Status: offen
DoD: [ ] mittig über Dock [ ] Wellenform reagiert auf Stimme [ ] animiertes Ausblenden [ ] kein Fokus-Diebstahl [ ] externer Monitor ok [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Basis vorhanden: `Views/Recorder/` (MiniRecorderPanel, NotchRecorderPanel, AudioVisualizerView)

## F3 — Fehlschlag-Notifications + Fail-Open

Status: offen
DoD: [ ] Notification bei simuliertem Fehler [ ] Raw-Text wird trotzdem eingefügt [ ] 5 Fehltests ohne Textverlust [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Upstream weitgehend vorhanden (`TranscriptionPipeline.swift`: Notification + Raw-Text bleibt finalText) — Feature = Fehltests fahren, Luecken schliessen

## F4 — History-Retention

Status: offen
DoD: [ ] Einstellung aus/1/7/30/unbegrenzt [ ] Lösch-Job beim Start inkl. Audio [ ] „aus" speichert nichts Neues [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Teilweise vorhanden (`TranscriptionAutoCleanupService`, `transcriptionRetentionMinutes`) — Granularitaet + Audio-Loeschung pruefen

## F5 — Content-Aware: aktives Fenster + Toggle + Hinweis

Status: offen
DoD: [ ] Kontext nur aktives Fenster (Log-Check) [ ] Toggle wirkt sofort [ ] Hinweis sichtbar [ ] Namens-Korrektur-Test besteht [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: `ScreenCaptureService` arbeitet bereits fensterbasiert (FocusedWindowHint) — Toggle + Hinweis pruefen

## F6 — UI-Feinschliff

Status: offen (startet erst, wenn F1–F5 done)
DoD: [ ] subjektiv Wispr-Niveau [ ] alle vorherigen DoDs weiterhin grün [ ] gemergt
Notizen: UX-Feedback Onboarding (2026-08-06, Alexander): Modell-Anbindungen als eine Uebersicht statt sequenzieller Provider-Abfrage (erst Groq-Key-Formular, Skip wirkt wie Funktionsverlust inkl. roter Warnung). Wunsch: alle Anbindungen (STT lokal/Cloud, Enhancement-Provider) auf einer Seite konfigurierbar, Skip neutral formulieren

## Session-Log

- 2026-08-06 (Erst-Session): Setup-Paket eingecheckt (288985e), Workspace-Gitignore ergaenzt, Makefile-Fork-Patch fuer Headless-Build (50fc4c6), Build erfolgreich. Details Build-Voraussetzungen: CLAUDE.md Abschnitt „Build"
