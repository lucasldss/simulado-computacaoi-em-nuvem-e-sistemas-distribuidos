
#!/bin/bash

# SIMULADO CLOUD - COMPUTAÇÃO EM NUVEM
# Professora: Simone Tatiane do Canto
# Namespace: simulado-nuvem

# ==========================================
# ETAPA 1 - CLUSTER E NAMESPACE
# ==========================================

kubectl get nodes

kubectl create namespace simulado-nuvem

kubectl get namespace simulado-nuvem


# ==========================================
# ETAPA 2 - CONFIGMAP, SECRET E RBAC
# ==========================================

kubectl apply -f manifests/01-configmap-v1.yaml

kubectl -n simulado-nuvem create secret generic senha-app \
  --from-literal=token=valor-ficticio-2026

kubectl apply -f manifests/03-rbac.yaml

kubectl auth can-i list pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web

kubectl auth can-i delete pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web


# ==========================================
# ETAPA 3 - DEPLOYMENT E SERVICE
# ==========================================

kubectl apply -f manifests/04-web.yaml

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem get deployment,pods,service


# ==========================================
# ETAPA 4 - TESTE HTTP E DIAGNÓSTICO
# ==========================================

kubectl -n simulado-nuvem run cliente \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600

kubectl -n simulado-nuvem wait \
  --for=condition=Ready pod/cliente \
  --timeout=90s

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

kubectl -n simulado-nuvem describe deployment web

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp

kubectl -n simulado-nuvem logs deployment/web


# ==========================================
# ETAPA 5 - ESCALA E AUTORRECUPERAÇÃO
# ==========================================

kubectl -n simulado-nuvem scale deployment web --replicas=3

kubectl -n simulado-nuvem get pods

kubectl -n simulado-nuvem scale deployment web --replicas=2

kubectl -n simulado-nuvem get pods

# Substituir pelo nome real de um Pod web
kubectl -n simulado-nuvem delete pod NOME_DO_POD

kubectl -n simulado-nuvem get pods -w

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


# ==========================================
# ETAPA 6 - ATUALIZAÇÃO E ROLLBACK
# ==========================================

kubectl apply -f manifests/02-configmap-v2.yaml

kubectl -n simulado-nuvem rollout restart deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

# Simulação de imagem inexistente
kubectl -n simulado-nuvem set image deployment/web \
  nginx=nginx:tag-inexistente-simulado

kubectl -n simulado-nuvem rollout status deployment/web \
  --timeout=60s

kubectl -n simulado-nuvem get pods

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp

# Recuperação da revisão anterior
kubectl -n simulado-nuvem rollout undo deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem get deployment,pods

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web


# ==========================================
# ETAPA 7 - CRONJOB E JOB
# ==========================================

kubectl apply -f manifests/05-cronjob.yaml

kubectl -n simulado-nuvem create job teste-web \
  --from=cronjob/verifica-web

kubectl -n simulado-nuvem wait \
  --for=condition=complete job/teste-web \
  --timeout=120s

kubectl -n simulado-nuvem logs job/teste-web

kubectl -n simulado-nuvem get jobs,cronjobs


# ==========================================
# ETAPA 8 - CONFERÊNCIA FINAL
# ==========================================

kubectl -n simulado-nuvem get all

kubectl -n simulado-nuvem get configmap,secret,serviceaccount,role,rolebinding
