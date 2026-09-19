from dataclasses import dataclass, asdict
@dataclass(frozen=True)
class AuditDTO:
    id: str
    kind: str
    subject: str
    ts: float
    def to_dict(self):
        return asdict(self)
