#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cat > app/__main__.py <<'EOF'
from app.core.config import load
from app.core.log import emit
from app.api.http import serve
from app.api.routes import build
from app.queue.engine import QueueEngine
from app.autonomy.loop import Autonomy
from app.autonomy.watchdog import Watchdog
from app.gateway.router import Gateway
from app.gateway.limits import TokenBucket
from app.util.store import Store
def main():
    cfg = load()
    engine = QueueEngine(capacity=cfg.queue_size)
    store = Store()
    gateway = Gateway(upstream="local")
    bucket = TokenBucket(rate=100.0, burst=100)
    router = build(engine, store)
    auto = Autonomy(engine, store, workers=cfg.worker_count)
    watch = Watchdog(engine, interval=2.0)
    auto.start()
    watch.start()
    server = serve(router, cfg.host, cfg.port)
    emit("app.start", {"host": cfg.host, "port": cfg.port})
    try:
        while True:
            server.handle_request()
    except KeyboardInterrupt:
        pass
    auto.stop()
    watch.stop()
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
EOF
cat > pyproject.toml <<'EOF'
[project]
name = "genesis-app"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []
[tool.setuptools.packages.find]
include = ["app*"]
EOF
cat > tests/test_smoke.py <<'EOF'
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root))
from app.queue.engine import QueueEngine, Job
def test_queue_push_pop():
    e = QueueEngine(capacity=2)
    assert e.push(Job(id="a", kind="k", payload={}, enqueued=0.0)) is True
    got = e.pop(timeout=0.1)
    assert got.id == "a"
def test_queue_capacity():
    e = QueueEngine(capacity=1)
    assert e.push(Job(id="a", kind="k", payload={}, enqueued=0.0)) is True
    assert e.push(Job(id="b", kind="k", payload={}, enqueued=0.0)) is False
def test_store_roundtrip():
    from app.util.store import Store
    s = Store()
    s.put("x", {"v": 1})
    assert s.get("x") == {"v": 1}
def test_token_bucket():
    from app.gateway.limits import TokenBucket
    b = TokenBucket(rate=0.0, burst=1)
    assert b.take() is True
    assert b.take() is False
def test_gateway_dispatch():
    from app.gateway.router import Gateway
    g = Gateway(upstream="x")
    g.rule("/a", lambda path, payload: (200, {"ok": True}))
    code, _ = g.dispatch("/a/b", {})
    assert code == 200
def test_make_id_deterministic():
    from app.core.ids import make_id
    assert make_id("a", "b") == make_id("a", "b")
    assert make_id("a", "b") != make_id("b", "a")
EOF
cat > build.sh <<'EOF'
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
EOF
chmod +x build.sh
cat > run.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 -m app
EOF
chmod +x run.sh
cat > test.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 -m pytest tests -q --no-header
EOF
chmod +x test.sh
