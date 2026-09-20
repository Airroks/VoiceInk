# Feature-Status

Letzte Aktualisierung: 2026-09-20 · main-Stand: siehe `git log` · Upstream-Stand: **v2.20 gemergt** (2026-09-20, Branch `feature/upstream-2.20`, wartet auf Praxistest vor dem Fast-Forward auf `main`)

## Upstream-Merge 2.20 (2026-09-20)

Anlass: Releases v2.13 (27.08.) und v2.20 (19.09.) — 136 Commits, 400 Dateien. Backup vor dem Merge: Tag `backup/pre-upstream-2.20` (= alter `main` 7504541) + App-Bundle `.local-backups/VoiceInk-fork-2.11-7504541.app` (Rollback: `ditto` nach `/Applications`).

Neu aus 2.13/2.20: Dictionary Auto Learn (KI-gestuetzte Korrekturvorschlaege), Woerterbuch-Import/-Export (JSON), Quick-History-Panel, **native Maus-Shortcuts** (siehe F9), Gemini-Transkription, SenseVoice, Grok Voice Transcribe 2.0, Gemini 3.8 Flash + Qwen 3.8 als Enhancement-Modelle, Shortcuts werden bei gesperrtem Mac ignoriert, bessere Esc-Abbruchlogik, Recorder-Panel-Fix nach Wake, Model-Download-Performance, Franzoesisch. Quellbaum komplett reorganisiert (`Features/`, `Infrastructure/`, `App/`) — Code-Landkarte in CLAUDE.md aktualisiert.

Merge-Ergebnis (7 Konflikte + 3 stille Auto-Merge-Korrekturen), Details in CLAUDE.md → „Upstream-Merge":

1. Keychain-, Lizenz- und CloudKit-Guard sind seit 2.20 **upstream nativ** (PR #889) — Fork-Patches entfernt. Der Auto-Merge hatte aus beiden Keychain-Implementierungen einen Hybrid gebaut → auf Upstream-Stand gesetzt. Migration des Gemini-Keys aus `LocalKeychain_geminiAPIKey` in den Login-Keychain (Service `com.prakashjoshipax.VoiceInk.Local`) beim ersten Start im Log bestaetigt
2. Updater-Guard bleibt Fork-Patch (Upstream startet Sparkle weiterhin) — Laufzeit-Log: 0 Sparkle-Zeilen
3. `OllamaService` bleibt Fork-Version: LLMkit-Stand 7b62182 kennt in `OllamaGenerationOptions` nur temperature/topP/topK — kein `num_ctx`, kein `keep_alive`
4. F7-Kaskade in Upstreams zentralisierten Request-Pfad (`performChatCompletion`, `EnhancementRequestSettings.maximumAttempts`) eingepasst; Ollama behaelt das eigene 15s-Budget
5. **Upstream-Bug entdeckt**: `LocalBuild.xcconfig` setzt `CODE_SIGN_IDENTITY = -` und ueberschreibt damit die im Makefile erkannte Apple-Development-Identity (`-xcconfig` hat Vorrang vor Kommandozeilen-Settings) → jeder `make local` war ad-hoc signiert, TCC-Grants waeren bei jedem Rebuild verloren gegangen. Fork-Patch: Zeile entfernt; Designated Requirement des neuen Builds ist identisch mit dem alten Fork-Build, alle TCC-Grants (Accessibility, Input Monitoring, Mikrofon, PostEvent) laut tccd-Log ohne Prompt uebernommen
6. Neues Makefile-Target `install-local` (letzten Build ohne Neubau installieren)
7. Xcode 27.0 verlangte erneut Lizenz-Accept (sudo, durch Alexander) und Metal-Toolchain-Download

Praxistest Alexander 2026-09-20: Diktat + Gemini ok (58,7s Diktat → Parakeet 758ms, gemini-3.6-flash 1,9s), Dashboard ohne Lizenzhinweis, Offline-Fallback greift („Default · Ollama-Fallback", 1,6s) — aber mit deutlich schlechterem Text. Ursache per A/B-Test gegen Ollama belegt (gleiche Parameter wie die App, reproduzierbar bei Temperatur 0,3): Upstreams neues System-Template aus 2.20 („Improve prompt structure": XML-Sektionen, Absatz-/Listenregeln, Kuerzungs-Beispiele) laesst qwen3:4b-instruct jeden Satz mit Markdown-Zeilenumbruch einzeln setzen und Inhalt um Selbstkorrekturen herum verlieren („Das wäre besser." 2/2 weg, „Da müssten wir" → „Ich müsste"). Fork-Fix: `AIPrompts.enhancementSystemTemplateLocal` (= 2.11-Template) nur fuer `provider == .ollama`, Gemini behaelt Upstreams Template. Nach dem Fix installiert, wartet auf Alexanders Offline-Gegenprobe.

Maus-Shortcut (F9): Taste 6 wurde im Recorder nicht erkannt — Recorder nutzt einen lokalen `NSEvent`-Monitor, BTT lag mit Taste-6→F20 noch davor und hat den Klick geschluckt (VoiceInk sah nur F20). Alexander bleibt bei BTT→F20 mit F20 als VoiceInk-Toggle. Nativer Weg offen: BTT-Zuweisung deaktivieren, dann im Recorder aufnehmen.

Verifiziert 2026-09-20: `** BUILD SUCCEEDED **` (Release, 9 Upstream-Warnings + 1 erwartete aus dem Sparkle-Guard), App startet ohne Crash, Parakeet V3 Prewarm 0,41s, Gemini-Key migriert, Ollama erreichbar (`qwen3:4b-instruct`), Dashboard-Stats-Snapshot einmalig neu aufgebaut (2.11-Format kannte `thisYearDailyActivity` nicht — beim naechsten Start still). Offen (nur manuell pruefbar): Diktat mit Enhancement, Dashboard ohne Lizenzhinweis, Offline-Fallback provozieren, Maus-Shortcut einrichten.

## Upstream-Merge 2.11 (2026-08-13)

Anlass: Sparkle hatte am 2026-08-12 ungefragt die offizielle 2.11 installiert und den Fork-Build ersetzt. Nach dem Rollback wurde 2.11 kontrolliert gemergt (31 Commits, 67 Dateien upstream; nur 5 Ueberschneidungen, 1 echter Konflikt in `VoiceInk.swift` — Upstream hatte `UpdaterViewModel` nach `Services/` ausgelagert).

Neu aus 2.11: VoiceInk Refine (on-device Enhancement), Cohere Transcribe (experimentell), Update-Anzeige im Dashboard, Mikrofon-Fix bei geschlossenem Deckel (Clamshell).

Drei Nacharbeiten, weil Upstream lokale Sonderwege entfernt hatte — Details und Pflicht-Checkliste in `CLAUDE.md` → „Upstream-Merge":

1. Keychain-Fallback fuer lokale Builds wiederhergestellt (sonst API-Keys unlesbar)
2. Lizenz-Bypass fuer Eigenbau wiederhergestellt (sonst Testversions-Hinweis)
3. Updater-Guard in Upstreams neuer Datei neu gesetzt

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
Notizen: OFFEN: Onboarding-Ueberarbeitung (UX-Feedback 2026-08-06) — Modell-Anbindungen als eine Uebersicht statt sequenzieller Provider-Abfrage, Skip neutral formulieren; bewusst zurueckgestellt (Onboarding laeuft nur einmal, Aufwand/Nutzen) · ERLEDIGT vorab: Fenster-Flash beim Start im Menueleisten-Modus behoben (2026-08-06, Commit 4f7b047 — synchrones alpha-0 vor dem ersten Frame) · Kandidat aus F7-Beobachtung: Accidental-Start-Abbruchfenster (~1s) konfigurierbar machen, falls es im Alltag stoert

## F7 — Automatischer Offline-Fallback fuer Enhancement

Status: done (2026-08-06) · nachgebessert 2026-08-13
Nachbesserung 2026-08-13: Bei aktivem Fallback bekommt die Cloud nur noch EINEN Versuch. Vorher liefen 3 Gemini-Timeouts a 15s (45,9s) vor der Kaskade, danach lieferte Ollama in 7s — 53s bis Text erschien (Log-Beweis). Ohne Fallback bleibt die Retry-Schleife aktiv.
DoD: [x] Settings-Toggle „Offline fallback via Ollama" (Default an; Modell/URL aus der Ollama-Provider-Config, nichts hartcodiert) [x] Netz aus → Enhancement laeuft automatisch ueber Ollama (Log-Beweis: „Offline fallback: routing enhancement to Ollama", Selbstkorrekturen offline aufgeloest) [x] Offline-Badge (wifi.slash, orange) im Notch- und Mini-Recorder, links neben dem Modus-Logo als Overlay [x] Netz zurueck → automatisch Gemini (stateless pro Request, im Test bestaetigt) [x] Kaskade: Cloud-Fehler trotz Netz → einmal Ollama, dann Fail-Open Raw [x] Kurz-Test-Set ok [x] gemergt
Notizen: Umsetzung: `Services/NetworkStatusService.swift` (NWPathMonitor) · Failover + 15s-UX-Budget (ein Versuch, keine Retry-Schleife) in `AIEnhancementService.enhance()` · Keep-Warm-Loop laedt das Ollama-Modell beim Netzausfall vor und erneuert alle 10 Min (keep_alive 15m) · History markiert Fallback mit „· Ollama-Fallback". KRITISCHE ERKENNTNISSE: (1) Ollama-Tag `qwen3:4b` zeigt auf die Thinking-Variante (2507), die IMMER denkt (2.600+ Tokens fuer Mini-Auftraege, think:false und /no_think wirkungslos) → Wechsel auf `qwen3:4b-instruct` (1,3-1,8s inkl. Kaltstart). (2) Aktuelles Ollama laedt Modelle mit vollem Kontextfenster (qwen3: 262k → 23,7 GB KV-Cache) → `options.num_ctx` wird jetzt in jedem Request gepinnt (Default 8192, UserDefaults „OllamaNumCtx"); direkter API-Call statt LLMkit noetig. UX-Regel Alexander: <2s instant, 5-6s okay, >10s wirkt kaputt. (3) Seit Upstream 2.20 bekommt Ollama das kompakte 2.11-System-Template (`AIPrompts.enhancementSystemTemplateLocal`, gewaehlt in `CustomPrompt.finalPromptText(forLocalModel:)`) — Upstreams neues Template degradiert das 4B-Modell messbar (Zeilenumbruch je Satz, Inhaltsverlust), siehe Upstream-Merge 2.20. Bei 64 GB RAM waere ein groesseres lokales Modell (z.B. qwen3 8B) als Fallback testbar — nur mit TESTSET-Vergleich und Latenzmessung entscheiden. Beobachtung (einmalig, kein Bug): Tastendruck <1s nach Aufnahme-Trigger loest upstream die Accidental-Start-Abbruchlogik aus (Ton ohne sichtbare Aufnahme) — z.B. Enter im Terminal + sofortiger Diktat-Klick

## F8 — Berechtigungs-Seite in den Settings (NEU 2026-08-06)

Status: done (2026-08-06)
DoD: [x] Settings-Sektion „Permissions" zeigt Status aller drei Berechtigungen (verifiziert: alle drei sichtbar, gruen) [x] Deep-Link-Buttons oeffnen die korrekten Systemeinstellungs-Seiten (verifiziert) [x] Status aktualisiert sich live (Refresh bei App-Fokus-Wechsel) [x] gemergt
Notizen: Umsetzung: `Views/Settings/PermissionsSettingsSection.swift`, wiederverwendet die Onboarding-Modelle (OnboardingPermissionKind/-Status, PrivacySettingsPane). Mikrofon loest bei „notDetermined" den nativen Dialog aus statt nur die Settings zu oeffnen. Betroffene Datei ausserdem: SettingsView.swift (Sektion vor Diagnostics)

## F9 — Maustasten als Aufnahme-Trigger

Status: geloest extern (2026-08-06, via BetterTouchTool) · **nativ verfuegbar seit Upstream 2.20** — Umstellung von BTT auf den nativen Maus-Shortcut steht an (Entscheidung Alexander 2026-09-20: Feature nutzen)
DoD: [ ] BTT-Zuweisung Maustaste-6→F20 **vorher** deaktivieren (sonst schluckt BTT den Klick und der Recorder sieht nur F20 — passiert am 2026-09-20) [ ] Maustaste im Shortcut-Recorder (Settings → Shortcuts) als Aufnahme-Shortcut gesetzt [ ] Halten + Toggle mit Maustaste verifiziert
Notizen: Upstream 2.20 (`Features/Shortcuts/`: `Shortcut.isSupportedMouseButtonNumber`, `ShortcutRecorder.handleMouseDown`) nimmt Maustasten direkt im Recorder auf; Hinweis in den Settings erklaert den Support. Alte BTT-Loesung bleibt als Fallback dokumentiert: Maus-Down/Up-Trigger → F20 Key-Down-only/Key-Up-only. Technischer Einstieg dann: ShortcutMonitor-EventMask um otherMouseDown/otherMouseUp erweitern + Shortcut-Recorder-UI; upstream existiert bereits ein Middle-Click-Toggle (isMiddleClickToggleEnabled) als Muster

## Session-Log

- 2026-09-20 (Upstream-2.20-Merge): Backup-Tag + App-Bundle, Trocken-Merge zur Konfliktanalyse, Merge in `feature/upstream-2.20` (7e18456), Signing-Bug in Upstreams LocalBuild.xcconfig gefunden und gepatcht, `make install-local`, Build + Laufzeitpruefung (Logs, Keychain-Migration, TCC-Grants). Praxistest: Gemini/Lizenz/Fallback ok; Ollama-Qualitaetsverlust per A/B auf Upstreams neues System-Template zurueckgefuehrt und mit lokalem 2.11-Template gefixt. CLAUDE.md komplett auf neue Code-Struktur gebracht. Fast-Forward auf `main` nach Offline-Gegenprobe
- 2026-08-06 (Erst-Session): Setup-Paket eingecheckt (288985e), Workspace-Gitignore ergaenzt, Makefile-Fork-Patch fuer Headless-Build (50fc4c6), Build erfolgreich. Details Build-Voraussetzungen: CLAUDE.md Abschnitt „Build"
