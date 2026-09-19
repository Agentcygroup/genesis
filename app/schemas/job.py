from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class JobDTO:
    id: str
    kind: str
    payload: dict
    enqueued: float
    attempts: int = 0
    def to_dict(self):
        return asdict(self)
