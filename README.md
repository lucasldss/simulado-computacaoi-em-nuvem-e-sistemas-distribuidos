# simulado-computacaoi-em-nuvem-e-sistemas-distribuidos
SIMULADO PRÁTICO INTEGRADO — COMPUTAÇÃO EM NUVEM

## Simulado Cloud

**Aluno:** Lucas Henrique dos Santos
**Turma:** 4° semestre
**Professora:** Simone Tatiane do Canto  
**Data:** 11/11/2026  
**Ambiente:** Killercoda — Kubernetes Playground

---

## 1. Objetivo

O objetivo desta atividade é desenvolver, configurar e testar uma aplicação web utilizando Kubernetes.

A aplicação recebeu o nome de Simulado Cloud e utiliza o servidor Nginx para disponibilizar uma página HTML internamente no cluster.

Durante a atividade foram trabalhados conceitos de configuração, segurança, gerenciamento de aplicações, escalabilidade, recuperação de falhas e automação de tarefas.

## 2. Tecnologias e recursos utilizados

- Kubernetes
- Killercoda Kubernetes Playground
- Nginx Alpine
- BusyBox
- ConfigMap
- Secret
- Deployment
- Service
- ServiceAccount
- Role
- RoleBinding
- Readiness Probe
- Liveness Probe
- Job
- CronJob
- GitHub

## 3. Organização do projeto

```text
simulado-nuvem-nome-sobrenome/
├── README.md
├── manifests/
│   ├── 01-configmap-v1.yaml
│   ├── 02-configmap-v2.yaml
│   ├── 03-rbac.yaml
│   ├── 04-web.yaml
│   └── 05-cronjob.yaml
├── scripts/
│   └── comandos.sh
└── evidencias/
    └── resultados.md
```

## 4. Descrição da implementação

Foi criado o namespace `simulado-nuvem` para organizar todos os recursos da atividade.

O ConfigMap `pagina` armazena o conteúdo HTML da aplicação. Foram utilizadas duas versões da página para testar a atualização da configuração.

O Secret `senha-app` armazena um token fictício, disponibilizado ao contêiner por meio da variável de ambiente `TOKEN_TESTE`.

Para controlar o acesso à API do Kubernetes, foi criada a ServiceAccount `leitor-web`, associada à Role `leitura-pods` por meio de um RoleBinding.

A Role permite somente as operações `get` e `list` sobre Pods dentro do namespace.

A aplicação é executada por um Deployment chamado `web`, configurado inicialmente com duas réplicas e utilizando a imagem `nginx:alpine`.

O Service `web`, do tipo ClusterIP, permite o acesso interno à aplicação pela porta 80.

Também foram configuradas verificações de disponibilidade e funcionamento por meio de Readiness Probe e Liveness Probe.

Por fim, foi criado um CronJob chamado `verifica-web`, responsável por executar verificações periódicas da aplicação utilizando a imagem `busybox:1.36`.

## 5. Respostas às questões

### 5.1 Qual é a diferença entre contêiner, Pod e Deployment?

O contêiner é responsável por executar a aplicação e suas dependências.

O Pod é a menor unidade executável do Kubernetes e pode conter um ou mais contêineres que compartilham recursos de rede e armazenamento.

O Deployment é responsável por gerenciar os Pods, controlar a quantidade de réplicas e permitir atualizações e recuperação automática de falhas.

Neste exercício, o Nginx é executado dentro de contêineres, os contêineres estão dentro de Pods e o Deployment mantém duas réplicas da aplicação.

### 5.2 Por que ConfigMap e Secret têm finalidades diferentes?

O ConfigMap armazena configurações que não são confidenciais, como arquivos HTML e parâmetros da aplicação.

O Secret armazena informações sensíveis, como senhas, tokens e credenciais.

Neste projeto, o ConfigMap armazena o conteúdo da página HTML, enquanto o Secret guarda um token fictício utilizado pela aplicação.

Essa separação facilita o gerenciamento das configurações e evita colocar credenciais diretamente nos manifestos da aplicação.

O Secret também precisa de controles de acesso e proteção de armazenamento, pois seu conteúdo não é automaticamente seguro apenas por ser um Secret.

### 5.3 Qual é a diferença entre Readiness e Liveness?

A Readiness Probe verifica se a aplicação está pronta para receber requisições.

Quando a Readiness falha, o Pod deixa de receber tráfego pelo Service até voltar a estar pronto.

A Liveness Probe verifica se a aplicação continua funcionando corretamente.

Quando a Liveness falha repetidamente, o Kubernetes pode reiniciar o contêiner.

Neste exercício, a Readiness verifica o endereço `/index.html` e a Liveness verifica o endereço `/`, ambos na porta 80.

### 5.4 O que ocorreu após a exclusão do Pod?

Após a exclusão manual de um Pod, o Deployment identificou que a quantidade de réplicas estava abaixo do valor desejado.

O Kubernetes criou automaticamente outro Pod para manter a quantidade configurada de duas réplicas.

Esse comportamento demonstra a capacidade de autorrecuperação do Kubernetes.

O Service continuou disponibilizando a aplicação por meio dos Pods disponíveis.

### 5.5 O que o rollback recuperou? A página voltou à versão 1?

O rollback recuperou a revisão anterior do Deployment, restaurando a configuração válida da imagem do contêiner após a tentativa de atualização com uma imagem inexistente.

A página não voltou automaticamente para a versão 1, pois o ConfigMap é um recurso independente do Deployment.

Como o ConfigMap já havia sido atualizado para a versão 2, seu conteúdo continuou sendo utilizado pela aplicação.

Portanto, após o rollback, a aplicação voltou a funcionar com a imagem válida e continuou apresentando a página:

**Simulado Cloud - Versao 2**

### 5.6 Qual é a diferença entre Deployment, Job e CronJob?

O Deployment mantém aplicações em execução continuamente, controlando suas réplicas e substituindo Pods que apresentam falhas.

O Job executa uma tarefa até sua conclusão bem-sucedida.

O CronJob agenda a criação e execução de Jobs em intervalos definidos.

Neste projeto, o Deployment mantém o servidor Nginx funcionando, o Job `teste-web` executa uma verificação pontual e o CronJob `verifica-web` agenda verificações a cada cinco minutos.

## 6. Resultados esperados

- Namespace `simulado-nuvem` criado.
- ConfigMap versão 1 aplicado.
- Secret fictício criado.
- RBAC permitindo listar Pods e negando exclusão.
- Deployment com duas réplicas prontas.
- Service ClusterIP funcionando.
- Página versão 1 acessível por HTTP.
- Escalabilidade de duas para três réplicas.
- Recuperação automática após exclusão de um Pod.
- Atualização da página para versão 2.
- Falha intencional de imagem identificada.
- Rollback do Deployment realizado.
- Página versão 2 mantida após rollback.
- Job concluído com sucesso.
- CronJob configurado para execução a cada cinco minutos.

## 7. Conclusão

A atividade permitiu compreender na prática o funcionamento do Kubernetes e seus principais recursos para gerenciamento de aplicações em contêineres.

Foi possível trabalhar com configurações externas, credenciais fictícias, controle de permissões, disponibilidade, escalabilidade, recuperação de falhas, atualização de aplicações e automação de tarefas.

Os testes demonstram como o Kubernetes busca manter o estado desejado dos recursos e disponibilizar aplicações de maneira organizada e resiliente.

