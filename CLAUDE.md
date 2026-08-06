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

## Build (Stand 2026-08-06)

- Build-Befehl: `make local` — ad-hoc Signing ohne Developer-Account, installiert direkt nach `/Applications/VoiceInk.app` (Fork-Patch; Upstream kopierte nach `~/Downloads`)
- Voraussetzungen (einmalig): Xcode als aktives Developer-Verzeichnis (`xcode-select -p` muss auf `/Applications/Xcode.app/...` zeigen), `cmake` (Homebrew), Metal Toolchain (`xcodebuild -downloadComponent MetalToolchain` — Xcode 26 liefert den Metal-Compiler nicht mehr mit; mlx-swift braucht ihn)
- Fork-Patch im Makefile: `local`-Target baut mit `-skipPackagePluginValidation -skipMacroValidation`, sonst scheitert der Headless-Build an der interaktiven Freigabe des mlx-swift-Plugins `CudaBuild`
- whisper.cpp wird einmalig nach `~/VoiceInk-Dependencies/` geklont und als XCFramework gebaut (danach gecacht, `make clean` loescht es)
- Erste Builds laden SPM-Abhaengigkeiten — Geduld. Fuer schnelle Iteration den `xcodebuild`-Aufruf aus dem `local`-Target direkt nutzen (ohne das vorangehende `rm -rf .local-build`)
- Achtung bei Pipes: `xcodebuild ... | tail` maskiert den Exit-Code — Erfolg immer an `** BUILD SUCCEEDED **` bzw. am App-Bundle verifizieren

## Code-Landkarte je Feature (Erkundung 2026-08-06)

- **F1 Record-Modus**: Upstream bereits vorhanden — `VoiceInk/Shortcuts/RecordingShortcutManager.swift` kennt `toggle`, `pushToTalk` und `hybrid`. Feature = verifizieren + Settings-UI pruefen, kaum Neubau
- **F2 Indikator**: `VoiceInk/Views/Recorder/` — MiniRecorderPanel/MiniWindowManager (Mini-Stil), NotchRecorderPanel/NotchWindowManager (Notch-Stil), `AudioVisualizerView.swift` (Wellenform existiert)
- **F3 Notifications/Fail-Open**: Weitgehend vorhanden — `Transcription/Engine/TranscriptionPipeline.swift` zeigt bei Enhancement-Fehler Notification und behaelt Raw-Text als finalText; `VoiceInk/Notifications/NotificationManager.swift`. Feature = Fehltests fahren, Luecken schliessen
- **F4 Retention**: Teilweise vorhanden — `Services/TranscriptionAutoCleanupService.swift` (`transcriptionRetentionMinutes`), `Views/Settings/AudioCleanupManager.swift`. Pruefen: Granularitaet aus/1/7/30/unbegrenzt + Audio-Loeschung
- **F5 Content-Aware**: `Services/ScreenCaptureService.swift` arbeitet bereits mit dem aktiven Fenster (FocusedWindowHint/findActiveWindow); dazu `Modes/ActiveWindowService.swift`, `Services/RecordingContextSnapshot.swift`. Pruefen: Toggle + Hinweis auf sensible Daten
- **STT**: `Transcription/FluidAudio/` (Parakeet via FluidAudio), `Transcription/Whisper/`, Cloud-Provider unter `Transcription/Cloud/`
- **Enhancement**: `Services/AIEnhancement/AIService.swift` — Provider-Enum inkl. Gemini und Ollama (`ollamaBaseURL` default `http://localhost:11434`), Modell-IDs als UserDefaults-Settings
- Upstream ist deutlich weiter als die BAUPLAN-Annahmen (Aug 2026) — vor jedem Feature erst den Ist-Stand im Code pruefen, dann bauen
