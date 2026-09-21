# SeggiMeter

> Interaktive Live-Word-Cloud-Anwendung für das **Modul 223 („Multi-User-Applikationen objektorientiert realisieren“)**.

---

## 📋 Übersicht

**SeggiMeter** ermöglicht es Moderatoren (Admins), interaktive Fragen als „Lobbies“ zu erstellen, und Teilnehmern, in Echtzeit bis zu 3 Begriffe zu einer Frage einzureichen. Die Begriffe werden live als dynamische Wortwolke visualisiert – je öfter ein Begriff genannt wird, desto prominenter und größer wird er dargestellt.

---

## 🚀 Schnellstart (Getting Started)

### 1. Abhängigkeiten & Setup
```bash
bundle install
bin/rails db:migrate
bin/rails db:seed
```

### 2. Server starten
```bash
bin/rails server
```
Die Anwendung ist danach unter [http://localhost:3000](http://localhost:3000) erreichbar.

### 3. Vorkonfigurierte Accounts (via Seed-Daten)
* **Administrator:**
  * Benutzername: `admin`
  * Passwort: `admin123`
* **Standard-Benutzer:**
  * Benutzername: `damian`
  * Passwort: `password123`
* **Auto-Registrierung:** Beliebiger neuer Benutzername + Passwort bei `/login` eingeben – der Account wird bei Klick auf `Enter` automatisch neu angelegt (`admin: false`).

---

## 🏛️ Architektur & Technische Kernkonzepte

### 1. Authentifizierung & Rollenberechtigung
* **Auto-Registration:** Beim Anmeldeformular (`/login`) prüft das System, ob der Benutzername existiert. Wenn nicht, wird der Account automatisch mit `admin: false` erstellt und die Session initialisiert.
* **Passwort-Sicherheit:** Verwendung von ActiveModel `has_secure_password` mit `bcrypt`.
* **Erster Admin:** Kann über `bin/rails console` (`User.find_by(name: "...").update!(admin: true)`) oder via Seeds gesetzt werden.
* **Admin-Panel (`/admin/users`):** Nur für Admins zugänglich. Kein Navigationslink im UI (Aufruf via direkter URL-Eingabe). Ermöglicht das Vergeben/Entziehen von Admin-Rechten sowie das Löschen von Benutzern. Selbstsperrung und Selbstlöschung sind gesperrt.

### 2. Transaktionen & 3-Wörter-Limit
* Die Wortabgabe erfolgt atomar innerhalb einer Datenbanktransaktion (`ActiveRecord::Base.transaction`).
* Es wird serverseitig garantiert, dass ein Benutzer maximal 3 Wörter pro Frage einreichen kann:
```ruby
ActiveRecord::Base.transaction do
  raise "Limit erreicht" if user.submissions.where(lobby_id: lobby.id).count >= 3
  lobby.submissions.create!(user: user, word: params[:word])
  ActivityLog.create!(user: user, action: "submitted_word")
end
```

### 3. Echtzeit-Word-Cloud (Hotwire / Turbo Streams)
* Bei jeder neuen Einreichung wird automatisch ein Turbo Stream an den Kanal `lobby_#{lobby.id}` gesendet (`after_create_commit` im `Submission`-Model).
* Alle verbundenen Clients sehen die Wortwolke und die aktualisierten Häufigkeiten ohne Seiten-Reload in Echtzeit.

### 4. Pessimistic DB Locking
* Beim Bearbeiten des Fragentitels durch einen Administrator wird der Datensatz pessimistisch auf DB-Ebene gesperrt (`lobby.with_lock`), um gleichzeitige Schreibzugriffe durch andere Admins zu verhindern.
* Zusätzlich wird `locked_by_id` gepflegt, um anderen Nutzern visuell anzuzeigen, wenn eine Frage gerade bearbeitet wird.

### 5. Aktivitätsprotokoll (`ActivityLog`)
* Alle wesentlichen Benutzeraktionen werden persistent im `ActivityLog` erfasst:
  * `user_registered`, `user_logged_in`, `user_logged_out`
  * `lobby_created`, `lobby_updated`, `lobby_deleted`
  * `submitted_word`
  * `password_changed`
  * `admin_promoted`, `admin_demoted`, `user_deleted`

---

## 🗄️ Datenmodell (ERM)

```
       1 ┌──────────────┐ 0..*
 ┌───────┤    users     ├──────────────┐
 │       └──────┬───────┘              │
 │              │ 1                    │ 1
 │              │                      │
 │ 0..*         │ 0..*                 │ 0..*
 ▼              ▼                      ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ activity_logs│   │   lobbies    │   │ submissions  │
└──────────────┘   └──────┬───────┘   └──────────────┘
                          │ 1
                          │
                          │ 0..*
                          ▼
                   ( submissions )
```

---

## 🧪 Testing

Alle Tests gemäss Modul-223-Kriterienkatalog (Model-, Controller-, Integrations- und Transaktionstests) ausführen:

```bash
bin/rails test
```

### Test-Umfang:
* **Models:** Validierungen, Assoziationen, Methoden (`word_frequencies`, `can_submit_to?`, Locking).
* **SessionsController:** Anmelden, Passwort-Prüfung, Auto-Registrierung, Abmelden.
* **LobbiesController:** Autorisierung (Admin vs. User), Erstellen, DB-Locking beim Editieren.
* **SubmissionsController:** Atomare Transaktion, 3-Wörter-Limit, Validierung von Leereingaben.
* **ProfilesController:** Passwortänderung, Session-Prüfung.
* **Admin::UsersController:** Rollenverwaltung (`add Admin`/`remove Admin`), Benutzerlöschung, Schutz vor Selbstlöschung/-demotierung.
* **MultiUserFlowTest:** Vollständiger E2E-Ablauf von Registrierung über Wortabgaben bis hin zum Transaktions-Rollback.
