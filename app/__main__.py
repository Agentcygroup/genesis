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
