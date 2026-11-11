
# EVIDÊNCIAS DE EXECUÇÃO — SIMULADO CLOUD

**Aluno:** SEU NOME COMPLETO  
**Turma:** SUA TURMA  
**Professora:** Simone Tatiane do Canto  
**Data:** 11/11/2026  

---

## 1. Cluster e namespace

**Comandos utilizados:**

```bash
kubectl get nodes
kubectl create namespace simulado-nuvem
kubectl get namespace simulado-nuvem
```

**Resultados obtidos:**

[COLAR AQUI AS SAÍDAS REAIS]

**Explicação:**

O comando `kubectl get nodes` permite consultar os nós disponíveis no cluster.

O namespace `simulado-nuvem` foi criado para organizar os recursos utilizados no exercício.

---

## 2. ConfigMap, Secret e RBAC

**Comandos utilizados:**

```bash
kubectl apply -f manifests/01-configmap-v1.yaml

kubectl -n simulado-nuvem create secret generic senha-app \
  --from-literal=token=valor-ficticio-2026

kubectl apply -f manifests/03-rbac.yaml
```

**Verificação das permissões:**

```bash
kubectl auth can-i list pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web

kubectl auth can-i delete pods -n simulado-nuvem \
  --as=system:serviceaccount:simulado-nuvem:leitor-web
```

**Resultados esperados:**

```text
yes
no
```

**Resultados reais:**

[COLAR AQUI AS SAÍDAS REAIS]

**Explicação:**

A ServiceAccount `leitor-web` recebeu permissão para consultar e listar Pods, mas não possui autorização para excluir Pods.

O ConfigMap armazena configurações não confidenciais e o Secret armazena o token fictício.

---

## 3. Deployment, Pods e Service

**Comandos utilizados:**

```bash
kubectl apply -f manifests/04-web.yaml

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem get deployment,pods,service
```

**Resultados reais:**

[COLAR AQUI AS SAÍDAS REAIS]

**Explicação:**

O Deployment foi criado com duas réplicas da aplicação Nginx.

O Service ClusterIP disponibiliza a aplicação internamente pela porta 80.

---

## 4. Teste HTTP, probes e diagnóstico

**Comandos utilizados:**

```bash
kubectl -n simulado-nuvem run cliente \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600

kubectl -n simulado-nuvem wait \
  --for=condition=Ready pod/cliente --timeout=90s

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web
```

**Resultado esperado:**

```html
<h1>Simulado Cloud - Versao 1</h1>
```

**Resultado real:**

[COLAR AQUI A SAÍDA REAL]

**Diagnóstico:**

```bash
kubectl -n simulado-nuvem describe deployment web

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp

kubectl -n simulado-nuvem logs deployment/web
```

**Resultados reais:**

[COLAR AQUI AS SAÍDAS REAIS]

**Explicação:**

A Readiness Probe verifica se a aplicação está pronta para receber requisições.

A Liveness Probe verifica se a aplicação continua funcionando. Quando falha repetidamente, pode provocar a reinicialização do contêiner.

---

## 5. Escalabilidade e autorrecuperação

**Escala para três réplicas:**

```bash
kubectl -n simulado-nuvem scale deployment web --replicas=3

kubectl -n simulado-nuvem get pods
```

**Resultado real:**

[COLAR AQUI A SAÍDA MOSTRANDO TRÊS RÉPLICAS]

**Retorno para duas réplicas:**

```bash
kubectl -n simulado-nuvem scale deployment web --replicas=2

kubectl -n simulado-nuvem get pods
```

**Resultado real:**

[COLAR AQUI A SAÍDA MOSTRANDO DUAS RÉPLICAS]

**Exclusão de um Pod:**

```bash
kubectl -n simulado-nuvem delete pod NOME_DO_POD
```

**Resultado real:**

[COLAR AQUI A SAÍDA DA EXCLUSÃO]

**Verificação da reposição:**

```bash
kubectl -n simulado-nuvem get pods
```

**Resultado real:**

[COLAR AQUI A SAÍDA MOSTRANDO O NOVO POD]

**Explicação:**

O Deployment identificou que havia menos Pods do que a quantidade desejada e criou automaticamente outro Pod para manter duas réplicas.

---

## 6. Atualização e rollback

**Atualização para versão 2:**

```bash
kubectl apply -f manifests/02-configmap-v2.yaml

kubectl -n simulado-nuvem rollout restart deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web
```

**Resultado esperado:**

```html
<h1>Simulado Cloud - Versao 2</h1>
```

**Resultado real:**

[COLAR AQUI A SAÍDA REAL]

**Falha intencional:**

```bash
kubectl -n simulado-nuvem set image deployment/web \
  nginx=nginx:tag-inexistente-simulado
```

**Verificação da falha:**

```bash
kubectl -n simulado-nuvem rollout status deployment/web --timeout=60s

kubectl -n simulado-nuvem get pods

kubectl -n simulado-nuvem get events \
  --sort-by=.metadata.creationTimestamp
```

**Resultados reais:**

[COLAR AQUI AS SAÍDAS REAIS]

**Rollback:**

```bash
kubectl -n simulado-nuvem rollout undo deployment/web

kubectl -n simulado-nuvem rollout status deployment/web

kubectl -n simulado-nuvem get deployment,pods
```

**Resultado real:**

[COLAR AQUI AS SAÍDAS REAIS]

**Teste final:**

```bash
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web
```

**Resultado esperado:**

```html
<h1>Simulado Cloud - Versao 2</h1>
```

**Explicação:**

O rollback recuperou a revisão anterior do Deployment, restaurando a imagem válida.

O ConfigMap permaneceu na versão 2, pois é um recurso independente. Por isso, a página continuou apresentando a versão 2 após o rollback.

---

## 7. Job e CronJob

**Criação do CronJob:**

```bash
kubectl apply -f manifests/05-cronjob.yaml
```

**Criação do Job manual:**

```bash
kubectl -n simulado-nuvem create job teste-web \
  --from=cronjob/verifica-web
```

**Aguardar conclusão:**

```bash
kubectl -n simulado-nuvem wait \
  --for=condition=complete job/teste-web \
  --timeout=120s
```

**Consultar os logs:**

```bash
kubectl -n simulado-nuvem logs job/teste-web
```

**Resultado esperado:**

```html
<h1>Simulado Cloud - Versao 2</h1>
```

**Resultado real:**

[COLAR AQUI O LOG REAL]

**Explicação:**

O Job foi criado a partir do CronJob e executou a verificação da aplicação imediatamente, sem precisar aguardar o intervalo de cinco minutos.

A conclusão do Job demonstra que o contêiner BusyBox conseguiu acessar o Service `web` e obter o conteúdo da página.

---

## 8. Conclusão

A atividade permitiu demonstrar o funcionamento dos principais recursos do Kubernetes.

Foram utilizados recursos de configuração, segurança, gerenciamento de aplicações, monitoramento, escalabilidade, recuperação de falhas e automação.

Os testes demonstraram como o Kubernetes mantém o estado desejado da aplicação, substitui Pods excluídos e permite realizar atualizações e rollback.

O Job também demonstrou a possibilidade de executar tarefas pontuais, enquanto o CronJob permite automatizar verificações periódicas.

**Repositório GitHub:** INSERIR LINK
