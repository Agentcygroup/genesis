import json
import sys
import time
def emit(kind, payload):
    row = {"ts": time.time(), "kind": kind, "payload": payload}
    sys.stdout.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")
    sys.stdout.flush()
