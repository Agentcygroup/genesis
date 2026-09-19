from collections import deque
from dataclasses import dataclass
import threading
import time
@dataclass
class Job:
    id: str
    kind: str
    payload: dict
    enqueued: float
    attempts: int = 0
@dataclass
class QueueEngine:
    capacity: int = 1024
    def __post_init__(self):
        self._q = deque()
        self._lock = threading.Lock()
        self._cv = threading.Condition(self._lock)
        self._closed = False
    def push(self, job):
        with self._cv:
            if self._closed:
                return False
            if len(self._q) >= self.capacity:
                return False
            self._q.append(job)
            self._cv.notify()
            return True
    def pop(self, timeout=1.0):
        with self._cv:
            end = time.monotonic() + timeout
            while not self._q and not self._closed:
                remaining = end - time.monotonic()
                if remaining <= 0:
                    return None
                self._cv.wait(remaining)
            if self._q:
                return self._q.popleft()
            return None
    def size(self):
        with self._lock:
            return len(self._q)
    def close(self):
        with self._cv:
            self._closed = True
            self._cv.notify_all()
