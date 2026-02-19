Pour repartir sur des bases saines et lancer ton service sur ton Kubernetes local (Docker Desktop), voici la procédure complète, étape par étape, mise à jour pour 2026.

### 1. Préparation des fichiers

Assure-toi d'avoir ces trois fichiers dans ton dossier de travail :

**A. `api_test.py**` (Le code de l'API)
Vérifie bien la ligne `host="0.0.0.0"`.

```python
from fastapi import FastAPI, Response, status
import uvicorn

app = FastAPI()
healthy = True

@app.get("/health")
def health_check(response: Response):
    if healthy:
        return {"status": "ok"}
    response.status_code = 500
    return {"status": "error"}

@app.get("/break")
def break_app():
    global healthy
    healthy = False
    return {"message": "Application sabotée"}

@app.get("/")
def home():
    return {"message": "Hello Kubernetes !"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

```

**B. `pyproject.toml**` (Les dépendances)

```toml
[project]
name = "tuto-kubernetes"
version = "0.1.0"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn>=0.30.0",
]

```

**C. `Dockerfile**` (L'image)

```dockerfile
FROM python:3.11-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_SYSTEM_PYTHON=1
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv pip install --system --no-cache -r pyproject.toml
COPY . .
CMD ["python", "api_test.py"]

```

---

### 2. Build de l'image

Ouvre ton terminal et génère d'abord le fichier de verrouillage, puis build l'image Docker :

```bash
# 1. Générer le lockfile (sur ton PC)
uv lock

# 2. Builder l'image
docker build -t devermyst/mon-image-kube:v1 .

```

---

### 3. Configuration de Kubernetes (K8s)

Crée un fichier nommé `k8s-config.yaml` et colle ce contenu (il regroupe le Deployment et le Service) :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-ia-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-ia
  template:
    metadata:
      labels:
        app: api-ia
    spec:
      containers:
      - name: api-container
        image: devermyst/mon-image-kube:v1
        imagePullPolicy: IfNotPresent # Utilise l'image locale sans Docker Hub
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: api-ia-service
spec:
  type: LoadBalancer
  selector:
    app: api-ia
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000

```

---

### 4. Déploiement et Vérification

**Étape A : Appliquer la configuration**

```bash
kubectl apply -f k8s-config.yaml

```

**Étape B : Vérifier que tout est "Running"**

```bash
kubectl get pods

```

*Si le statut est `ImagePullBackOff`, c'est que le nom de l'image dans le YAML ne correspond pas exactement à celui du `docker build`.*

**Étape C : Accéder à l'API**
Une fois que le pod est prêt, ouvre ton navigateur sur :
👉 **`http://localhost:8000`**

---

### 5. Le test du "Self-healing" (Pour la démo)

C'est ici que tes élèves vont comprendre l'intérêt de K8s :

1. Laisse un terminal ouvert avec : `kubectl get pods -w`
2. Dans ton navigateur, va sur `http://localhost:8000/break`.
3. Attends 5 à 10 secondes.
4. Tu vas voir le statut du Pod changer, puis la colonne `RESTARTS` passer à **1**.
5. Retourne sur `http://localhost:8000/` : l'application est de nouveau vivante !

**Est-ce que tout se lance correctement avec cet enchaînement ?** 🚀🎤