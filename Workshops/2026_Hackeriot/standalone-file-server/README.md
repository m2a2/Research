By: https://github.com/m2a2/Research/tree/main/Workshops

# A web server that only serves files

> **A file server maps a URL to a file on disk.** It runs none of your code.

Self-contained — copy this folder anywhere. Everything in `site/` is a plain
file; the only program involved ships with Python. Works on macOS, Linux and
Windows.

```
standalone-file-server/
├── run.sh          # starts the server (macOS / Linux / Git Bash / WSL)
├── run.cmd         # starts the server (Windows cmd.exe or PowerShell)
└── site/           # ← the whole "website". Served verbatim.
    ├── index.html
    ├── style.css
    ├── clock.js
    └── books.json
```

## Setup

Nothing to install. You need Python 3 — no `pip`, no virtualenv, no
`package.json`. `http.server` is in the standard library.

**macOS / Linux**

```bash
python3 --version
```

**Windows** — in PowerShell or cmd:

```
py --version
```

If that says "not found", install Python 3 from <https://python.org> and tick
**Add python.exe to PATH** in the installer. Avoid the bare `python` command
until you have: on a clean Windows it is a stub that just opens the Microsoft
Store. `run.cmd` prefers `py` for exactly that reason.

## Run

**macOS / Linux** (or Git Bash / WSL on Windows):

```bash
./run.sh              # http://localhost:8000
./run.sh 9000         # if 8000 is taken
```

If it is not executable: `chmod +x run.sh`, or run it as `bash run.sh`.

**Windows** — `cd` into this folder in PowerShell or cmd, then:

```
.\run.cmd
.\run.cmd 9000
```

Either way, open <http://localhost:8000> and Ctrl-C to stop. Windows may pop a
firewall prompt the first time; "allow on private networks" is enough, or just
deny it — localhost still works.

Equivalent one-liner without the scripts:

```bash
cd site && python3 -m http.server 8000     # Windows: cd site && py -m http.server 8000
```

## What to look at

The commands below use `curl`, which is built into macOS, Linux and Windows 10+.
**In PowerShell, type `curl.exe`, not `curl`** — the bare name is an alias for
`Invoke-WebRequest`, which is a different program with different flags.

**1. The response *is* the file, byte for byte.**

```bash
curl localhost:8000/index.html
```

Now prove the bytes are identical, which is the whole point:

```bash
# macOS / Linux
diff <(curl -s localhost:8000/index.html) site/index.html      # no output = identical
```

```powershell
# PowerShell
curl.exe -s -o got.html localhost:8000/index.html
(Get-FileHash got.html).Hash -eq (Get-FileHash site\index.html).Hash   # True
```

```
:: cmd.exe  —  /b is a binary compare
curl -s -o got.html http://localhost:8000/index.html
fc /b got.html site\index.html
```

The server did not *decide* anything. Edit `site/index.html`, save, reload the
browser: the response changed because **the file** changed. That is the only way
it can change.

`curl localhost:8000/` gives you a directory listing — the server is a filing
clerk with no opinions about your app.

**2. Serving JSON does not make it an API.**

```bash
curl localhost:8000/books.json          # JSON! over HTTP! is this an API?
```

No. Two things you cannot do with it:

```bash
curl "localhost:8000/books.json?author=le+guin"   # query string ignored:
                                                  # there is no code to read it
```

...and add a book. There is no verb for it, no code to run, nothing to ask:

```bash
curl -i -X POST localhost:8000/books.json         # 501 Unsupported method
```

Running your code is what makes something an API.

**3. `clock.js` runs, but not on the server.**

The caption on the page has an **update** button that fills in today's date. That
is real code executing — in the *browser*, after the download finished. The
server's part was identical to its part for the CSS: hand over the bytes.

```bash
# macOS / Linux
diff <(curl -s localhost:8000/clock.js) site/clock.js   # identical too
curl -s localhost:8000/index.html | grep "Today is"     # a placeholder, never a date
```

```powershell
# PowerShell
curl.exe -s localhost:8000/index.html | Select-String "Today is"
```

```
:: cmd.exe
curl -s http://localhost:8000/index.html | findstr "Today is"
```

Reload the page and the date reverts to the placeholder string, because that
string is what is on disk. Nothing on the server knows what day it is.

## Where this stops

| | This file server |
|---|---|
| URL points to | a path on disk |
| Response body | the file's bytes, verbatim |
| Same request twice | same bytes |
| Query string `?x=1` | ignored |
| Methods | GET and HEAD; everything else is a 501 |
| Who does the work | the OS filesystem |

The next step up is a server where a URL maps to a **function call** instead of a
path — one URL that can give many answers, read the query string, and let `POST`
change what later requests see.

**Do not use this for anything real.** `http.server` is a demo/debug server: it
is single-threaded, does no auth, and the docs say so themselves. In production
files get served by nginx, a CDN, or your framework's static-file route.
