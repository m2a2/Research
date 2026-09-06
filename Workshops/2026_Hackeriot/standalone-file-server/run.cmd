@echo off
rem Serve .\site over HTTP. Nothing to install - this is the Python stdlib.
rem   run.cmd          :8000
rem   run.cmd 9000     some other port
rem Run it from a terminal, not by double-clicking, so you can see the log.
setlocal
cd /d "%~dp0site"

set "port=%~1"
if "%port%"=="" set "port=8000"

rem The py launcher first: on Windows a bare `python` can be the Microsoft Store
rem stub that installs nothing and helpfully opens a shop instead.
set "PY="
where py >nul 2>nul && set "PY=py -3"
if not defined PY (
  where python >nul 2>nul && set "PY=python"
)
if not defined PY (
  echo No Python found. Install Python 3 from https://python.org and tick
  echo "Add python.exe to PATH" in the installer.
  exit /b 1
)

echo serving %CD% on http://localhost:%port%  (ctrl-c to stop)
%PY% -m http.server %port%
