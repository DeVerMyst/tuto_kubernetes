# 1. Utilisation d'une image légère et sécurisée
FROM python:3.11-slim-bookworm

# 2. On récupère l'exécutable uv depuis son image officielle (Multi-stage build)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 3. Dossier de travail
WORKDIR /app

# 4. On copie les fichiers de configuration de uv (l'équivalent moderne du requirements.txt)
# On le fait avant de copier le code pour optimiser le cache Docker
COPY pyproject.toml uv.lock ./

# 5. On installe les dépendances
# --system : Installe dans le Python global du conteneur (pas besoin de venv ici)
# --frozen : Garantit que l'on respecte exactement le fichier uv.lock
RUN uv pip install --system --frozen

# 6. On copie tout le reste
COPY . .

# 7. Commande de lancement (pense à utiliser le host 0.0.0.0 pour Docker !)
CMD ["python", "api_test.py"]