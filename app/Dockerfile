# DOTWEB DevSecOps Pipeline — Application Dockerfile
# Multi-stage build for minimal attack surface
 
# ── Stage 1: Build ──────────────────────────────────────────
FROM python:3.12-slim AS builder
 
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
 
# ── Stage 2: Runtime ────────────────────────────────────────
FROM python:3.12-slim AS runtime
 
# Security: run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
 
WORKDIR /app
 
# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn
 
COPY app.py .
 
RUN chown -R appuser:appuser /app
USER appuser
 
EXPOSE 5000
 
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"
 
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
