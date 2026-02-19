# 0. Utilisation d'une image légère et sécurisée
FROM python:3.11-slim-bookworm

# 1. On installe uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. ON FORCE LE MODE SYSTEME
# astuce pour que 'uv sync' n'essaie pas de créer un .venv
ENV UV_SYSTEM_PYTHON=1

WORKDIR /app

# 3. On synchronise les dépendances
COPY pyproject.toml uv.lock ./
RUN uv pip install --system --no-cache -r pyproject.toml

# 4. On finit par le code
COPY . .

CMD ["python", "api_test.py"]