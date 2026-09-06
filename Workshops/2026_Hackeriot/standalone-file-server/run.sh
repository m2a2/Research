#!/usr/bin/env bash
# Serve ./site over HTTP. Nothing to install — this is the Python stdlib.
#   ./run.sh          # :8000
#   ./run.sh 9000     # some other port
# Windows: use run.cmd instead, or this script under Git Bash / WSL.
set -euo pipefail
cd "$(dirname "$0")/site"

port="${1:-8000}"

# python3 on macOS/Linux; Git Bash usually only has `python` or the `py` launcher.
if command -v python3 >/dev/null 2>&1; then py=(python3)
elif command -v py >/dev/null 2>&1; then py=(py -3)
elif command -v python >/dev/null 2>&1; then py=(python)
else
  echo "No Python found. Install Python 3 from https://python.org" >&2
  exit 1
fi

if ! "${py[@]}" -c 'import sys; sys.exit(sys.version_info[0] != 3)'; then
  echo "${py[*]} is Python 2. Install Python 3 from https://python.org" >&2
  exit 1
fi

echo "serving $(pwd) on http://localhost:$port  (ctrl-c to stop)"
exec "${py[@]}" -m http.server "$port"
