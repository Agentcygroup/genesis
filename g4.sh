#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cat > app/api/http.py <<'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import threading
from app.core.log import emit
class Handler(BaseHTTPRequestHandler):
    router = None
    def _reply(self, code, body):
        payload = json.dumps(body, sort_keys=True, separators=(",", ":")).encode()
        self.send_response(code)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)
    def do_GET(self):
        handler = (self.router or {}).get(("GET", self.path))
        if handler is None:
            self._reply(404, {"error": "not_found", "path": self.path})
            return
        code, body = handler({})
        self._reply(code, body)
    def do_POST(self):
        length = int(self.headers.get("content-length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        try:
            payload = json.loads(raw.decode() or "{}")
        except Exception:
            self._reply(400, {"error": "bad_json"})
            return
        handler = (self.router or {}).get(("POST", self.path))
        if handler is None:
            self._reply(404, {"error": "not_found", "path": self.path})
            return
        code, body = handler(payload)
        self._reply(code, body)
    def log_message(self, *args):
        return
def serve(router, host, port):
    Handler.router = router
    server = HTTPServer((host, port), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    emit("http.serve", {"host": host, "port": port, "routes": len(router)})
    return server
EOF
cat > app/api/routes.py <<'EOF'
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
EOF
