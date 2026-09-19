import threading
from app.core.log import emit
class Watchdog:
    def __init__(self, engine, interval=2.0):
        self.engine = engine
        self.interval = interval
        self._stop = threading.Event()
    def start(self):
        def loop():
            while not self._stop.is_set():
                emit("watchdog.tick", {"size": self.engine.size()})
                self._stop.wait(self.interval)
        threading.Thread(target=loop, daemon=True).start()
    def stop(self):
        self._stop.set()
