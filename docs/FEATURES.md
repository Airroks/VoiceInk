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

Status: done (2026-08-06)
DoD: [x] Kontext nur aktives Fenster (AI-Request-Inspektion: „Active Window"-Header, ausschliesslich dessen Inhalt; Code: SCContentFilter(desktopIndependentWindow:)) [x] Toggle wirkt sofort (Screen aus → Request ohne CURRENT_WINDOW_CONTEXT, verifiziert) [x] Hinweis sichtbar (InfoTips aller drei Kontext-Quellen mit Sensible-Daten-Zusatz, Fork-Ergaenzung) [x] Namens-Korrektur-Test besteht (Fruehbeisser in Spark, Nicolaus in LinkedIn — mit Kontext korrekt, ohne Kontext falsch) [x] Kurz-Test-Set ok [x] gemergt
Notizen: Wichtiger Betriebsfund: Fehlt die Bildschirmaufnahme-Berechtigung, scheitert die Kontext-Erfassung STILL (macOS zeigt keinen Auto-Prompt, App meldet nichts) — Symptom: CURRENT_WINDOW_CONTEXT fehlt im Request, Namens-Korrektur unterbleibt. F8-Statusseite macht das sichtbar. History-Detailansicht (gespeicherter AI-Request) ist das beste Diagnose-Werkzeug. Datenschutz-Beleg: Fenster-Kontext kann sehr viel Privates enthalten (LinkedIn-Nachrichtenliste) — Toggle-Disziplin bei Kundenarbeit wichtig, Clipboard-Kontext ggf. deaktivieren (uebertrug im Test Terminal-Befehle)

## F6 — UI-Feinschliff

Status: offen (startet erst, wenn F1–F5 done)
DoD: [ ] subjektiv Wispr-Niveau [ ] alle vorherigen DoDs weiterhin grün [ ] gemergt
Notizen: UX-Feedback Onboarding (2026-08-06, Alexander): Modell-Anbindungen als eine Uebersicht statt sequenzieller Provider-Abfrage (erst Groq-Key-Formular, Skip wirkt wie Funktionsverlust inkl. roter Warnung). Wunsch: alle Anbindungen (STT lokal/Cloud, Enhancement-Provider) auf einer Seite konfigurierbar, Skip neutral formulieren · Fenster blitzt beim App-Start kurz auf, bevor der Menueleisten-Modus („im Dock ausblenden") greift (2026-08-06)

## F7 — Automatischer Offline-Fallback fuer Enhancement

Status: done (2026-08-06)
DoD: [x] Settings-Toggle „Offline fallback via Ollama" (Default an; Modell/URL aus der Ollama-Provider-Config, nichts hartcodiert) [x] Netz aus → Enhancement laeuft automatisch ueber Ollama (Log-Beweis: „Offline fallback: routing enhancement to Ollama", Selbstkorrekturen offline aufgeloest) [x] Offline-Badge (wifi.slash, orange) im Notch- und Mini-Recorder, links neben dem Modus-Logo als Overlay [x] Netz zurueck → automatisch Gemini (stateless pro Request, im Test bestaetigt) [x] Kaskade: Cloud-Fehler trotz Netz → einmal Ollama, dann Fail-Open Raw [x] Kurz-Test-Set ok [x] gemergt
Notizen: Umsetzung: `Services/NetworkStatusService.swift` (NWPathMonitor) · Failover + 15s-UX-Budget (ein Versuch, keine Retry-Schleife) in `AIEnhancementService.enhance()` · Keep-Warm-Loop laedt das Ollama-Modell beim Netzausfall vor und erneuert alle 10 Min (keep_alive 15m) · History markiert Fallback mit „· Ollama-Fallback". KRITISCHE ERKENNTNISSE: (1) Ollama-Tag `qwen3:4b` zeigt auf die Thinking-Variante (2507), die IMMER denkt (2.600+ Tokens fuer Mini-Auftraege, think:false und /no_think wirkungslos) → Wechsel auf `qwen3:4b-instruct` (1,3-1,8s inkl. Kaltstart). (2) Aktuelles Ollama laedt Modelle mit vollem Kontextfenster (qwen3: 262k → 23,7 GB KV-Cache) → `options.num_ctx` wird jetzt in jedem Request gepinnt (Default 8192, UserDefaults „OllamaNumCtx"); direkter API-Call statt LLMkit noetig. UX-Regel Alexander: <2s instant, 5-6s okay, >10s wirkt kaputt. Beobachtung (einmalig, kein Bug): Tastendruck <1s nach Aufnahme-Trigger loest upstream die Accidental-Start-Abbruchlogik aus (Ton ohne sichtbare Aufnahme) — z.B. Enter im Terminal + sofortiger Diktat-Klick

## F8 — Berechtigungs-Seite in den Settings (NEU 2026-08-06)

Status: done (2026-08-06)
DoD: [x] Settings-Sektion „Permissions" zeigt Status aller drei Berechtigungen (verifiziert: alle drei sichtbar, gruen) [x] Deep-Link-Buttons oeffnen die korrekten Systemeinstellungs-Seiten (verifiziert) [x] Status aktualisiert sich live (Refresh bei App-Fokus-Wechsel) [x] gemergt
Notizen: Umsetzung: `Views/Settings/PermissionsSettingsSection.swift`, wiederverwendet die Onboarding-Modelle (OnboardingPermissionKind/-Status, PrivacySettingsPane). Mikrofon loest bei „notDetermined" den nativen Dialog aus statt nur die Settings zu oeffnen. Betroffene Datei ausserdem: SettingsView.swift (Sektion vor Diagnostics)

## F9 — Maustasten als Aufnahme-Trigger

Status: geloest extern (2026-08-06, via BetterTouchTool)
DoD: entfaellt — BTT-Loesung (Maus-Down/Up-Trigger → F20 Key-Down-only/Key-Up-only) liefert Wispr-Paritaet inkl. Halten und Toggle, im Alltag verifiziert
Notizen: Nativer Support nur wieder aufnehmen, falls der BTT-Weg im Alltag stoert. Technischer Einstieg dann: ShortcutMonitor-EventMask um otherMouseDown/otherMouseUp erweitern + Shortcut-Recorder-UI; upstream existiert bereits ein Middle-Click-Toggle (isMiddleClickToggleEnabled) als Muster

## Session-Log

- 2026-08-06 (Erst-Session): Setup-Paket eingecheckt (288985e), Workspace-Gitignore ergaenzt, Makefile-Fork-Patch fuer Headless-Build (50fc4c6), Build erfolgreich. Details Build-Voraussetzungen: CLAUDE.md Abschnitt „Build"
