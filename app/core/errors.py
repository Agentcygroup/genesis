class AppError(Exception):
    pass
class NotFound(AppError):
    pass
class Conflict(AppError):
    pass
class Refused(AppError):
    pass
