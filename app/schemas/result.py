from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class ResultDTO:
    job_id: str
    ok: bool
    detail: str
    finished: float
    def to_dict(self):
        return asdict(self)
