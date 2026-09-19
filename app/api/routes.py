from app.core.ids import make_id
from app.core.time import now
from app.queue.engine import Job
from app.queue.topics import topic
def build(engine, store):
    def health(_payload):
        return 200, {"ok": True, "size": engine.size()}
    def submit(payload):
        kind = payload.get("kind", "")
        body = payload.get("payload", {})
        if not kind:
            return 400, {"error": "missing_kind"}
        jid = make_id(kind, str(now()), str(body))
        job = Job(id=jid, kind=kind, payload=body, enqueued=now())
        accepted = engine.push(job)
        if not accepted:
            return 503, {"error": "queue_full"}
        store.put(jid, {"id": jid, "kind": kind, "payload": body})
        return 202, {"id": jid, "topic": topic("job.created")}
    def list_jobs(_payload):
        return 200, {"jobs": store.list_ids()}
    return {("GET", "/health"): health, ("POST", "/submit"): submit, ("GET", "/jobs"): list_jobs}
