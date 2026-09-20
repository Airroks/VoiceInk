# CLAUDE.md — Voice-to-Text-App (VoiceInk-Fork)

## Projektziel

Persönliche Wispr-Flow-Alternative für macOS (Apple Silicon), schneller und für Alexanders Anwendungsfall präziser als Wispr Flow. Verbindliche Referenz: `docs/BAUPLAN.md` · Projektstand: `docs/FEATURES.md`

## Fixe Entscheidungen (nicht ohne Rücksprache ändern)

- STT lokal: Parakeet TDT 0.6B v3 via FluidAudio (Default) · Whisper large-v3-turbo als Zweit-Engine, hart auf Deutsch fixiert (Flüstern/Lärm)
- LLM-Cleanup: Gemini (Cloud-Default) — aktuell `gemini-3.6-flash` mit thinking=minimal, bewusste Qualitaets-Entscheidung 2026-08-06 (Paid Tier aktiv, Limit 15 €/Monat; `gemini-3.5-flash-lite` als dokumentierte Sparoption) · Ollama auf localhost:11434 als Offline-Backup mit `qwen3:4b-instruct` — NICHT `qwen3:4b` (= Thinking-Variante, denkt zwingend und sprengt jedes Latenz-Budget); num_ctx wird app-seitig gepinnt (Default 8192) · Provider und Modell-IDs immer als konfigurierbare Settings, nie hartcodiert
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
- **Nie das In-App-Update annehmen**: Der gebündelte Sparkle-Feed zeigt auf den Upstream-Appcast — ein Update ersetzt den Fork-Build durch die offizielle App und verwirft alle Fork-Änderungen (passiert am 2026-08-12 mit 2.11). Seit Commit e198315 ist der Updater in `LOCAL_BUILD` deaktiviert. Nach einem versehentlichen Update: `make local` neu bauen, dann installieren — Einstellungen und Daten (UserDefaults, Recordings, Dictionary) überleben, nur die Code-Features fehlen bis zum Rebuild

## Upstream-Merge: Pflicht-Checkliste

Upstream kennt unsere lokalen Sonderwege nicht und entfernt sie beim Refactoring, ohne es zu merken (2.11 hat zwei stillgelegt, 2.20 hat den Quellbaum komplett umgebaut). Seit 2.20 trägt Upstream die LOCAL_BUILD-Pfade für Keychain, Lizenz und CloudKit selbst (PR #889) — diese Fork-Patches sind entfallen. Was bleibt, trägt im Code den Marker `FORK PATCH — do not drop when merging upstream`:

| Datei                                                              | Zweck                                                                                                       | Symptom bei Verlust                                                                    |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `App/Updates/UpdaterViewModel.swift`                               | Sparkle startet in `LOCAL_BUILD` nicht — Upstream hat diesen Guard bis heute nicht                          | In-App-Update ersetzt den Fork durch die offizielle App                                |
| `Infrastructure/Providers/Enhancement/Ollama/OllamaService.swift`  | Direkter `/api/generate`-Call mit `num_ctx`-Pinning + `keep_alive`; LLMkits `OllamaGenerationOptions` kennt beides nicht (Stand 2.20 geprüft) | Ollama lädt qwen3 mit 262k Kontext → 23,7 GB KV-Cache, Fallback unbenutzbar |
| `Makefile` (`local`- und `install-local`-Target)                   | Installiert nach `/Applications` statt `~/Downloads`; `install-local` installiert den letzten Build ohne Neubau | Login-Item und Berechtigungen zeigen auf eine alte App                              |
| `LocalBuild.xcconfig`                                              | Kein `CODE_SIGN_IDENTITY = -` — Upstreams Zeile überschreibt die Kommandozeilen-Identity (`-xcconfig` hat Vorrang, `man xcodebuild`) und macht jeden Build ad-hoc | App ad-hoc signiert (`codesign -dvvv` zeigt `flags=…adhoc`, Designated Requirement = cdhash) → TCC-Grants gehen bei jedem Rebuild verloren |

Merge-sensible Fork-Bereiche ohne eigenen Guard (bei Konflikten bewusst zusammenführen, nicht Upstream nehmen):

- `Core/Enhancement/AIPrompts.swift` (`enhancementSystemTemplateLocal`, FORK PATCH) + `Features/Enhancement/Models/CustomPrompt.swift` (`finalPromptText(forLocalModel:)`, FORK PATCH) — der Ollama-Pfad bekommt das kompakte 2.11-Template; Upstreams 2.20-Template degradiert qwen3:4b messbar (Beleg in FEATURES.md → Upstream-Merge 2.20). Bei kuenftigen Upstream-Prompt-Aenderungen: Gemini folgt Upstream, das lokale Template bleibt
- `Features/Enhancement/Workflows/AIEnhancementService.swift` — F7-Kaskade (Offline-Route, 1 Cloud-Versuch bei aktivem Fallback, Ollama-Fallback nach Cloud-Fehler, Keep-Warm-Loop, eigenes 15s-Budget für Ollama). Upstream 2.20 hat die Requests in `performChatCompletion` zentralisiert; die Kaskade sitzt in `enhance()`, das Ollama-Timeout im `performChatCompletion`-Aufruf
- Fork-eigene Dateien (existieren upstream nicht): `Infrastructure/SystemIntegration/Network/NetworkStatusService.swift`, `Features/Recording/Views/OfflineIndicatorBadge.swift`, `Features/Settings/Views/PermissionsSettingsSection.swift`
- Kleinere Fork-Diffs: `Features/Modes/State/ModeRuntimeConfiguration.swift` (`replacingProvider`), `Features/Modes/Views/ModeConfigFormView.swift` (F5-Hinweise), `Features/History/Views/HistorySettingsPanel.swift` (30-Tage-Option), `App/Windows/WindowManager.swift` + `App/VoiceInk.swift` (Launch-Flash-Unterdrückung), Diagnose-Logging in `Features/Shortcuts/Coordination/`

Vorgehen bei jedem Upstream-Merge:

1. `git tag backup/pre-upstream-<version>` auf den aktuellen `main` + App-Bundle nach `.local-backups/` kopieren (`ditto /Applications/VoiceInk.app .local-backups/VoiceInk-fork-<alt>-<hash>.app`)
2. Trocken-Merge (`git merge --no-commit`, dann `--abort`) für die Konfliktliste; bei Auto-Merges in Guard-Dateien den Inhalt lesen — 2.20 hat aus zwei Keychain-Implementierungen still einen Hybrid gebaut
3. Schnelltest nach dem Merge: `grep -rln "FORK PATCH" Makefile LocalBuild.xcconfig VoiceInk/` muss die vier Dateien der Tabelle plus `AIPrompts.swift` und `CustomPrompt.swift` listen; `grep -rl LOCAL_BUILD VoiceInk/ --include="*.swift"` muss `UpdaterViewModel.swift` enthalten
4. `make local` → `** BUILD SUCCEEDED **`; Signatur prüfen: `codesign -dvvv /Applications/VoiceInk.app` muss `Authority=Apple Development` und `TeamIdentifier=86UWZN67H8` zeigen (nicht `adhoc`); dann Praxistest: Diktat, Gemini verbunden, Dashboard ohne Lizenzhinweis, kein Update-Hinweis, Offline-Fallback einmal provozieren (WLAN aus)

## Kontext

- Zielhardware: MacBook Pro M1, macOS 14.4+
- Latenz-Ziele: BAUPLAN Abschnitt 3 · App-weite Definition of Done: BAUPLAN Abschnitt 7

## Build (Stand 2026-09-20, Xcode 27.0)

- Build-Befehl: `make local` — baut **Release** (seit Upstream 2.20; vorher Debug), signiert mit der automatisch erkannten Apple-Development-Identity (stabile Signatur → TCC-Berechtigungen überleben Rebuilds) und installiert nach `/Applications/VoiceInk.app` (Fork-Patch; Upstream kopiert nach `~/Downloads`). Bei mehreren Identities: `LOCAL_CODESIGN_IDENTITY=<SHA> make local`
- Voraussetzungen (einmalig bzw. nach jedem Xcode-Major-Update): Xcode als aktives Developer-Verzeichnis (`xcode-select -p` → `/Applications/Xcode.app/...`), Lizenz akzeptiert (`sudo xcodebuild -license accept` — muss der User ausführen), `cmake` (Homebrew), Metal Toolchain (`xcodebuild -downloadComponent MetalToolchain`, ~840 MB, kein sudo — Xcode 26+ liefert den Metal-Compiler nicht mehr mit; mlx-swift braucht ihn). Xcode 27 hat am 2026-09-20 beides erneut verlangt
- `-skipPackagePluginValidation -skipMacroValidation` sind seit 2.20 Upstream-Standard (kein Fork-Patch mehr); `VoiceInk.local.entitlements` trägt `disable-library-validation`, damit ad-hoc-signierte Frameworks laden
- whisper.cpp wird einmalig nach `~/VoiceInk-Dependencies/` geklont und als XCFramework gebaut (danach gecacht, `make clean` löscht es). FluidAudio kommt seit 2.20 als Remote-SPM-Package
- Erste Builds laden SPM-Abhängigkeiten — Geduld (voller Release-Build auf dem M1 ~15 Min). Für schnelle Iteration den `xcodebuild`-Aufruf aus dem `local`-Target direkt nutzen (ohne das vorangehende `rm -rf .local-build`), danach `make install-local`
- Achtung bei Pipes: `xcodebuild ... | tail` maskiert den Exit-Code — Erfolg immer an `** BUILD SUCCEEDED **` bzw. am App-Bundle verifizieren
- Xcode-27-Rauschen im Log (`DVTCoreDeviceCore`-Plug-in, `CoreSimulator is out of date`) betrifft nur iOS-Simulator-Support und ist für den macOS-Build irrelevant

## Code-Landkarte je Feature (Stand 2.20, Quellbaum seit Upstream-Reorg nach Features/Infrastructure/App)

- **F1 Record-Modus**: `Features/Shortcuts/Coordination/RecordingShortcutManager.swift` kennt `toggle`, `pushToTalk` und `hybrid`; Event-Tap in `ShortcutMonitor.swift` daneben. Seit 2.20 nativ auch **Maustasten** als Shortcut (`Features/Shortcuts/Models/Shortcut.swift`, Recorder-UI `Features/Shortcuts/Views/ShortcutRecorder.swift`) — Kandidat, um den BTT-Umweg aus F9 abzulösen
- **F2 Indikator**: `Features/Recording/Presentation/` (MiniRecorderPanel/MiniWindowManager, NotchRecorderPanel/NotchWindowManager), Views in `Features/Recording/Views/`, Wellenform `Features/Recording/Components/AudioVisualizerView.swift`
- **F3 Notifications/Fail-Open**: `Features/Recording/Workflows/TranscriptionPipeline.swift` behält bei Enhancement-Fehler den Raw-Text; `App/Notifications/NotificationManager.swift`
- **F4 Retention**: `Infrastructure/Persistence/Cleanup/TranscriptionAutoCleanupService.swift` (`transcriptionRetentionMinutes`), `AudioCleanupManager.swift` daneben; Settings-UI `Features/History/Views/HistorySettingsPanel.swift` (Fork: 30-Tage-Option)
- **F5 Content-Aware**: `Infrastructure/SystemIntegration/ScreenCapture/ScreenCaptureService.swift` (aktives Fenster), `Infrastructure/SystemIntegration/Context/ActiveWindowService.swift`, `Features/Recording/Context/RecordingContextSnapshot.swift`; Toggles + Hinweis in `Features/Modes/Views/ModeConfigFormView.swift`
- **F7 Offline-Fallback**: `Features/Enhancement/Workflows/AIEnhancementService.swift` (Kaskade), `Infrastructure/Providers/Enhancement/Ollama/OllamaService.swift` (num_ctx/keep_alive/prewarm), `Infrastructure/SystemIntegration/Network/NetworkStatusService.swift`, Badge `Features/Recording/Views/OfflineIndicatorBadge.swift`; Toggle in `Features/ModelLibrary/Views/ModelSettingsPanel.swift`
- **F8 Berechtigungen**: `Features/Settings/Views/PermissionsSettingsSection.swift`, eingehängt in `SettingsView.swift` daneben
- **STT**: `Infrastructure/Providers/Transcription/` — `FluidAudio/` (Parakeet), `Whisper/`, `Cloud/`, `AppleSpeech/`, `TranscribeCpp/`
- **Enhancement**: `Features/Enhancement/State/AIService.swift` (Provider-Enum, Modell-Listen, `ollamaBaseURL`), Request-Routing `Infrastructure/Providers/Enhancement/Chat/AIChatCompletionService.swift` (`performChatCompletion`), Timeouts/Retries `Infrastructure/Providers/Enhancement/EnhancementRequestSettings.swift`
- **Local-Build-Guards**: `Infrastructure/Credentials/KeychainService.swift` (Upstream), `Features/Licensing/State/LicenseViewModel.swift` (Upstream), `App/VoiceInk.swift` CloudKit (Upstream), `App/Updates/UpdaterViewModel.swift` (**Fork**)
- Upstream ist deutlich weiter als die BAUPLAN-Annahmen (Aug 2026) — vor jedem Feature erst den Ist-Stand im Code prüfen, dann bauen
