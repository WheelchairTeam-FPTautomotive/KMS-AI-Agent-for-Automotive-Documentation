# ---- Build Stage ----
FROM python:3.12-slim AS builder

WORKDIR /build

COPY pyproject.toml .
RUN pip install --no-cache-dir uv && uv pip install --system --no-cache -r pyproject.toml

COPY src/ src/
COPY scripts/ scripts/

# ---- Runtime Stage ----
FROM python:3.12-slim

RUN useradd --create-home appuser
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /build/src ./src
COPY --from=builder /build/scripts ./scripts

RUN mkdir -p data outputs logs && chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "main:app", "--app-dir", "src", "--host", "0.0.0.0", "--port", "8000"]
