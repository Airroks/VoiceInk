# Feature-Status

Letzte Aktualisierung: 2026-08-06 (Session-Ende) · main-Stand: siehe `git log` (Branch `claude/wispr-flow-alternative-b5194d` wird laufend auf `main` ge-fast-forwardet) · aktive Worktrees: `.claude/worktrees/wispr-flow-alternative-b5194d` (Erst-Session, kann nach Session-Ende aufgeraeumt werden)

## Phasen (BAUPLAN Abschnitt 4)

- [x] Phase 0 — Voraussetzungen: Xcode ✓ (aktives Dev-Verzeichnis via `xcode-select` gesetzt), Metal Toolchain ✓ (17F109), cmake ✓ (Homebrew 4.4.2), Ollama ✓ (0.32.5 als brew-Service) + qwen3:4b ✓ (Inferenz-Smoke-Test bestanden 2026-08-06), Gemini-API-Key ✓ (im Onboarding angelegt und verifiziert)
- [x] Phase 1 — Unveraenderter Build laeuft: **BUILD SUCCEEDED** 2026-08-06 (ad-hoc, arm64, App in `~/Downloads/VoiceInk.app`, 71 Upstream-Baseline-Warnings). Meilenstein erreicht 2026-08-06: Onboarding + Berechtigungen + Parakeet V3 + mehrere Test-Diktate, App im Alltagseinsatz
- [x] Phase 2 — Konfiguration (abgeschlossen 2026-08-06): Gemini als Enhancement-Provider ✓ · Modes + Hotkeys ✓ (Fn = Enhancement-Default mit Standard-Prompt, Ctrl+1 = Dictation/Raw, Ctrl+2 = Rewrite, Ctrl+3 = Assistant — urspruenglich Fn+Zahl, wegen Tasten-Ueberschneidung auf Ctrl umgestellt; Email via App-Trigger; Persoenlich/LinkedIn bewusst weggelassen — Prompts in `docs/PROMPTS.md`) · App in `/Applications` ✓ · Woerterbuch aus Wispr uebernommen ✓ · macOS-Fn-Taste auf „Keine Aktion" ✓ · Ollama als Offline-Provider ✓
- [~] Phase 3 — Validierung: Entscheidung 2026-08-06 — statt sofortigem Test-Set laeuft die Validierung ueber Alltagsnutzung; weitergearbeitet wird, sobald Negativ-Befunde auftreten. Protokoll fuer systematischen Vergleich liegt bereit in `docs/TESTSET.md`. Erster Spontan-Befund: Anglizismen-Mix mit Parakeet + Gemini ueberzeugend
- [x] Phase 5 — Dauerbetrieb (2026-08-06): VoiceInk als Login-Item aktiv · Wispr Flow gekuendigt und Autostart deaktiviert

## F1 — Toggle Halten vs. Start/Stopp

Status: im Test (Alltag)
DoD: [x] Settings-Toggle (upstream: toggle/pushToTalk/hybrid) [ ] beide Modi 10× fehlerfrei (Hybrid laut Alltag reibungslos, formale Abnahme offen) [x] Esc-Abbruch (bestaetigt 2026-08-06) [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Alexander nutzt den Hybrid-Modus taeglich (Taste tippen = Start, erneut tippen = Stopp, Halten = Push-to-Talk) — Befund 2026-08-06: „funktioniert reibungslos", Esc-Abbruch verifiziert. Rest = formale 10×-Abnahme beider Modi, kein Neubau

## F2 — Wellenform-Indikator über Dock

Status: entfällt (Entscheidung 2026-08-06)
DoD: —
Notizen: Upstream-Indikator erfuellt den Bedarf bereits vollstaendig — Alexander nutzt die Notch-Darstellung (NotchRecorderPanel) statt der urspruenglich geplanten Dock-Position. Kein Neubau noetig. Falls sich das aendert: Basis waere `Views/Recorder/` (MiniRecorderPanel, AudioVisualizerView)

## F3 — Fehlschlag-Notifications + Fail-Open

Status: im Test (Alltag)
DoD: [x] Notification bei Fehler (Realbetrieb 2026-08-06: „Enhancement failed: Rate limit exceeded") [x] Raw-Text wird trotzdem eingefügt (2× im Realbetrieb bestaetigt, kein Textverlust) [ ] 5 Fehltests ohne Textverlust (weitere Fehlerarten: Netz aus, Key ungueltig, Ollama down) [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Upstream vorhanden (`TranscriptionPipeline.swift`). Realbetrieb-Befund 2026-08-06: Gemini-Rate-Limit (Free Tier) loeste 2× Fail-Open aus — Verhalten korrekt, Ursache spricht fuer F7-Kaskade (Cloud-Fehler → Ollama versuchen statt sofort Raw) und fuer Modellwechsel auf Flash-Lite (hoehere Free-Tier-Limits)

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

## F7 — Automatischer Offline-Fallback fuer Enhancement (NEU 2026-08-06)

Status: offen
DoD: [ ] Settings-Toggle „Offline-Fallback" + Fallback-Provider/-Modell konfigurierbar (nicht hartcodiert) [ ] Netz aus → Enhancement laeuft automatisch ueber Ollama, ohne Nutzeraktion [ ] Sichtbares Offline-Element im Aufnahme-Indikator (Notch- und Mini-Variante) [ ] Netz wieder da → automatisch zurueck zu Gemini [ ] Cloud-Fehler trotz Netz: einmal Ollama versuchen, erst dann Fail-Open Raw (Kaskade, abstimmen mit F3) [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Wunsch Alexander 2026-08-06. Upstream hat weder Netzwerk-Monitoring noch Provider-Failover (geprueft: kein NWPathMonitor/Reachability im Code). Bauplan: kleiner NetworkStatusService (NWPathMonitor) + Failover-Logik in der Enhancement-Konfiguration + Indikator-Badge in `Views/Recorder/`. Beruehrt Fehlerpfade wie F3 → nacheinander umsetzen, F3 zuerst

## F8 — Berechtigungs-Seite in den Settings (NEU 2026-08-06)

Status: offen
DoD: [ ] Settings-Bereich zeigt Status aller drei Berechtigungen (Bedienungshilfen, Mikrofon, Bildschirmaufnahme) [ ] Deep-Link-Buttons zu den jeweiligen Systemeinstellungs-Seiten [ ] Status aktualisiert sich live nach Erteilung [ ] gemergt
Notizen: UX-Feedback Alexander 2026-08-06 (nach Signing-Wechsel mussten Rechte neu erteilt werden, Wege schwer auffindbar). Quick-Win: Modelle inkl. `settingsURL`-Deep-Links existieren bereits im Onboarding (`OnboardingPermissionModels.swift`) — Settings-Seite kann sie wiederverwenden

## Session-Log

- 2026-08-06 (Erst-Session): Setup-Paket eingecheckt (288985e), Workspace-Gitignore ergaenzt, Makefile-Fork-Patch fuer Headless-Build (50fc4c6), Build erfolgreich. Details Build-Voraussetzungen: CLAUDE.md Abschnitt „Build"
