#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 -m py_compile app/__main__.py
python3 -m py_compile app/core/config.py
python3 -m py_compile app/core/log.py
python3 -m py_compile app/core/ids.py
python3 -m py_compile app/core/time.py
python3 -m py_compile app/queue/engine.py
python3 -m py_compile app/api/http.py
python3 -m py_compile app/api/routes.py
python3 -m py_compile app/util/store.py
python3 -m py_compile app/gateway/router.py
python3 -m py_compile app/gateway/limits.py
python3 -m py_compile app/autonomy/loop.py
python3 -m py_compile app/autonomy/watchdog.py
echo BUILD_OK
