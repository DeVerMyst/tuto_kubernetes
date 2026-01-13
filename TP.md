# 💥 TP : Le Challenge "Chaos Monkey"

**Objectif :** Vous allez jouer le rôle du méchant. Votre but est de détruire l'application. Le but de Kubernetes est de la maintenir en vie coûte que coûte. Qui va gagner ?

> **💡 Astuce de Pro :** Avant de commencer, ouvrez un terminal dédié et lancez cette commande pour observer le combat en direct :
> `kubectl get pods -w`

---

### 🟢 Niveau 1 : La Reconnaissance

Avant d'attaquer, vérifions que la cible est présente.

1. Ouvrez votre navigateur.
2. Tapez **`http://localhost`**.
3. **Résultat attendu :** Vous devez voir le message de bienvenue (`"status": "ok"` ou le message d'accueil). Tout est calme... pour l'instant.

---

### 🥊 Niveau 2 : L'Attaque Frontale (Pod Deletion)

Nous allons supprimer purement et simplement le conteneur.

1. Repérez le nom du pod : `kubectl get pods`
2. Tuez-le :
```bash
kubectl delete pod <nom-du-pod>

```


3. **👀 Observation :**
* Le pod passe en statut `Terminating`.
* **Immédiatement**, un nouveau pod avec un nom différent apparait (`Pending` -> `Running`).
* **Pourquoi ?** Le **ReplicaSet** a remarqué qu'il manquait un soldat à l'appel (on a demandé 1 replica) et l'a remplacé instantanément.



---

### 🔫 Niveau 3 : Le Sabotage Interne (Process Kill)

Cette fois, on ne détruit pas le conteneur de l'extérieur, on rentre dedans pour tuer le processus Python.

1. Connectez-vous à l'intérieur du pod :
```bash
kubectl exec -it <nom-du-pod> -- sh

```


2. Une fois dedans (`#`), tuez le processus principal (PID 1) :
```bash
kill 1

```


3. La connexion va couper ("command terminated with exit code 137").
4. **👀 Observation :**
* Regardez vos pods (`kubectl get pods`).
* Le pod est toujours là (même nom), mais son compteur **RESTARTS** est passé à `1`.
* **Pourquoi ?** Kubernetes a vu que le programme principal a crashé. Sa politique est de redémarrer le conteneur existant.



---

### 🧪 Niveau 4 : L'Empoisonnement (Liveness Probe)

L'attaque la plus sournoise. Le pod tourne, le processus tourne, mais l'application est "malade" (bloquée ou buggée).

1. Allez sur la route de sabotage : **`http://localhost/break`**
* *L'application vous prévient qu'elle va mourir.*


2. Vérifiez son état de santé : **`http://localhost/health`**
* *Elle retourne une erreur 500.*


3. Attendez... (environ 30 secondes, selon votre configuration `livenessProbe`).
4. **👀 Observation :**
* Sans que vous touchiez à rien, le pod va redémarrer.
* Le compteur **RESTARTS** augmente encore.
* Si vous retournez sur `localhost/health`, tout est redevenu vert (`200 OK`).
* **Pourquoi ?** La sonde **Liveness Probe** a détecté l'erreur 500 à répétition. Elle a signalé au cluster : "Ce pod est inutile, tuez-le et relancez-le".



---

### 🏆 Conclusion

**Kubernetes a gagné 3-0.**
Peu importe la panne (suppression, crash, bug interne), le système d'auto-guérison a restauré le service sans intervention humaine.