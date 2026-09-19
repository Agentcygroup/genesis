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
