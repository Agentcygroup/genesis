class Gateway:
    def __init__(self, upstream):
        self.upstream = upstream
        self.rules = {}
    def rule(self, prefix, handler):
        self.rules[prefix] = handler
    def dispatch(self, path, payload):
        for prefix in sorted(self.rules, key=len, reverse=True):
            if path.startswith(prefix):
                return self.rules[prefix](path, payload)
        return 404, {"error": "no_rule", "path": path}
