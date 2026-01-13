"""
Introduction a kubernetes (Version FastAPI)
"""

from fastapi import FastAPI, Response, status
import uvicorn

app = FastAPI()

# Variable globale qui définit l'état de santé
healthy = True

@app.get("/health")
def health_check(response: Response):
    """
    Route vérifiée par Kubernetes/Docker (Liveness & Readiness).
    """
    if healthy:
        # Code 200 = Tout va bien
        response.status_code = status.HTTP_200_OK
        return {"status": "ok"}
    else:
        # Code 500 = Erreur interne (Le pod est malade)
        response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        return {"status": "error"}

@app.get("/break")
def break_app():
    """
    Route de sabotage.
    """
    global healthy
    healthy = False
    return {"message": "Health probe will now fail. Check Kubernetes events!"}

@app.get("/")
def home():
    return {"message": "Bienvenue sur l'API FastAPI ! Allez sur /docs pour voir l'interface."}

if __name__ == "__main__":
    # FastAPI a besoin d'un serveur ASGI comme Uvicorn pour tourner
    uvicorn.run(app, host="0.0.0.0", port=8000)