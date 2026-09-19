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
