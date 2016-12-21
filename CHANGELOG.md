# ChangeLog

The following are lists of the notable changes included with each release.
This is intended to help keep people informed about notable changes between
versions as well as provide a rough history.

#### Next Release
- Relax rack version dependency to >= 1.6 from ~> 1.6

#### v0.3.0 - 2015-12-15
- Fix load order issue that was preventing the gem from working in an app

#### v0.2.0 - 2015-12-9
- You can add "checks" for `/health` by using the `critical: true` flag
- You can see a report of all your checks through `/status`.
