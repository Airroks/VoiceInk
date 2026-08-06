# Feature-Status
Letzte Aktualisierung: 2026-08-05 · main-Stand: — (noch kein Build) · aktive Worktrees: keine

## Phasen (BAUPLAN Abschnitt 4)
- [ ] Phase 0 — Voraussetzungen (Xcode, Ollama + qwen3:4b, Gemini-API-Key)
- [ ] Phase 1 — Unveränderter Build läuft stabil (Meilenstein: Diktat → Text am Cursor, lokal)
- [ ] Phase 2 — Konfiguration (Provider, 3 Enhancement Modes, Wörterbuch, Fn/Esc)
- [ ] Phase 3 — Validierung mit Test-Set (15 Aufnahmen, Ergebnisse dokumentiert)

## F1 — Toggle Halten vs. Start/Stopp
Status: offen
DoD: [ ] Settings-Toggle  [ ] beide Modi 10× fehlerfrei  [ ] Esc-Abbruch  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: —

## F2 — Wellenform-Indikator über Dock
Status: offen
DoD: [ ] mittig über Dock  [ ] Wellenform reagiert auf Stimme  [ ] animiertes Ausblenden  [ ] kein Fokus-Diebstahl  [ ] externer Monitor ok  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: —

## F3 — Fehlschlag-Notifications + Fail-Open
Status: offen
DoD: [ ] Notification bei simuliertem Fehler  [ ] Raw-Text wird trotzdem eingefügt  [ ] 5 Fehltests ohne Textverlust  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: —

## F4 — History-Retention
Status: offen
DoD: [ ] Einstellung aus/1/7/30/unbegrenzt  [ ] Lösch-Job beim Start inkl. Audio  [ ] „aus" speichert nichts Neues  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: —

## F5 — Content-Aware: aktives Fenster + Toggle + Hinweis
Status: offen
DoD: [ ] Kontext nur aktives Fenster (Log-Check)  [ ] Toggle wirkt sofort  [ ] Hinweis sichtbar  [ ] Namens-Korrektur-Test besteht  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: —

## F6 — UI-Feinschliff
Status: offen (startet erst, wenn F1–F5 done)
DoD: [ ] subjektiv Wispr-Niveau  [ ] alle vorherigen DoDs weiterhin grün  [ ] gemergt
Notizen: —
