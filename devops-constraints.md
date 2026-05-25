# DEVOPS TOOLS & CLOUD COMPUTING 

## 1/5
### Objetivo
Realizar a Conteinerização em nuvem da solução proposta de uma das disciplinas: ADVANCED BUSINESS DEVELOPMENT WITH .NET ou JAVA ADVANCED

### Regras gerais
**ENTREGA - 1º SPRINT**
* Apresentar um CRUD (GET, POST, PUT, DELETE) com pelo menos 2 inserts com conteúdo significativo
* Persistência de dados com Banco H2 ou Oracle
* Implementação do Readme no GitHub do projeto apresentando: Descrição do projeto, Benefícios para o Negócio, Desenho Macro da Arquitetura, Rotas, Instalação da solução (How to), Dockerfile ou Arquivo YAML do Docker Compose e scripts do Azure CLI

A nota irá variar de acordo com a completude da entrega e, se a entrega não funcionar em nuvem, não poderá ser avaliada, ficando apenas a parte do GitHub e Arquitetura para análise e totalização da nota

---

## DEVOPS TOOLS & CLOUD COMPUTING 

## 2/5
### Tarefas
**ENTREGA - 1º SPRINT**

**01) Um Script completo criado pelo Azue CLI que realize as tarefas em sequência: (Até 20 pontos)**
* 1.1) Provisionar uma Máquina Virtual Linux na Azure
* 1.2) Abrir as portas necessárias ao projeto na VM
* 1.3) Instalar o Docker na VM criada
* 1.4) Instalar as ferramentas necessárias ao projeto (Git, nano etc )

**02) Executar a entrega de .NET ou Java na VM em nuvem utilizando Docker (App e Banco) e realizar os testes externamente (Até 60 pontos)**
* 2.1) Projeto executando em background
* 2.2) Rodar aplicação com usuário sem privilégios administrativos 
* 2.3) Volume nomeado para persistir os dados do Banco escolhido

---

## DEVOPS TOOLS & CLOUD COMPUTING 

## 3/5
**03)** Desenhe a Arquitetura Macro da sua solução na nuvem (ex: fluxo de usuários, front-end, API, banco de dados, VM, containers, etc). Utilize ferramentas como Draw.io ou Visual Paradigm (links abaixo) e inclua legendas, rótulos, imagens e setas de fluxo para facilitar a compreensão - Até 20 pontos

**04)** Ao final da entrega delete a Máquina Virtual criada – Obrigatório – Zero pontos

### Entrega
**ENTREGA - 1º SPRINT**
Grave um vídeo demonstrando: A execução do Script CLI para criar a infra (Tarefa 01), Funcionamento da aplicação com o Docker e Persistência de dados. Mostrar cada operação executada no banco escolhido (Tarefa 02)

### Entrega final
Um único arquivo PDF contendo:
* 01) Uma folha de rosto com o nome da equipe, RM e nome completo dos alunos. Inclua um índice para organização
* 02) Desenho da arquitetura com legenda, fluxos etc
* 03) Link para o repositório no GitHub
* 04) Link para o vídeo no YouTube
* 05) Print da evidencia da remoção da VM e recursos em nuvem

---

## DEVOPS TOOLS & CLOUD COMPUTING 

## 4/5
### Sugestões de ferramentas de desenho e Imagem do Banco
* **Azure Diagram Tool (Visual Paradigm)** https://online.visual-paradigm.com/diagrams/features/azure-architecture-diagram-tool/
* **Draw.io** https://app.diagrams.net/

**ENTREGA - 1º SPRINT**
* O Container do Banco Oracle fica como sugestão a imagem do Docker Hub: `gvenzl/oracle-xe`
* O Container do Banco H2 fica como sugestão a imagem do Docker Hub: `oscarfonts/h2`

#### Dicas para o Banco H2
Habilitar console do H2 pelo navegador Web - Incluir no arquivo de propriedades:
```properties
spring.h2.console.enabled=true
spring.h2.console.settings.web-allow-others=true
```
Formato da Chamada -> `jdbc:h2:tcp://[nome-do-servico-banco][:porta]/[caminho-do-banco]`  
Exemplo -> `spring.datasource.url=jdbc:h2:tcp://H2DimDim:9090/h2/data/meubanco`

---

## DEVOPS TOOLS & CLOUD COMPUTING 

## 5/5
### Penalidades
* Projeto não executando em background - menos 0,5 ponto
* Aplicação rodando com usuário root - menos 0,5 ponto
* Sem Volume nomeado para persistir os dados do Banco escolhido - menos 1,5 ponto
* Não mostrar cada operação executada no banco escolhido - menos 3,0 pontos

**ENTREGA - 1º SPRINT**
* Projeto no GitHub sem How to (Instalação da Solução) - menos 2,0 pontos
* Projeto no GitHub sem a Descrição do Projeto - menos 0,5 ponto
* Projeto no GitHub sem os Benefícios para o Negócio - menos 0,5 ponto
* Projeto no GitHub sem Script do Azure CLI - menos 3,0 pontos
* Projeto no GitHub sem Dockerfile ou YAML do Docker Compose - menos 3,0 pontos
* Entrega sem utilizar o Banco H2 ou Oracle Conteinerizado - Menos 5,0 pontos
* Entrega em LOCALHOST - Não será possível a correção - Zero de nota
* Vídeo com qualidade inferior a 720p ou sem explicação (por voz) completa da solução - Não será possível a correção - Zero de nota
* Professor sem acesso ao Repositório ou Vídeo - Não será possível a correção - Zero de nota
* **NÃO SERÁ ACEITO ENTREGA FORA DA DATA E HORA ACORDADA NO DOCUMENTO - Zero de nota**