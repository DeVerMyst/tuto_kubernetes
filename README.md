C'est une excellente initiative. Avoir une "Cheat Sheet" (anti-sèche) propre est indispensable quand on apprend Kubernetes, car il y a beaucoup de commandes à retenir.

Voici ton guide récapitulatif, formaté professionnellement pour tes étudiants ou ta documentation personnelle. J'ai remplacé toutes les données spécifiques par des variables génériques `<...>`.

---

# 🚢 Guide de Déploiement : De l'API Python à Kubernetes

Ce guide résume les étapes pour conteneuriser une application Python (FastAPI/Flask) avec **uv**, créer l'image Docker, et la déployer sur un cluster Kubernetes local.

---

## 1. Préparation de l'Application 🐍

Avant de toucher à Docker, il faut figer les dépendances de l'application.

1. Assurez-vous que votre API contient les routes `/health` (pour les probes K8s) et `/break` (pour tester le self-healing).
2. Générez le fichier standard pour Docker :

```bash
uv export --format requirements-txt > requirements.txt

```

---

## 2. Configuration de l'Environnement ⚙️

Il faut activer le cluster Kubernetes intégré à Docker Desktop.

1. Ouvrez **Docker Desktop**.
2. Allez dans les **Settings** (⚙️) > **Kubernetes**.
3. Cochez **Enable Kubernetes**.
4. Cliquez sur **Apply & Restart** (le redémarrage peut prendre quelques minutes).

> 💡 **Vérification :** Assurez-vous que votre contexte est bien réglé sur le cluster local :
> `kubectl config use-context docker-desktop`

---

## 3. Conteneurisation (Docker) 🐳

### Construction et Test Local

Créez votre `Dockerfile` à la racine, puis construisez l'image :

```bash
# Construire l'image
docker build -t <nom-image> .

# Tester l'image (sans exposer le port - juste pour voir si ça crash pas)
docker run <nom-image>

# Tester l'accès (avec mappage de port)
# Accès via http://localhost:8000
docker run -p 8000:8000 <nom-image>

```

### Publication sur le Registre (Docker Hub)

Pour que Kubernetes puisse télécharger votre image, elle doit être sur un registre (Registry).

```bash
# 1. Se connecter à Docker Hub
docker login

# 2. Taguer l'image (OBLIGATOIRE : doit inclure votre pseudo)
docker tag <nom-image> <ton-pseudo-docker>/<nom-image>:v1

# 3. Envoyer l'image vers le Cloud
docker push <ton-pseudo-docker>/<nom-image>:v1

```

---

## 4. Déploiement Kubernetes (K8s) ☸️

Une fois l'image en ligne, on ordonne au cluster de la déployer.

### Déploiement (Deployment)

Gère les Pods (les conteneurs) et le self-healing.

1. Créez le fichier `<nom-app>-deployment.yaml` (n'oubliez pas de mettre l'image `<ton-pseudo-docker>/<nom-image>:v1` dedans).
2. Appliquez la configuration :

```bash
kubectl apply -f <nom-app>-deployment.yaml

```

### Service (Réseau)

Gère l'accès réseau et l'adresse IP stable.

1. Créez le fichier `<nom-app>-service.yaml`.
2. Appliquez la configuration :

```bash
kubectl apply -f <nom-app>-service.yaml

```

---

## 5. Surveillance et Debugging 🕵️‍♂️

Une fois déployé, voici les commandes vitales pour vérifier que tout fonctionne.

| Action | Commande |
| --- | --- |
| **Voir les Pods** | `kubectl get pods` |
| **Voir les Services (IP)** | `kubectl get svc` |
| **Lire les Logs** | `kubectl logs <nom-du-pod>` |
| **Décrire un problème** | `kubectl describe pod <nom-du-pod>` |

> **Exemple pour voir les logs d'un pod spécifique :**
> `kubectl logs <nom-deployment>-d966f85c6-nsftg`

---

## 6. Nettoyage (Cleanup) 🧹

Pour supprimer les ressources et ne pas encombrer le cluster.

```bash
# Supprimer le déploiement (tue tous les pods associés)
kubectl delete deployment <nom-deployment>

# Supprimer le service (libère le port/IP)
kubectl delete service <nom-service>

```