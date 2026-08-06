# Bauplan: Eigene Wispr-Flow-Alternative für macOS

Stand: August 2026 · Zielhardware: MacBook Pro (Apple Silicon, M1-Generation) · Arbeitsumgebung: `~/Developer/` mit Warp + Claude Code

---

## 1. Kernentscheidung: Fork statt Eigenbau

Die Basis ist ein **Fork von VoiceInk** (github.com/Beingpax/VoiceInk) — eine native Swift/SwiftUI-App unter GPL v3, die sich kostenlos aus dem Quellcode bauen lässt (BUILDING.md im Repo). Der Entwickler erlaubt Forks für den Eigengebrauch ausdrücklich, nimmt aber keine Pull Requests an.

Warum das die richtige Basis ist: VoiceInk deckt geschätzt **85–90 % deiner Feature-Liste bereits ab** — inklusive der zwei Punkte, die im Eigenbau am teuersten wären (Screen-Kontext und Power Mode). Ein Eigenbau von null wäre bei deinem Feature-Umfang ein Projekt von 100+ Stunden; der Fork bringt dich in einem Bruchteil davon zu einem lauffähigen Stand, und du investierst deine Zeit in die Feinheiten, die den Unterschied machen.

### Feature-Abgleich: Deine Anforderungen vs. VoiceInk

| Deine Anforderung | Status in VoiceInk | Aufwand |
|---|---|---|
| Konfigurierbare Funktionstasten (Hotkeys) | ✅ Vorhanden: globale Shortcuts inkl. Push-to-Talk und Abbruch-Taste, frei belegbar | 0 — konfigurieren |
| Eigenes Wörterbuch | ✅ Personal Dictionary: eigene Wörter, Fachbegriffe, Ersetzungsregeln | 0 — befüllen |
| Custom-Instruktionen für Weiterverarbeitung | ✅ Enhancement Modes: eigene AI-Prompts je Kontext (E-Mail, Chat, Social Post), umschaltbar | 0 — deine Wispr/Superwhisper-Prompts einpflegen |
| Text an Cursor einfügen, native Bedienung | ✅ Kernfunktion | 0 |
| **Toggle: Verarbeitung überspringen** (Raw direkt einfügen) | ✅ AI-Enhancement ist pro Modus an-/abschaltbar; ein "Raw-Modus" ohne Prompt ist trivial anlegbar | 0–1 h (ggf. eigenen Hotkey dafür belegen) |
| **Toggle: Halten vs. Start/Stopp-Druck** | ⚠️ Push-to-Talk vorhanden; Umschalt-Logik (einmal drücken = Start, erneut = Stopp) prüfen und ggf. nachrüsten | 0–4 h |
| **Wellenform-Indikator mittig über dem Dock** | ⚠️ Ein Recorder-Indikator existiert; Position/Optik exakt wie bei Wispr Flow anpassen | 3–8 h |
| **Grammatik-Korrektur + Schachtelsätze aufteilen** | ✅ Reine Prompt-Sache in deinen Enhancement Modes | 0 (Prompt-Arbeit, siehe Abschnitt 4, Phase 2) |
| **Content-Aware (Bildschirm-Kontext für Namen/Apps)** | ✅ Contextual Awareness vorhanden. Beschlossene Anpassung: Kontext auf das **aktive Fenster** beschränken, Toggle zum An-/Abschalten + Hinweis auf sensible Daten in den Einstellungen | 1–4 h (Fenster-Beschränkung, Toggle, Hinweis) — Abschnitt 6 lesen! |
| API-Keys in den Einstellungen | ✅ BYOK für OpenAI / Anthropic / Google / Groq | 0 |
| **Notification bei Fehlschlag** | ⚠️ Prüfen; falls nicht vorhanden: `UNUserNotificationCenter`-Aufruf in die Fehlerpfade einbauen | 2–4 h |
| **History-Tab (raw + verarbeitet)** | ✅ Durchsuchbare History inkl. gespeicherter Audioaufnahmen | 0 |
| **Speicherdauer einstellbar/abstellbar** | ⚠️ Prüfen; falls nur an/aus: Retention-Regel (z. B. "nach X Tagen löschen") nachrüsten | 2–6 h |
| UI/UX auf Wispr-Flow-Niveau | ⚠️ VoiceInk ist solide und nativ, aber schlichter als Wispr. Feinschliff = größter offener Posten | 10–30 h (iterativ, optional) |

**Legende Aufwand:** mit Claude Code als Pair-Programmer, Swift-Kenntnisse nicht vorausgesetzt aber Einarbeitung eingerechnet.

---

## 2. Tech-Stack

| Ebene | Technologie | Begründung |
|---|---|---|
| App-Shell | **VoiceInk-Fork** — Swift / SwiftUI, macOS 14.4+, Apple Silicon | Nativ, GPL v3, kostenlos baubar, Feature-Deckung s. o. |
| STT-Engine 1 (Default) | **Parakeet TDT 0.6B v3** via FluidAudio (CoreML, Neural Engine) | Schnellste lokale Option, 25 EU-Sprachen inkl. Deutsch, ~0,6 GB RAM |
| STT-Engine 2 (Fallback) | **Whisper large-v3-turbo** via whisper.cpp (in VoiceInk integriert) | Für Flüstern, Lärm, hart auf Deutsch fixierbar (kein Auto-Language-Kippen bei Anglizismen) |
| LLM-Cleanup (online, Default) | **Gemini 3.1 Flash-Lite** per API-Key in den Einstellungen. Provider/Modell-ID als konfigurierbares Setting — Groq bleibt als latente Ausweichroute im Dropdown, ohne aktiv gepflegt zu werden | Sub-Sekunden-Latenz, auf Umformulieren/Strukturieren destilliert, gutes Deutsch, Kosten im Cent-Bereich |
| LLM-Cleanup (offline, Fallback) | **Ollama + Qwen3 4B** (lokaler Server auf `localhost:11434`) | Läuft ohne Netz; schwächer bei Selbstkorrekturen, ausreichend für Füllwörter + Interpunktion |
| Screen-Kontext | VoiceInk Contextual Awareness (Accessibility/Screen-Capture + lokale Texterkennung) | Löst dein Namens-/App-Korrektur-Szenario |
| Einfügen am Cursor | Accessibility API / simulierte Tastatureingabe (in VoiceInk enthalten) | Systemweit, app-unabhängig |
| Persistenz (History, Settings) | App-interner Speicher von VoiceInk (lokale Datenbank + Audio-Dateien) | Bleibt vollständig auf dem Gerät |
| Entwicklung | **Xcode 16+** zum Bauen, **Claude Code in Warp** für alle Anpassungen, Git-Repo in `~/Developer/projects/` | Passt in deine bestehende Workspace-Architektur |

**RAM-Budget auf 16 GB (falls dein M1 16 GB hat):** Parakeet ~0,6–1 GB + Whisper turbo (nur bei Bedarf geladen) ~1,5 GB + Qwen3 4B via Ollama ~3 GB. Ollama entlädt Modelle nach ~5 Min. Leerlauf automatisch. Kritisch wird es nur, wenn du gleichzeitig DaVinci Resolve mit großem Projekt offen hast — dann Offline-LLM deaktivieren und rein Cloud fahren. Mit 32 GB ist alles entspannt.

---

## 3. Lokal vs. Cloud — was wohin gehört und warum

| Pipeline-Schritt | Ort | Internet nötig? | Begründung |
|---|---|---|---|
| Hotkey, Audio-Aufnahme, Indikator | **Zwingend lokal** | Nein | Systemfunktionen, keine Alternative |
| Transkription (STT) | **Lokal (Parakeet/Whisper)** | Nein | Auf M1 schneller als jeder Cloud-Roundtrip, Audio verlässt nie das Gerät. Cloud-STT (z. B. AssemblyAI) nur als optionale Route für Dialekt-Anwender — kostet dann ~0,2–0,4 ct/Min. |
| Wörterbuch-Ersetzungen | **Zwingend lokal** | Nein | Deterministisch, <1 ms |
| LLM-Weiterverarbeitung | **Cloud (Default), lokal (Fallback)** | Ja (Default) | Der Qualitätsunterschied bei Grammatik, Satz-Splitting und Selbstkorrekturen ist deutlich. Es gehen nur Text-Token raus, kein Audio. Offline-Fallback springt automatisch ein, wenn kein Netz. |
| Screen-Kontext | **Erfassung lokal; Achtung: Inhalt geht als Prompt-Kontext an das Cloud-LLM** | — | Wichtigster Datenschutz-Punkt des ganzen Projekts → Abschnitt 6 |
| Einfügen, History | **Zwingend lokal** | Nein | — |

**Verhalten ohne Internet:** App bleibt voll funktionsfähig. Transkription unverändert schnell; Weiterverarbeitung fällt auf Qwen3 4B zurück (spürbar: 60-s-Nachricht ~4 s statt ~1 s, Selbstkorrekturen unzuverlässiger). Der Raw-Toggle funktioniert immer.

**Latenz-Zielwerte (ab Loslassen der Taste, WLAN):**

| Szenario | Ziel |
|---|---|
| Kurzdiktat, Raw-Toggle | ~0,3 s |
| 60-s-Nachricht, Cloud-Cleanup | ~0,5–1,0 s |
| 5-Min-Nachricht, Cloud-Cleanup | ~1,0–2,0 s |
| 60-s-Nachricht, offline (Qwen3 4B) | ~4–6 s |

Zum Vergleich: Wispr Flow liegt in Tests bei Ø ~1,1 s (kurz) und skaliert bei langen Nachrichten mit dem Audio-Upload.

---

## 4. Schritt-für-Schritt: Aufsetzen → Validieren → Implementieren

### Phase 0 — Voraussetzungen (½ Abend, ~1–2 h)

1. Xcode aus dem Mac App Store installieren (~12 GB Download — nebenbei laufen lassen). Kostenlose Apple-ID reicht; **kein** bezahlter Developer-Account nötig, solange die App nur auf deinem Mac läuft.
2. Xcode einmal starten, Lizenz bestätigen, Command Line Tools installieren lassen.
3. Ollama installieren: `brew install ollama`, dann `ollama pull qwen3:4b`.
4. API-Key anlegen (kostenlos in <10 Min.): Google AI Studio für Gemini unter aistudio.google.com. Optional als kalte Reserve: Groq unter console.groq.com. Keys sicher ablegen (z. B. in deinem Passwort-Manager, nie im Repo).

### Phase 1 — VoiceInk unverändert bauen und testen (1 Abend, ~2–4 h)

1. Fork des Repos in deinen GitHub-Account, dann Repo-Setup nach Abschnitt 8.1 (Clone nach `~/Developer/projects/`, Upstream-Remote, Workspace-`.gitignore`, `docs/`-Ordner). Ab jetzt gilt: `main` bleibt immer baufähig, Feature-Arbeit nur in Branches/Worktrees.
2. `BUILDING.md` folgen: Projekt in Xcode öffnen, Signing auf "Sign to Run Locally" / dein persönliches Team stellen, bauen (⌘R). Erste Builds ziehen Swift-Package-Abhängigkeiten — Geduld.
3. Beim ersten Start alle Berechtigungen erteilen: Mikrofon, Bedienungshilfen (fürs Einfügen), Bildschirmaufnahme (für Contextual Awareness).
4. Parakeet-Modell in den App-Einstellungen herunterladen, 10 Test-Diktate machen. **Erst weitermachen, wenn der unveränderte Stand stabil läuft** — sonst debuggst du später an zwei Baustellen gleichzeitig.
5. Einen `CLAUDE.md` im Projektordner anlegen (Architektur-Notizen, deine Konventionen), damit Claude Code ab Phase 4 sauber arbeitet.

**Meilenstein:** Diktat → Text am Cursor, rein lokal, ohne eigene Änderungen.

### Phase 2 — Konfigurieren statt Coden (1 Abend, ~2–3 h)

1. API-Key in den Einstellungen hinterlegen, Gemini 3.1 Flash-Lite als Enhancement-Provider wählen, Ollama (Qwen3 4B) als Offline-Provider eintragen.
2. Enhancement Modes anlegen:
   - **Standard:** dein bestehender Polish-Prompt aus Wispr Flow, erweitert um: Grammatik korrigieren; Schachtelsätze in kurze Hauptsätze aufteilen; Selbstkorrekturen auflösen (letztgenannte Version gilt); Füllwörter entfernen; Ton beibehalten, nichts hinzuerfinden; nur den finalen Text ausgeben.
   - **LinkedIn:** dein Superwhisper-LinkedIn-Prompt.
   - **Raw:** Enhancement aus — das ist dein Skip-Toggle, per Hotkey/Modus-Wechsel erreichbar.
3. Wörterbuch befüllen: Kundennamen, "neue balan", Tool-Namen, deine typischen Anglizismen. Diese Liste wächst danach im Alltag — pflege sie konsequent, sie ist dein größter Genauigkeits-Hebel.
4. Hotkeys belegen — Defaults lt. Spezifikation: **Fn = Aufnahme**, **Esc = Aufnahme abbrechen**. Wichtig: In Systemeinstellungen → Tastatur die Option „Beim Drücken der Fn-Taste" auf „Keine Aktion" stellen, sonst kollidiert Fn mit macOS-Diktat/Emoji-Picker. Zweiten Hotkey für den Raw-Modus nach Geschmack belegen.

**Meilenstein:** Funktional bereits eine personalisierte Wispr-Alternative — noch ohne deine Spezial-Features.

### Phase 3 — Validieren mit eigenem Test-Set (½ Tag, ~3–5 h, vor jeder größeren Änderung wiederholbar)

1. Test-Set aufnehmen, je 3 Aufnahmen (Voice Memos, echte Formulierungen aus deinem Alltag):
   Hochdeutsch sauber · Anglizismen-Mix · Selbstkorrekturen (dein Freitag/Montag-Beispiel) · Umgebungsgeräusche (Coworking/Straße) · Flüstern.
2. Jede Aufnahme durch beide Ziel-Konfigurationen jagen: Parakeet + Gemini Flash-Lite (Default) und Parakeet + Qwen3 4B (Offline-Backup). Für Flüstern/Lärm zusätzlich Whisper-Engine testen.
3. Bewerten in einer simplen Tabelle (Numbers/Notion): Wortfehler im Raw-Transkript · Cleanup-Qualität 1–5 · gefühlte Latenz (Stoppuhr ab Tastenloslassen) · Fälle, in denen das LLM Inhalt verfälscht hat.
4. Entscheidungen ableiten: ob der Qualitätsabstand zwischen Gemini- und Offline-Cleanup akzeptabel ist, ob Parakeet bei deinem Anglizismen-Mix stabil bleibt (wenn es mitten im Satz die Sprache wechselt → Whisper mit fixiertem Deutsch als Default erwägen), ob Flüstern akzeptabel ist.
5. macOS-Mikrofonmodus "Stimmisolation" aktivieren und Lärm-Tests wiederholen — oft ein Gratis-Sprung nach vorn.

**Meilenstein:** Du weißt datenbasiert, welche Konfiguration für *dich* gewinnt — nicht laut Leaderboard.

### Phase 4 — Custom-Implementierung mit Claude Code (2–4 Wochen nebenbei, ~10–25 h)

Reihenfolge nach Nutzen pro Stunde:

1. **Fehlschlag-Notifications** (2–4 h): In den Fehlerpfaden von Transkription und Enhancement eine macOS-Notification auslösen; Raw-Text bei Enhancement-Fehler trotzdem einfügen (Fail-Open statt Textverlust).
2. **Toggle Halten vs. Start/Stopp** (0–4 h): Prüfen, ob vorhanden; sonst Umschalt-Option in Settings + Hotkey-Handler ergänzen.
3. **History-Retention** (2–6 h): Einstellung "Speicherdauer: aus / 1 Tag / 7 Tage / 30 Tage / unbegrenzt" + Lösch-Job beim App-Start.
4. **Wellenform-Indikator** (3–8 h): Vorhandenen Recorder-Indikator auf Position "mittig über dem Dock" bringen (frei schwebendes, nicht aktivierbares Fenster auf Dock-Höhe), Wellenform aus dem Audio-Pegel speisen, Ein-/Ausblend-Animation.
5. **UI-Feinschliff** (10–30 h, iterativ und optional): Settings aufräumen, History-Tab polieren, Animationen. Hier liegt der Löwenanteil des "Wispr-Gefühls" — und es ist der Teil, den du endlos treiben kannst. Empfehlung: erst nach 2 Wochen Alltagsnutzung priorisieren, dann weißt du, was dich wirklich stört.

Arbeitsweise je Feature: Branch anlegen → Claude Code mit präziser Aufgabenbeschreibung → bauen → am Test-Set gegenprüfen → mergen. Kleine Schritte, das Repo ist fremder Code.

### Phase 5 — Dauerbetrieb (1 h)

App als Login-Item eintragen, ein Alias/Skript für Rebuilds, fertig. Updates aus dem Original-Repo holst du dir bei Bedarf per `git fetch upstream` + Rebase — siehe Risiko "Fork-Pflege" unten.

---

## 5. Was es dich kostet

### Einmalig (Zeit)

| Posten | Aufwand |
|---|---|
| Phase 0–2: lauffähige, personalisierte App | **~6–9 h** (2–3 Abende) |
| Phase 3: Validierung | ~3–5 h |
| Phase 4: deine Spezial-Features | ~10–25 h |
| **Gesamt bis "fertig nach deiner Definition"** | **~20–40 h** |

Zum Vergleich: Eigenbau von null in Swift mit deinem Feature-Umfang: realistisch 80–150 h.

### Monatlich (Geld)

Annahme: ~45 Min. Diktat/Tag an 22 Tagen ≈ 16 h/Monat, inkl. Screen-Kontext-Overhead beim LLM.

| Konfiguration | Kosten/Monat |
|---|---|
| **Default:** Parakeet + Gemini 3.1 Flash-Lite | **~1–3 €** (inkl. Fenster-Kontext-Overhead; selbst bei sehr intensiver Nutzung weit unter 10 €) |
| **Offline-Backup:** alles lokal (Parakeet + Qwen3 4B) | **0 €** |
| Latente Reserve: Groq statt Gemini (Dropdown-Wechsel) | ~0–0,50 € (Free Tier) |
| Optionale Cloud-STT-Route (AssemblyAI) für Dialekt-Anwender | +~2–4 € je 10 h Audio darüber |
| Strom, Apple-Account, Lizenzen | 0 € |

Wispr Flow Pro als Referenz: ~15 $/Monat = ~170 €/Jahr.

---

## 6. Risiken & Probleme, denen du begegnen wirst

**1. Screen-Kontext × Cloud-LLM = dein größtes Datenschutzthema.** Contextual Awareness schickt Bildschirm-/Clipboard-Text als Prompt-Kontext mit — bei Cloud-Enhancement landet damit potenziell Kundenmaterial beim LLM-Anbieter. Beschlossene Entschärfung: Kontext auf das **aktive Fenster** beschränken (weniger sensible Daten, weniger Token, präziserer Kontext als der Vollbildschirm), dazu ein **Toggle** zum Aktivieren/Deaktivieren und ein **Hinweis in den Einstellungen**, der über die Übertragung potenziell sensibler Inhalte informiert. Zusätzlich empfohlen: für sensible Kundenarbeit einen Modus „lokal + ohne Kontext"; langfristig Kontext auf eine extrahierte Begriffsliste (Namen, App-Titel) reduzieren statt Voll-Text — lohnendes Claude-Code-Feature für später.

**2. Modell- und API-Wandel.** Cloud-Modelle werden umbenannt, abgekündigt, umbepreist (Google hat z. B. Gemini 2.0 Flash Mitte 2026 abgeschaltet; Free-Tier-Limits ändern sich regelmäßig). Gegenmaßnahmen: Modell-IDs und Endpoints ausschließlich als konfigurierbare Settings, nie hart im Code — damit ist ein Provider-Wechsel (z. B. auf Groq) ein Dropdown statt einer Code-Änderung; lokale Modelle altern nicht — dein Offline-Pfad ist zugleich deine Versicherung. Und er ist dein Endspiel: Sobald ein lokales Modell die Cleanup-Qualität von Flash-Lite erreicht, stellst du den Default auf Ollama um und die App läuft dauerhaft zu 0 € voll lokal — ohne eine Zeile Code anzufassen.

**3. Fork-Pflege.** Das Original entwickelt sich weiter, nimmt aber keine PRs an. Je mehr du änderst, desto zäher werden Rebases auf neue Upstream-Versionen. Gegenmaßnahmen: eigene Änderungen klein, gekapselt und dokumentiert halten (im CLAUDE.md des Projekts festhalten, welche Dateien du angefasst hast); Upstream-Updates nur gezielt ziehen, wenn sie dir etwas bringen — nicht reflexartig. Akzeptiere: ab einem gewissen Punkt ist es *deine* App, und das ist okay.

**4. macOS-Updates brechen Berechtigungen.** Nach großen macOS-Upgrades verlieren selbstgebaute Apps gern Bedienungshilfen-/Bildschirmaufnahme-Rechte, oder ein neues Xcode wird fällig. Symptom: Einfügen oder Kontext funktioniert plötzlich nicht. Fix ist Routine (Berechtigungen neu erteilen, ggf. neu bauen), aber plane nach jedem Major-Update 30–60 Min. ein.

**5. Praxistests werden Schwächen finden — geplant.** Flüstern bleibt die schwächste Disziplin jedes lokalen Modells; Parakeets automatische Spracherkennung kann bei dichten Anglizismen kippen; das LLM wird gelegentlich echten Inhalt als Versprecher "wegputzen". Deshalb: Raw-Transkript immer in der History behalten (hast du ohnehin spezifiziert), Fail-Open bei Enhancement-Fehlern, und das Test-Set aus Phase 3 vor jeder Konfigurationsänderung erneut laufen lassen.

**6. RAM auf 16 GB.** Siehe Abschnitt 2 — im Normalbetrieb unkritisch, in Kombination mit Resolve-Sessions Offline-LLM pausieren. Auf 32 GB kein Thema.

**7. Internetabhängigkeit.** Nur der Enhancement-Schritt hängt am Netz, und er degradiert kontrolliert (Offline-LLM → Raw). Im Zug/Flugzeug funktioniert alles, nur die Textpolitur wird einfacher.

**8. GPL v3.** Für private Nutzung: keinerlei Pflichten. Erst wenn du die App an Dritte weitergibst (auch an Coaching-Kunden!), musst du den Quellcode deines Forks offenlegen und unter GPL v3 lizenzieren. Verteilen an andere erfordert zudem Notarisierung → dann doch Apple-Developer-Account (99 $/Jahr). Solange die App nur auf deinem Mac läuft: 0 € und null Auflagen.

---

## 7. Definition of Done

Die App gilt als fertig, wenn: (1) Hotkey in beiden Modi (Halten/Toggle) zuverlässig auslöst, mit Wellenform-Indikator über dem Dock; (2) das Latenz-Ziel aus Abschnitt 3 in 9 von 10 Alltags-Diktaten gehalten wird; (3) dein Test-Set in der Ziel-Konfiguration ohne inhaltliche Verfälschungen durchläuft; (4) Wörterbuch, Modi, API-Keys, History-Retention und Raw-Toggle ohne Code-Änderung in den Settings bedienbar sind; (5) Fehlschläge eine Notification auslösen und nie Text verlieren; (6) die App eine Woche Alltagsnutzung ohne Neustart übersteht.

---

## 8. Übergabe an Claude Code & Arbeitsmodell

Der Chat lässt sich nicht 1:1 „umziehen" — dieses Dokument **ist** der Umzug. Es lebt im Repo (`docs/BAUPLAN.md`), jede Session referenziert es per Prompt; du musst nichts manuell anhängen. Pro Session gilt: **genau ein Feature als Auftrag.**

### 8.1 Einmalig: Repo-Setup (Teil von Phase 1)

1. VoiceInk auf GitHub in deinen Account forken (behält den Upstream-Bezug fürs spätere Nachziehen von Updates), dann:
   ```
   git clone https://github.com/<dein-account>/VoiceInk.git ~/Developer/projects/personal/voice-to-text-app
   cd ~/Developer/projects/personal/voice-to-text-app
   git remote add upstream https://github.com/Beingpax/VoiceInk.git
   ```
2. Da `~/Developer/` selbst ein Git-Repo ist: `projects/personal/voice-to-text-app/` in die Workspace-`.gitignore` eintragen — der Fork sichert sich über GitHub selbst, verschachtelte Repos machen nur Ärger.
3. Projektdateien einsetzen (liegen im Setup-Paket bei, siehe SETUP.md): `CLAUDE.md` in den Repo-Root, `docs/` mit `BAUPLAN.md` und `FEATURES.md` daneben — dann committen.
4. Branch-Regeln ab sofort: **`main` ist immer baufähig und validiert.** Feature-Arbeit ausschließlich in Branches (`feature/f1-record-mode` …), Merge nur nach erfülltem DoD.

### 8.2 Sessions & Worktrees: sequenziell vs. parallel

**Phase 1–3 strikt sequenziell auf `main`** — bauen, konfigurieren, validieren ist eine Baustelle, nicht drei.

**Ab Phase 4 Worktrees für Parallelarbeit:**
```
git worktree add ../vtt-f2-indicator -b feature/f2-indicator
cd ../vtt-f2-indicator && claude
```
Jeder Worktree ist ein vollwertiges Arbeitsverzeichnis mit eigenem Branch — zwei Claude-Code-Sessions können so gleichzeitig laufen, ohne sich Dateien streitig zu machen. Nach dem Merge: `git worktree remove ../vtt-f2-indicator` und Branch löschen.

**Zwei ehrliche Praxis-Grenzen:**
- **Maximal 2 parallele Sessions.** Xcode/SPM löst Paketabhängigkeiten je Worktree separat auf, und zwei gleichzeitige Builds bremsen sich auf dem M1 spürbar gegenseitig. Der beste Parallel-Mix ist deshalb oft: 1 Code-Feature + 1 Nicht-Code-Session (Enhancement-Prompts verfeinern, Test-Set auswerten, Wörterbuch pflegen).
- **Parallel nur bei disjunkten Dateibereichen.** Mehrere deiner Features berühren dieselbe Settings-Oberfläche — die parallel zu bearbeiten erzeugt Merge-Konflikte statt Tempo. Die Matrix in 8.3 regelt, was zusammen laufen darf.

### 8.3 Feature-Matrix: Sessions, Parallel-Gruppen, Definition of Done

| ID | Feature | Branch | Berührt | Parallel-Gruppe | Definition of Done |
|---|---|---|---|---|---|
| F1 | Toggle Halten vs. Start/Stopp | `feature/f1-record-mode` | Hotkey-Handler, Settings-UI | A (sequenziell) | Beide Modi per Settings-Toggle wählbar; Fn startet/stoppt in beiden Modi korrekt; Esc bricht ab; 10 Diktate je Modus fehlerfrei |
| F2 | Wellenform-Indikator über Dock | `feature/f2-indicator` | eigenes Overlay-Fenster, Audio-Pegel | B (parallelisierbar) | Erscheint bei Aufnahme mittig über dem Dock; Wellenform reagiert sichtbar auf die Stimme; blendet animiert aus; stiehlt nie den Fokus; verhält sich am externen Monitor korrekt |
| F3 | Fehlschlag-Notifications + Fail-Open | `feature/f3-notifications` | STT-/Enhancement-Fehlerpfade | B (parallelisierbar) | Bei simuliertem Fehler (API-Key entfernt / Netz aus) erscheint eine Notification UND der Raw-Text wird trotzdem eingefügt; in 5 Fehltests kein Textverlust |
| F4 | History-Retention | `feature/f4-retention` | History-Speicher, Settings-UI | A (sequenziell) | Einstellung aus / 1 / 7 / 30 Tage / unbegrenzt; Lösch-Job beim App-Start entfernt Alt-Einträge inkl. Audio; „aus" speichert nichts Neues |
| F5 | Content-Aware: aktives Fenster + Toggle + Hinweis | `feature/f5-context-window` | Kontext-Erfassung, Settings-UI | A (sequenziell) | Kontext nachweislich nur aus dem aktiven Fenster (Log-Check); Toggle wirkt sofort; Hinweis zu sensiblen Daten in den Einstellungen sichtbar; Namens-Korrektur-Fall aus dem Test-Set besteht |
| F6 | UI-Feinschliff | `feature/f6-ui-polish` | app-weit | Solo, als Letztes | Subjektiv Wispr-Niveau; alle vorherigen DoDs weiterhin grün |

**Parallel-Regeln:** F2 + F3 (Gruppe B) dürfen gleichzeitig laufen — disjunkte Bereiche. F1, F4, F5 (Gruppe A) berühren alle die Settings-UI → **nacheinander**, Reihenfolge frei. F6 immer allein und ganz am Schluss. Ein B-Feature darf parallel zu einem A-Feature laufen.

**Globales DoD, zusätzlich für jedes Feature:** App baut ohne neue Warnings; Kurz-Testlauf mit 3 Aufnahmen aus dem Test-Set ohne Regression; `FEATURES.md` aktualisiert; Branch auf `main` gemergt.

### 8.4 Status-Dokumentation: `docs/FEATURES.md`

Die eine Quelle der Wahrheit für den Projektstand. **Jede Session aktualisiert sie als letzten Schritt** — so erfasst jede neue Session den Stand in 30 Sekunden, und dein Session-End-Skill hat einen festen Ankerpunkt. Vorlage:

```markdown
# Feature-Status
Letzte Aktualisierung: <Datum> · main-Stand: <Commit-Hash> · aktive Worktrees: <Liste oder "keine">

## F1 — Toggle Halten vs. Start/Stopp
Status: offen | in Arbeit (<Branch, Worktree-Pfad>) | im Test | done (<Datum, Merge-Commit>)
DoD: [ ] Settings-Toggle  [ ] beide Modi 10× fehlerfrei  [ ] Esc-Abbruch  [ ] Kurz-Test-Set ok  [ ] gemergt
Notizen: <Entscheidungen, betroffene Dateien, offene Punkte>

## F2 … F6 (identisches Schema)
```

Regel: **Kein Merge ohne vollständig abgehakte DoD-Zeile.** Halbfertiges bleibt im Branch und ist in den Notizen dokumentiert.

### 8.5 Session-Prompts

**Erst-Session (Phase 1):**
```
Lies zuerst docs/BAUPLAN.md vollständig — das ist die verbindliche Projekt-Referenz.

Kontext: Dieses Repo ist ein frischer Fork von VoiceInk (GPL v3). Ziel ist meine
persönliche Wispr-Flow-Alternative gemäß Bauplan. Wir setzen jetzt Phase 1 um.

Aufgaben für diese Session:
1. Verschaffe dir einen Überblick über Projektstruktur und BUILDING.md.
2. Hilf mir, das Projekt in Xcode baufähig zu machen (Signing: "Sign to Run Locally").
3. Lies CLAUDE.md und docs/FEATURES.md (liegen bereits im Repo) und ergänze in
   der CLAUDE.md Projekt-Spezifisches, das dir beim Erkunden auffällt
   (z. B. Build-Eigenheiten, relevante Dateipfade je Feature).
4. Trage den erfolgreichen Build als Phase-1-Fortschritt in docs/FEATURES.md ein.
5. Ändere in dieser Session noch keinen Feature-Code — erst bauen und verstehen.
```

**Feature-Session (Vorlage, für jede weitere Session):**
```
Lies docs/BAUPLAN.md (Abschnitte 1, 7 und 8) und docs/FEATURES.md.

Wir arbeiten in dieser Session ausschließlich an <F-ID: Titel>
im Worktree/Branch <Name>. Scope-Grenze: nur die in der Feature-Matrix
genannten Bereiche anfassen — keine Nebenbaustellen.

Am Ende der Session: docs/FEATURES.md aktualisieren (Status, DoD-Haken,
Notizen inkl. betroffener Dateien) und mir die noch offenen DoD-Punkte nennen.
```

Damit ist der Kreislauf geschlossen: Bauplan = Was und Warum · FEATURES.md = Stand und DoD · CLAUDE.md = Spielregeln je Session. Jede Session startet mit vollem Kontext und hinterlässt einen dokumentierten Stand.
