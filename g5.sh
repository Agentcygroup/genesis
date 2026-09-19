#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cat > app/schemas/job.py <<'EOF'
from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class JobDTO:
    id: str
    kind: str
    payload: dict
    enqueued: float
    attempts: int = 0
    def to_dict(self):
        return asdict(self)
EOF
cat > app/schemas/result.py <<'EOF'
from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class ResultDTO:
    job_id: str
    ok: bool
    detail: str
    finished: float
    def to_dict(self):
        return asdict(self)
EOF
cat > app/schemas/audit.py <<'EOF'
from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class AuditDTO:
    id: str
    kind: str
    subject: str
    ts: float
    def to_dict(self):
        return asdict(self)
EOF
cat > app/util/store.py <<'EOF'
import threading
class Store:
    def __init__(self):
        self._d = {}
        self._lock = threading.Lock()
    def put(self, k, v):
        with self._lock:
            self._d[k] = v
    def get(self, k):
        with self._lock:
            return self._d.get(k)
    def list_ids(self):
        with self._lock:
            return sorted(self._d.keys())
    def size(self):
        with self._lock:
            return len(self._d)
EOF
