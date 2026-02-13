# ✅ Checklist CloudShop Kubernetes Deployment

## Namespace
- [ ] Appliquer le namespace : `kubectl apply -f namespace.yaml`
- [ ] Vérifier le namespace : `kubectl get ns`

## Deployments
- [ ] Appliquer les Deployments : `kubectl apply -f deployments/`
- [ ] Vérifier les Deployments : `kubectl get deployments -n cloudshop`
- [ ] Vérifier les pods : `kubectl get pods -n cloudshop`
- [ ] Frontend et Backend ont 2 replicas
- [ ] RollingUpdate activé
- [ ] Backend pods : anti-affinity pour éviter le même node
- [ ] ServiceAccount appliqué à chaque pod
- [ ] Test RollingUpdate réussi :  
  `kubectl set image deployment/backend backend=python:3.11-alpine -n cloudshop`  
  `kubectl rollout status deployment/backend -n cloudshop`

## Services
- [ ] Appliquer les Services : `kubectl apply -f services/`
- [ ] Vérifier les Services : `kubectl get svc -n cloudshop`
- [ ] Backend et DB exposés en ClusterIP
- [ ] Frontend exposé via Ingress uniquement

## Ingress
- [ ] Appliquer l’Ingress : `kubectl apply -f ingress/cloudshop-ingress.yaml`
- [ ] Vérifier l’Ingress : `kubectl get ingress -n cloudshop`
- [ ] Host-based routing : `cloudshop.local`
- [ ] Path-based routing : `/ → frontend`, `/api → backend`
- [ ] TLS activé (self-signed autorisé)
- [ ] Test Ingress fonctionnel :  
  `curl -k https://cloudshop.local/`  
  `curl -k https://cloudshop.local/api`

## Base de données & Storage
- [ ] Appliquer le PVC : `kubectl apply -f storage/postgres-pvc.yaml`
- [ ] Vérifier le PVC : `kubectl get pvc -n cloudshop`
- [ ] DB utilise PVC, pas de hostPath
- [ ] DB pod tolère taint `db-node` et est sur node tainté
- [ ] Vérification persistance des données

## Taints & Affinity
- [ ] Node DB tainté : `kubectl taint nodes <db-node> db-node=true:NoSchedule`
- [ ] Backend pods : anti-affinity pour éviter le même node
- [ ] Frontend et DB : ne cohabitent pas sur le même node
- [ ] Vérification des pods : `kubectl get pods -o wide -n cloudshop`
- [ ] Vérification des taints : `kubectl describe node <db-node> | grep Taints -A2`

## RBAC & ServiceAccounts
- [ ] `frontend-sa` : aucun droit API
- [ ] `backend-sa` : lecture de ConfigMaps et Secrets
- [ ] Test droits : `kubectl auth can-i get pods --as=testuser`

## NetworkPolicy
- [ ] Frontend → Backend autorisé
- [ ] Backend → DB autorisé
- [ ] Interdiction d’accès DB depuis frontend et namespace externe
- [ ] Test NetworkPolicy :  
  `kubectl exec -it frontend-<pod> -- curl http://backend:5000/api` (OK)  
  `kubectl exec -it frontend-<pod> -- psql -h postgres ...` (Bloqué)

## Vérification finale
- [ ] Application accessible via Ingress
- [ ] RollingUpdate fonctionne (zero downtime)
- [ ] DB persiste après suppression de pod
- [ ] Taints et Affinity respectés
- [ ] NetworkPolicy bloque accès non autorisé




# CloudShop Kubernetes - Checklist de tests

Ce guide permet de vérifier que toutes les exigences techniques du projet CloudShop sont respectées.

---

## 1. Namespace
**Objectif** : Vérifier que le namespace dédié existe et que rien n’est dans default.

kubectl get ns
kubectl get all -n default
kubectl get all -n cloudshop

✅ Vérifier que cloudshop existe et que default ne contient aucun objet du projet.

---

## 2. Deployments
**Objectif** : Vérifier les réplicas et le RollingUpdate.

kubectl get deployments -n cloudshop
kubectl describe deployment frontend -n cloudshop
kubectl describe deployment backend -n cloudshop

**Test RollingUpdate / Zero downtime** :

kubectl set image deployment/backend backend=python:3.11-alpine -n cloudshop
kubectl rollout status deployment/backend -n cloudshop
kubectl get pods -n cloudshop -w

✅ Vérifier que les pods backend se mettent à jour sans interruption du service.

---

## 3. Services
**Objectif** : Vérifier les types de service et l’exposition via Ingress.

kubectl get svc -n cloudshop

- Backend et DB : ClusterIP
- Frontend exposé uniquement via Ingress

---

## 4. Ingress
**Objectif** : Host-based & Path-based routing, TLS activé.

kubectl get ingress -n cloudshop
curl -k https://cloudshop.local/
curl -k https://cloudshop.local/api

✅ Vérifier que le frontend et le backend sont accessibles via les chemins / et /api.

---

## 5. Base de données & Volumes
**Objectif** : Vérifier persistance et PVC.

kubectl get pvc -n cloudshop
kubectl describe pod -l app=db -n cloudshop

**Tester la persistance des données** :

kubectl run -i --tty --rm pg-client \
  --image=postgres:15 \
  --namespace=cloudshop \
  --env="PGPASSWORD=password" \
  -- bash

# Dans le client psql
psql -h postgres -U admin -d cloudshop
CREATE TABLE test_persistence (id SERIAL PRIMARY KEY, name TEXT);
INSERT INTO test_persistence (name) VALUES ('Premier test');
SELECT * FROM test_persistence;
# Supprimer le pod postgres et vérifier que les données persistent

---

## 6. Taints & Affinity
**Objectif** : DB sur node dédié, backend pods sur nodes différents.

kubectl get nodes -o wide
kubectl describe node <db-node> | grep -i taint
kubectl get pods -o wide -n cloudshop

✅ Vérifier :
- Node DB a le taint db-node=true:NoSchedule
- DB pod tourne sur ce node
- Backend pods sur nodes différents
- Frontend et DB ne cohabitent pas

---

## 7. RBAC & ServiceAccounts
**Objectif** : vérifier permissions.

kubectl get sa -n cloudshop
kubectl auth can-i get pods --as=testuser
kubectl describe role backend-role -n cloudshop
kubectl describe rolebinding backend-rolebinding -n cloudshop

✅ Vérifier :
- Backend peut lire ConfigMaps et Secrets
- Frontend n’a aucun droit API

---

## 8. NetworkPolicy
**Objectif** : sécuriser la communication entre pods.

kubectl describe networkpolicy cloudshop-networkpolicy -n cloudshop
kubectl exec -it <frontend-pod> -- curl http://backend:5000/api  # OK
kubectl exec -it <frontend-pod> -- psql -h postgres ...          # Bloqué
kubectl exec -it <other-namespace-pod> -- curl http://backend:5000/api  # Bloqué

✅ Vérifier :
- Frontend -> Backend autorisé
- Backend -> DB autorisé
- Frontend -> DB interdit
- Pods externes -> Backend/DB interdits

---

## 9. Vérification finale
kubectl get all -n cloudshop
kubectl logs <pod-name> -n cloudshop
kubectl describe pod <pod-name> -n cloudshop

- Tous les pods sont en Running / Ready
- RollingUpdate fonctionne sans downtime
- DB persiste après suppression du pod
- Taints & Affinity respectés
- NetworkPolicy fonctionne
