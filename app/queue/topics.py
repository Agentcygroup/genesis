TOPICS = {"job.created": "job.created", "job.done": "job.done", "job.failed": "job.failed", "audit": "audit", "policy": "policy"}
def topic(name):
    return TOPICS[name]
