"""Falsifiers for the vatican operations lifecycle that exercise
genesis modules. Every operation in vatican/operations/lifecycle.py
whose module lives in this repo has its falsifier here.

These tests are named in the vatican registry. They are the
cross-repo half of the operations suite.
"""
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root))


def test_boot():
    from app.core.config import load
    cfg = load()
    assert cfg.port > 0


def test_config_loads():
    from app.core.config import load
    assert load().env in ("dev", "test", "prod")


def test_store_opens():
    from app.util.store import Store
    s = Store()
    s.put("x", {"v": 1})
    assert s.get("x") == {"v": 1}


def test_queue_starts():
    from app.queue.engine import QueueEngine
    e = QueueEngine(capacity=10)
    assert e.size() == 0
    e.close()


def test_workers_start():
    from app.queue.engine import QueueEngine
    from app.autonomy.loop import Autonomy
    from app.util.store import Store
    e = QueueEngine(capacity=10)
    s = Store()
    a = Autonomy(e, s, workers=1)
    a.start()
    a.stop()


def test_listener_opens():
    from app.core.config import load
    from app.api.http import serve
    from app.api.routes import build
    from app.queue.engine import QueueEngine
    from app.util.store import Store
    load()
    e = QueueEngine(capacity=10)
    s = Store()
    server = serve(build(e, s), "127.0.0.1", 0)
    server.server_close()


def test_routes_registered():
    from app.api.routes import build
    from app.queue.engine import QueueEngine
    from app.util.store import Store
    router = build(QueueEngine(capacity=10), Store())
    assert ("GET", "/health") in router
    assert ("POST", "/submit") in router


def test_serve():
    from app.api.routes import build
    from app.queue.engine import QueueEngine
    from app.util.store import Store
    router = build(QueueEngine(capacity=10), Store())
    code, _ = router[("GET", "/health")]({})
    assert code == 200


def test_health():
    from app.api.routes import build
    from app.queue.engine import QueueEngine
    from app.util.store import Store
    router = build(QueueEngine(capacity=10), Store())
    code, body = router[("GET", "/health")]({})
    assert body["ok"] is True


def test_log():
    from app.core.log import emit
    emit("test", {"x": 1})


def test_rate_limit():
    from app.gateway.limits import TokenBucket
    b = TokenBucket(rate=0.0, burst=1)
    assert b.take() is True
    assert b.take() is False


def test_backpressure():
    from app.queue.engine import QueueEngine, Job
    e = QueueEngine(capacity=1)
    assert e.push(Job(id="a", kind="k", payload={}, enqueued=0.0)) is True
    assert e.push(Job(id="b", kind="k", payload={}, enqueued=0.0)) is False


def test_shutdown():
    from app.queue.engine import QueueEngine, Job
    e = QueueEngine(capacity=10)
    e.close()
    assert e.push(Job(id="x", kind="k", payload={}, enqueued=0.0)) is False
