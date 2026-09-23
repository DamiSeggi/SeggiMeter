# Testing-Nachweis SeggiMeter

Dokumentation der geprüften Anforderungen aus der Testing-Aufgabe (Modul 223), Stand: 25.09.2026. Alle Aussagen beziehen sich auf den aktuellen Stand und wurden mit den untenstehenden Befehlen verifiziert.

## Testbefehl

Die komplette Testsuite wird über das README dokumentiert und wie folgt ausgeführt:

```bash
bin/rails test
```

**Aktuelles Ergebnis:**

```
Finished in 0.231323s, 211.8250 runs/s, 1007.2496 assertions/s.
49 runs, 233 assertions, 0 failures, 0 errors, 0 skips
```

Einzelne Klassen bzw. einzelne Tests können gezielt ausgeführt werden:

```bash
bin/rails test test/models/submission_test.rb        # eine Testklasse
bin/rails test test/models/submission_test.rb:14   # ein einzelner Test (Zeile)
```

## Umgebung: Separate Testdatenbank & Fixtures

Rails verwendet für Tests automatisch eine separate Datenbank (`RAILS_ENV=test`). Vorbereitung:

```bash
bin/rails db:test:prepare
```

Die **Fixtures** bilden die Rollen und fachlichen Situationen ab (`test/fixtures/`):

| Fixture | Inhalt / Zweck |
|---|---|
| `users.yml` | `admin_user` (Admin-Rolle), `damian_user` (`damian`), `nico_user` (`nico`) – deckt Rollen ab |
| `lobbies.yml` | `active_lobby`, `second_lobby` – Lobbies mit Fremdschlüssel auf den Ersteller |
| `submissions.yml` | Bestehende Wort-Abgaben (u. a. Basis für das 3-Wörter-Limit-Test-Szenario); `nico_user` hat Antworten auf beide Lobbies |
| `activity_logs.yml` | Audit-Einträge für Feed-/Protokoll-Tests |

## Zuordnung der Tests zur geprüften Klasse

Die Tests liegen nach der geprüften Klasse im entsprechenden Verzeichnis unter `test/`.

### Model-Tests (`test/models/`)

| Klasse | Geprüfte Regeln |
|---|---|
| `UserTest` | Name/Pflichtfeld, Passwort min. 12 Zeichen, Name eindeutig (case-insensitive), `can_submit_to?` unter/über Limit |
| `SubmissionTest` | **Kernregel: max. 3 Wörter pro Lobby** (Model-Validierung), Wort nicht leer, Wortlänge |
| `LobbyTest` | Titel-Pflichtfeld, `word_frequencies`-Aggregation, **Pessimistic Locking** |
| `ActivityLogTest` | `action`-Pflichtfeld, Zugehörigkeit zum User |

### Controller-Tests (`test/controllers/`)

| Klasse | Geprüfte Anforderungen |
|---|---|
| `SessionsControllerTest` | Login-Seite, Login ok, Login mit falschem Passwort verweigert, „unbekannter User" ohne Account-Leak, Logout |
| `RegistrationsControllerTest` | Registrierung gültig, Passwort < 12 Zeichen ungültig, doppelter Username ungültig |
| `LobbiesControllerTest` | Nicht eingeloggt → Login-Redirect, Admin darf Lobby erstellen/umbenennen, **Nicht-Admin verweigert**, Locking-Konflikt |
| `SubmissionsControllerTest` | **Kernfunktion im Controller**: erfolgreiche Abgabe inkl. `ActivityLog`, 4. Wort atomar abgewiesen, leeres Wort abgewiesen, nicht eingeloggt verweigert |
| `ProfilesControllerTest` | Zugriffskontrolle, Passwortänderung |
| `Admin::UsersControllerTest` | **Fremde Datensätze**: Admin verwaltet/löscht andere User, Nicht-Admin verweigert, Selbstlöschung + eigener Rechteentzug blockiert |

### Policy-Tests (`test/policies/`)

| Klasse | Geprüfte Anforderungen |
|---|---|
| `UserPolicyTest` | Admin für alle User-Admin-Aktionen authorisiert; regulärer User und Gast verweigert |

### Integrationstests (`test/integration/`)

| Klasse | Geprüfte Anforderungen |
|---|---|
| `MultiUserFlowTest` | End-to-End: Registrierung → Lobby → 3 Wörter → 4. Versuch blockiert → Passwort ändern → Logout/Relogin; **Transaktions-Rollback** bei Fehler im Submissions-Block; **Locking-Lebenszyklus** (Sperren → Ändern → Entsperren) |

## Aussagekraft: Mutationstest

Die Testing-Aufgabe fordert den Nachweis, dass die Tests einen eingebauten Fehler (Mutation) tatsächlich erkennen. Die Aussagekraft wird deshalb regelmässig über folgendes, reproduzierbares Vorgehen belegt:

1. **Mutation einbauen:** In einer zentralen Fachregel wird absichtlich ein Fehler eingeführt – z. B. die Limitschwelle der 3-Wörter-Regel in `app/models/submission.rb` von `count >= 3` auf `count >= 4` geändert (würde fälschlich ein 4. Wort zulassen).

2. **Betroffenen Test ausführen:**

   ```bash
   bin/rails test test/models/submission_test.rb
   ```

   Ergebnis (erwartungsgemäss **rot**):

   ```
   3 runs, 3 assertions, 1 failures, 0 errors, 0 skips

   Failure:
   SubmissionTest#test_cannot_submit_more_than_3_words_per_lobby
   ```

   Der relevante Test `test_cannot_submit_more_than_3_words_per_lobby` erkennt den Mutanten und schlägt fehl.

3. **Mutation zurücknehmen:** Der Fehler wird wieder behoben (Schwelle zurück auf `count >= 3`), damit kein mutierter Stand zurückbleibt.

4. **Komplette Suite erneut ausführen (grün):**

   ```
   49 runs, 233 assertions, 0 failures, 0 errors, 0 skips
   ```

Dank dieses Vorgehens ist sichergestellt, dass die Kernregeln durch die zugeordneten Tests abgesichert sind.