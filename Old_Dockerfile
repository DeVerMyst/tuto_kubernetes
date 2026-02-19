# 1. On part d'une version légère de Python (la même que tu utilises)
FROM python:3.11-slim

# 2. On crée un dossier de travail dans le conteneur pour ne pas mettre le bazar
WORKDIR /app

# 3. On copie d'abord les requirements (pour utiliser le cache Docker si ça ne change pas)
COPY requirements.txt .

# 4. On installe les librairies
RUN pip install --no-cache-dir -r requirements.txt

# 5. On copie tout le reste de ton code (api_test.py, etc.)
COPY . .

# 6. La commande que Docker lance au démarrage
CMD ["python", "api_test.py"]