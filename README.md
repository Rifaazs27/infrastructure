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
