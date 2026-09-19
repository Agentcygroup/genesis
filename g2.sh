#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
touch app/__init__.py app/core/__init__.py app/queue/__init__.py app/api/__init__.py app/schemas/__init__.py app/util/__init__.py app/gateway/__init__.py app/autonomy/__init__.py
cat > app/core/config.py <<'EOF'
from dataclasses import dataclass
import os
@dataclass(frozen=True)
class Config:
    host: str = os.environ.get("APP_HOST", "0.0.0.0")
    port: int = int(os.environ.get("APP_PORT", "8080"))
    env: str = os.environ.get("APP_ENV", "dev")
    queue_size: int = int(os.environ.get("APP_QUEUE_SIZE", "1024"))
    worker_count: int = int(os.environ.get("APP_WORKER_COUNT", "4"))
def load() -> Config:
    return Config()
EOF
cat > app/core/log.py <<'EOF'
import json
import sys
import time
def emit(kind, payload):
    row = {"ts": time.time(), "kind": kind, "payload": payload}
    sys.stdout.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")
    sys.stdout.flush()
EOF
cat > app/core/errors.py <<'EOF'
class AppError(Exception):
    pass
class NotFound(AppError):
    pass
class Conflict(AppError):
    pass
class Refused(AppError):
    pass
EOF
cat > app/core/ids.py <<'EOF'
import hashlib
def make_id(*parts):
    h = hashlib.sha256()
    for p in parts:
        h.update(p.encode())
    return h.hexdigest()[:16]
EOF
cat > app/core/time.py <<'EOF'
import time
def now():
    return time.time()
def mono():
    return time.monotonic_ns()
EOF
