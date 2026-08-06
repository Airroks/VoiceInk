# Feature-Status

Letzte Aktualisierung: 2026-08-06 (Session-Ende) · main-Stand: siehe `git log` (Branch `claude/wispr-flow-alternative-b5194d` wird laufend auf `main` ge-fast-forwardet) · aktive Worktrees: `.claude/worktrees/wispr-flow-alternative-b5194d` (Erst-Session, kann nach Session-Ende aufgeraeumt werden)

## Phasen (BAUPLAN Abschnitt 4)

- [x] Phase 0 — Voraussetzungen: Xcode ✓ (aktives Dev-Verzeichnis via `xcode-select` gesetzt), Metal Toolchain ✓ (17F109), cmake ✓ (Homebrew 4.4.2), Ollama ✓ (0.32.5 als brew-Service) + qwen3:4b ✓ (Inferenz-Smoke-Test bestanden 2026-08-06), Gemini-API-Key ✓ (im Onboarding angelegt und verifiziert)
- [x] Phase 1 — Unveraenderter Build laeuft: **BUILD SUCCEEDED** 2026-08-06 (ad-hoc, arm64, App in `~/Downloads/VoiceInk.app`, 71 Upstream-Baseline-Warnings). Meilenstein erreicht 2026-08-06: Onboarding + Berechtigungen + Parakeet V3 + mehrere Test-Diktate, App im Alltagseinsatz
- [x] Phase 2 — Konfiguration (abgeschlossen 2026-08-06): Gemini als Enhancement-Provider ✓ · Modes + Hotkeys ✓ (Fn = Enhancement-Default mit Standard-Prompt, Ctrl+1 = Dictation/Raw, Ctrl+2 = Rewrite, Ctrl+3 = Assistant — urspruenglich Fn+Zahl, wegen Tasten-Ueberschneidung auf Ctrl umgestellt; Email via App-Trigger; Persoenlich/LinkedIn bewusst weggelassen — Prompts in `docs/PROMPTS.md`) · App in `/Applications` ✓ · Woerterbuch aus Wispr uebernommen ✓ · macOS-Fn-Taste auf „Keine Aktion" ✓ · Ollama als Offline-Provider ✓
- [~] Phase 3 — Validierung: Entscheidung 2026-08-06 — statt sofortigem Test-Set laeuft die Validierung ueber Alltagsnutzung; weitergearbeitet wird, sobald Negativ-Befunde auftreten. Protokoll fuer systematischen Vergleich liegt bereit in `docs/TESTSET.md`. Erster Spontan-Befund: Anglizismen-Mix mit Parakeet + Gemini ueberzeugend
- [x] Phase 5 — Dauerbetrieb (2026-08-06): VoiceInk als Login-Item aktiv · Wispr Flow gekuendigt und Autostart deaktiviert

## F1 — Toggle Halten vs. Start/Stopp

Status: done (2026-08-06)
DoD: [x] Settings-Toggle (upstream: toggle/pushToTalk/hybrid) [x] beide Modi ueber Fn fehlerfrei (Tippen + Halten validiert 2026-08-06) [x] Esc-Abbruch (Doppel-Esc-Bestaetigung, verifiziert 2026-08-06) [x] Maustasten-Weg via BTT Key-Down/Up-Split bestaetigt (Halten + Toggle funktionieren) [x] Kurz-Test-Set ok (zahlreiche Alltags-Diktate 2026-08-06) [x] gemergt
Notizen: Bug-Analyse 2026-08-06: „Halten stoppt nicht" lag NICHT an VoiceInk/Fn, sondern an der BetterTouchTool-Zuweisung Maustaste-6→F20 — BTT sendete einen Millisekunden-Tipp statt gehaltenem Key (Log-Beweis: pressDuration 0.000-0.054s, verschluckte KeyDowns im 0.5s-Cooldown). Loesung: BTT mit getrennten Mouse-Down/Up-Triggern und Key-Down-only/Key-Up-only-Aktionen. Diagnose-Logging in ShortcutMonitor (warning bei Tap-Timeouts) und RecordingShortcutModeHandler (debug) bleibt fuer kuenftige Analysen im Code. Beobachtung: Hybrid-Stopp-Bedingung verlangt state==recording — bei langsamem Engine-Start theoretisch fehlklassifizierbar, bisher nicht reproduziert. Upstream-Fund: Middle-Click-Toggle existiert bereits nativ (isMiddleClickToggleEnabled) — Anknuepfungspunkt fuer F9

## F2 — Wellenform-Indikator über Dock

Status: entfällt (Entscheidung 2026-08-06)
DoD: —
Notizen: Upstream-Indikator erfuellt den Bedarf bereits vollstaendig — Alexander nutzt die Notch-Darstellung (NotchRecorderPanel) statt der urspruenglich geplanten Dock-Position. Kein Neubau noetig. Falls sich das aendert: Basis waere `Views/Recorder/` (MiniRecorderPanel, AudioVisualizerView)

## F3 — Fehlschlag-Notifications + Fail-Open

Status: done (2026-08-06)
DoD: [x] Notification bei Fehler (Realbetrieb: Rate-Limit + Timeouts) [x] Raw-Text wird trotzdem eingefügt (alle Faelle, kein Textverlust) [x] 5 Fehltests — ersetzt durch 5 Realbetrieb-Fail-Opens am 2026-08-06 (2× Rate-Limit, 3× Timeout), Entscheidung Alexander: simulierte Fehltests nicht noetig [x] Kurz-Test-Set ok (Alltags-Diktate) [x] gemergt (upstream-Verhalten, keine Code-Aenderung noetig)
Notizen: Upstream vorhanden (`TranscriptionPipeline.swift`), Verhalten mehrfach real bewiesen. Offen als Beobachtung: Haeufung von Enhancement-Timeouts am Abend des 2026-08-06 (3×, Default-Timeout 7s) — Ursache klaeren, staerkt Prioritaet von F7 (Kaskade Cloud→Ollama→Raw)

## F4 — History-Retention

Status: done (2026-08-06)
DoD: [x] Einstellung aus/1/7/30/unbegrenzt (Picker: Immediately/1h/1d/3d/7d/30d + Toggle aus = unbegrenzt; 30d als Fork-Ergaenzung) [x] Loesch-Job beim Start inkl. Audio (code-verifiziert: sweepOldTranscriptions + cleanupOrphanAudioFiles beim startMonitoring) [x] „aus" speichert nichts Neues (code-verifiziert: retention=0 loescht sofort nach Abschluss inkl. Audio) [x] Kurz-Test-Set ok (aktive Nutzung) [x] gemergt (32d61d2)
Notizen: Aktive Einstellung Alexander: Auto-delete nach 1 Tag (bewusste Datensparsamkeit). Upstream-Bonus: separater Audio-only-Cleanup (Audio loeschen, Transkripte behalten), falls spaeter gewuenscht

## F5 — Content-Aware: aktives Fenster + Toggle + Hinweis

Status: offen
DoD: [ ] Kontext nur aktives Fenster (Log-Check) [ ] Toggle wirkt sofort [ ] Hinweis sichtbar [ ] Namens-Korrektur-Test besteht [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: `ScreenCaptureService` arbeitet bereits fensterbasiert (FocusedWindowHint) — Toggle + Hinweis pruefen

## F6 — UI-Feinschliff

Status: offen (startet erst, wenn F1–F5 done)
DoD: [ ] subjektiv Wispr-Niveau [ ] alle vorherigen DoDs weiterhin grün [ ] gemergt
Notizen: UX-Feedback Onboarding (2026-08-06, Alexander): Modell-Anbindungen als eine Uebersicht statt sequenzieller Provider-Abfrage (erst Groq-Key-Formular, Skip wirkt wie Funktionsverlust inkl. roter Warnung). Wunsch: alle Anbindungen (STT lokal/Cloud, Enhancement-Provider) auf einer Seite konfigurierbar, Skip neutral formulieren · Fenster blitzt beim App-Start kurz auf, bevor der Menueleisten-Modus („im Dock ausblenden") greift (2026-08-06)

## F7 — Automatischer Offline-Fallback fuer Enhancement (NEU 2026-08-06)

Status: offen
DoD: [ ] Settings-Toggle „Offline-Fallback" + Fallback-Provider/-Modell konfigurierbar (nicht hartcodiert) [ ] Netz aus → Enhancement laeuft automatisch ueber Ollama, ohne Nutzeraktion [ ] Sichtbares Offline-Element im Aufnahme-Indikator (Notch- und Mini-Variante) [ ] Netz wieder da → automatisch zurueck zu Gemini [ ] Cloud-Fehler trotz Netz: einmal Ollama versuchen, erst dann Fail-Open Raw (Kaskade, abstimmen mit F3) [ ] Kurz-Test-Set ok [ ] gemergt
Notizen: Wunsch Alexander 2026-08-06. Upstream hat weder Netzwerk-Monitoring noch Provider-Failover (geprueft: kein NWPathMonitor/Reachability im Code). Bauplan: kleiner NetworkStatusService (NWPathMonitor) + Failover-Logik in der Enhancement-Konfiguration + Indikator-Badge in `Views/Recorder/`. Beruehrt Fehlerpfade wie F3 → nacheinander umsetzen, F3 zuerst

## F8 — Berechtigungs-Seite in den Settings (NEU 2026-08-06)

Status: offen
DoD: [ ] Settings-Bereich zeigt Status aller drei Berechtigungen (Bedienungshilfen, Mikrofon, Bildschirmaufnahme) [ ] Deep-Link-Buttons zu den jeweiligen Systemeinstellungs-Seiten [ ] Status aktualisiert sich live nach Erteilung [ ] gemergt
Notizen: UX-Feedback Alexander 2026-08-06 (nach Signing-Wechsel mussten Rechte neu erteilt werden, Wege schwer auffindbar). Quick-Win: Modelle inkl. `settingsURL`-Deep-Links existieren bereits im Onboarding (`OnboardingPermissionModels.swift`) — Settings-Seite kann sie wiederverwenden

## F9 — Maustasten als Aufnahme-Trigger (NEU 2026-08-06, niedrige Prio)

Status: offen (optional)
DoD: [ ] Maustaste (z.B. MX Master Button 6) direkt in den Shortcut-Settings aufnehmbar [ ] Halten + Toggle funktionieren wie bei Tasten [ ] gemergt
Notizen: Wispr-Flow-Paritaet, Wunsch Alexander. Aktuell geloest ueber BetterTouchTool (Maus-Down/Up → F20 Key-Down/Up-Split) — nativer Support nur noetig, falls der BTT-Weg im Alltag nervt. Technisch: ShortcutMonitor-EventMask um otherMouseDown/otherMouseUp erweitern + Shortcut-Recorder-UI

## Session-Log

- 2026-08-06 (Erst-Session): Setup-Paket eingecheckt (288985e), Workspace-Gitignore ergaenzt, Makefile-Fork-Patch fuer Headless-Build (50fc4c6), Build erfolgreich. Details Build-Voraussetzungen: CLAUDE.md Abschnitt „Build"
