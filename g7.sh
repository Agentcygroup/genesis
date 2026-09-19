#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cat > app/gateway/router.py <<'EOF'
class Gateway:
    def __init__(self, upstream):
        self.upstream = upstream
        self.rules = {}
    def rule(self, prefix, handler):
        self.rules[prefix] = handler
    def dispatch(self, path, payload):
        for prefix in sorted(self.rules, key=len, reverse=True):
            if path.startswith(prefix):
                return self.rules[prefix](path, payload)
        return 404, {"error": "no_rule", "path": path}
EOF
cat > app/gateway/limits.py <<'EOF'
import threading
import time
class TokenBucket:
    def __init__(self, rate, burst):
        self.rate = rate
        self.burst = burst
        self.tokens = float(burst)
        self.ts = time.monotonic()
        self._lock = threading.Lock()
    def take(self, n=1):
        with self._lock:
            now = time.monotonic()
            self.tokens = min(self.burst, self.tokens + (now - self.ts) * self.rate)
            self.ts = now
            if self.tokens >= n:
                self.tokens -= n
                return True
            return False
EOF
