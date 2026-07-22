import logging
import os
from logging.handlers import RotatingFileHandler


def setup_logger(name: str = "kms_docs_logger") -> logging.Logger:
    """Create a rotating file + console logger."""
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        formatter = logging.Formatter(
            "[%(asctime)s] %(levelname)s [%(name)s.%(funcName)s:%(lineno)d] %(message)s"
        )

        # Console output
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)

        # Rotating file output
        os.makedirs("logs", exist_ok=True)
        file_handler = RotatingFileHandler(
            "logs/kms_docs.log",
            maxBytes=10 * 1024 * 1024,
            backupCount=5,
            encoding="utf-8",
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    return logger
