import threading
import time
from app.core.log import emit
class Autonomy:
    def __init__(self, engine, store, workers=4):
        self.engine = engine
        self.store = store
        self.workers = workers
        self.threads = []
        self.running = False
    def handler(self, job):
        return True, {"handled": job.kind}
    def run_worker(self):
        while self.running:
            job = self.engine.pop(timeout=0.5)
            if job is None:
                continue
            ok, detail = self.handler(job)
            row = {"id": job.id, "ok": ok, "detail": detail, "finished": time.time()}
            self.store.put(job.id, row)
            emit("job.done" if ok else "job.failed", row)
    def start(self):
        self.running = True
        for _ in range(self.workers):
            t = threading.Thread(target=self.run_worker, daemon=True)
            t.start()
            self.threads.append(t)
        emit("autonomy.start", {"workers": self.workers})
    def stop(self):
        self.running = False
        self.engine.close()
