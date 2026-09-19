from dataclasses import dataclass
import os
@dataclass(frozen=True)
class Config:
    host: str = os.environ.get("APP_HOST", "0.0.0.0")
    port: int = int(os.environ.get("APP_PORT", "8080"))
    env: str = os.environ.get("APP_ENV", "dev")
    queue_size: int = int(os.environ.get("APP_QUEUE_SIZE", "1024"))
    worker_count: int = int(os.environ.get("APP_WORKER_COUNT", "4"))
def load() -> Config:
    return Config()
