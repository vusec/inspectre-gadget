import logging
import zlib

from angr.misc.ansi import Color, BackgroundColor, color, clear


class __CustomFormatter(logging.Formatter):
    """Logging Formatter for a simple unix style logger """

    def format(self, record):
        name: str = record.name
        level: str = record.levelname
        message: str = record.getMessage()
        name_len: int = len(name)
        lvl_len: int = len(level)

        # Choose a different color for each logger.
        c: int = zlib.adler32(name.encode()) % 7
        c = (c + zlib.adler32(level.encode())) % 7
        if c != 0:  # Do not color black or white, allow 'uncolored'
            col = Color(c + Color.black.value)

        return color(col, False) + f"[{name}]  {message}"


class __ExitHandler(logging.Handler):
    def emit(self, _):
        logging.shutdown()
        exit(1)


def __initialize_logger(name):

    logger = logging.getLogger(name)
    logger.propagate = False

    logger.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    ch.setFormatter(__CustomFormatter())
    logger.addHandler(ch)
    logger.addHandler(__ExitHandler(level=50))

    return logger


__loggers = {}


def get_logger(name):
    global __loggers

    if name not in __loggers.keys():
        __loggers[name] = __initialize_logger(name)

    return __loggers[name]

def disable_logging():
    for l in __loggers:
        __loggers[l].disabled = True
