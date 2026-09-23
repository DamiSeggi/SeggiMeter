# SeggiMeter

Webanwendung zur Echtzeit-Visualisierung von Wortwolken (Live Word Clouds) für das Modul 223 (*Multi-User-Applikationen objektorientiert realisieren*).

## Funktionsübersicht

SeggiMeter ermöglicht es Administratoren, Lobbies mit Fragestellungen zu erstellen, in denen Nutzer in Echtzeit Begriffe einreichen können. Die Abgaben werden dynamisch als Wortwolke aggregiert und dargestellt.

## Installation und Betrieb

*Voraussetzung: Ruby und Bundler sind auf dem System installiert*

1. **Abhängigkeiten installieren:**

   ```bash
   bundle install
   ```

2. **Datenbank aufsetzen & Seeds einspielen:**

   ```bash
   bin/rails db:setup
   ```

   *(Erstellt die Demo-Accounts `admin` / `password1234` sowie `damian` / `password1234`)*

3. **Server starten:**

   ```bash
   bin/rails server
   ```

4. **Aufruf im Browser:** [http://localhost:3000](http://localhost:3000)

## Architektur & Kernkonzepte

| Konzept | Beschreibung |
|---|---|
| **Authentifizierung & Rechte** | Passwort-Sicherheit mit `bcrypt`. Geschütztes Admin-Panel (`/admin`) mit Schutz vor Selbstlöschung und Rechteentzug. |
| **Transaktionssicherheit** | Atomare Speicherung von Wortabgabe und ActivityLog (ActiveRecord::Base.transaction) mit automatischem Rollback bei Fehlern. |
| **Echtzeit-Aktualisierung** | Synchronisation der Wortwolken via Hotwire (Turbo Streams / WebSockets) ohne Re-Loads. |
| **Pessimistic Locking** | Schutz vor zeitgleichen Schreibzugriffen beim Bearbeiten von Lobbies mittels `lobby.with_lock`. |
| **Audit Trail** | Protokollierung aller relevanten System- und Benutzeraktionen im `ActivityLog`. |

## Testabdeckung

Ausführen aller Unit-, Integration- und Transaktionstests:

```bash
bin/rails test
```

Deckt Models, Controller-Rechte, atomare Transaktionen (3-Wörter-Limit), DB-Locking sowie vollständige Multi-User-Abläufe ab.

## Sonstige Infos

- Weitere Infos / Doku in abgegebener Projektdokumentation
- Github: https://github.com/DamiSeggi/SeggiMeter
- Entwickler: Damian Segginger