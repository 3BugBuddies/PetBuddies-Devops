# Plano — Entrega DevOps Tools & Cloud Computing (Sprint 1)

## Contexto

Entrega de conteinerização **em Azure VM** de uma das disciplinas (Java ou .NET). O avaliador vai assistir a um vídeo demonstrando: execução do script Azure CLI → app rodando via Docker → operações persistindo no banco. Estado atual em `teste-devops/` está 80% pronto, mas tem confusões reais a resolver antes do vídeo.

**Critérios obrigatórios:**
- Script Azure CLI completo (VM Linux + portas + Docker + ferramentas)
- App rodando em background com **usuário não-root** + volume nomeado pro banco
- 2 inserts significativos + CRUD demonstrado (GET, POST, PUT, DELETE)
- README com descrição, benefícios, arquitetura macro, rotas, how-to, Dockerfile/Compose, scripts Azure CLI
- Vídeo ≥720p com narração

**Penalidades pesadas:** sem volume nomeado (-1.5), sem How To (-2), sem Azure CLI script (-3), sem Dockerfile/compose (-3), banco não conteinerizado (-5), entrega em localhost = 0.

---

## Estado atual em `teste-devops/`

### ✅ Pronto

| Item | Detalhes |
|---|---|
| `azure-deploy.sh` | 5 passos: RG → VM Ubuntu 22.04 `Standard_B4ms` → portas 22/8080/5000/8081 → Docker+Git → clone + `docker compose up -d --build` |
| `docker-compose.yml` | 5 serviços: `oracle-xe` (gvenzl/oracle-xe:21-slim), `petbuddies-java`, `petbuddies-net`, `postgres` (Evolution), `evolution-api` |
| Volumes nomeados | `oracle_data`, `evolution_postgres_data`, `evolution_instances` ✓ |
| Healthchecks | Oracle (300s startup), Postgres (`pg_isready`), `depends_on` com `service_healthy` ✓ |
| `Dockerfile` Java | Multi-stage, Alpine, usuário `petbuddies` não-root, expose 8080, timezone São Paulo ✓ |
| `Dockerfile` .NET | Multi-stage, usuário `appuser` não-root, expose 80 ✓ |
| `.env.example` | Variáveis nomeadas e organizadas por seção ✓ |

### ❌ Gaps reais

| Gap | Impacto |
|---|---|
| Java **não tem `application-docker.yml`** | Variáveis `${ORACLE_URL}`, `${GEMINI_API_KEY}` injetadas pelo compose **não são lidas**; Spring cai em `application.yml` padrão com hardcodes locais → app não conecta no Oracle do container |
| .NET **não tem `appsettings.Docker.json`** | `ASPNETCORE_ENVIRONMENT=Docker` resolve pra arquivo inexistente; cai em `appsettings.json` com `oracle.fiap.com.br` hardcoded → não conecta no Oracle do container |
| `REPO_URL` placeholder | `azure-deploy.sh` tem `https://github.com/SEU_ORG/SEU_REPO.git` — precisa de URL real |
| Pasta `docker/` solta | Backup/duplicata dos Dockerfiles, parece abandonada |
| Sem README dedicado a DevOps | Falta o README com descrição/benefícios/arquitetura/how-to específicos |
| Sem diagrama de arquitetura macro | Item de 20 pontos no PDF final |

---

## Resolução das suas confusões

### 1. Dockerfiles — precisa criar/ajustar?

**Não.** Os dois Dockerfiles já estão prontos e corretos:
- `teste-devops/petbuddies-ai/Dockerfile` — multi-stage, user `petbuddies` (não-root), expose 8080
- `teste-devops/PetBuddies-API/Dockerfile` — multi-stage, user `appuser` (não-root), expose 80

A pasta `teste-devops/docker/` parece duplicata — recomendo **remover** ou documentar como "rascunho histórico" pra não confundir avaliador.

### 2. Docker Hub registry — precisa?

**Não.** O `docker-compose.yml` usa `build: ./petbuddies-ai` e `build: ./PetBuddies-API` — a VM clona o repo e builda os containers localmente. Funciona, é simples, atende ao requisito.

**Custo de não usar registry:** primeiro `docker compose up --build` leva ~5 min na VM (Maven baixa deps, .NET restore, Oracle puxa imagem). Aceitável pra demo.

**Alternativa Docker Hub** só vale se o vídeo precisar mostrar deploy <2 min — não é o caso. Manter como está.

### 3. Como importar `.env` dos projetos

**Esclarecimento:** há **três níveis de configuração** que se confundem. Separação correta:

| Arquivo | Quem usa | Onde fica | O que contém |
|---|---|---|---|
| `teste-devops/.env` | docker-compose.yml | raiz `teste-devops/` | Credenciais Oracle XE local, GEMINI_API_KEY, conn strings com hostnames dos containers (`oracle-xe`, `postgres`) |
| `application-docker.yml` | Spring Boot Java | `petbuddies-ai/src/main/resources/` | Placeholders Spring `${ORACLE_URL}`, `${GEMINI_API_KEY}` que **leem do environment do container** (que o compose preencheu via `.env`) |
| `appsettings.Docker.json` | ASP.NET .NET | `PetBuddies-API/PetBuddies-API/` | Estrutura JSON com placeholders ou referência ao env var (`ConnectionStrings__Oracle` é lido automaticamente do environment via `IConfiguration`) |

**Fluxo:**
1. Avaliador copia `.env.example` → `.env` (na VM ou local) e preenche `GEMINI_API_KEY`
2. `docker compose up` lê `.env`, injeta variáveis nos containers (via `env_file` e `environment` no compose)
3. Java lê variáveis via `application-docker.yml` (`spring.datasource.url: ${ORACLE_URL}`)
4. .NET lê via `IConfiguration` (`ConnectionStrings:Oracle` resolve automaticamente de env var `ConnectionStrings__Oracle`)

**Os `.env` dos projetos (se existirem em `petbuddies-ai/.env` ou similar) NÃO entram** — só o `.env` da raiz do `teste-devops/`.

### 4. Ciclo de apresentação — CRUD ou bot?

**Recomendação: CRUD principalmente, bot como bônus final.**

| Opção | Pros | Contras |
|---|---|---|
| **Só CRUD** | Atende 100% do critério, controlável | Menos "wow", igual a qualquer entrega |
| **Só bot** | Impactante visualmente | Exige Evolution funcionando + WhatsApp pareado + LLM (custo Gemini); avaliador pode questionar se isso conta como "CRUD com 2 inserts significativos" |
| **CRUD + bot bônus** | Cobre critério + diferencia | Vídeo mais longo, mais coisa pra dar errado |

**Sugestão concreta:** roteiro principal = CRUD da API **Java de Protocolo** (mesma entidade do plano anterior — aproveita o trabalho). No final do vídeo, 30s de bônus mostrando o bot respondendo no WhatsApp ("nota que tudo isso roda no mesmo docker compose na Azure").

Por que Java? Porque a entrega DevOps + Java casa naturalmente (a disciplina "Java Advanced" é a paralela). E porque o plano anterior já está construindo o controller de Protocolo — reaproveita 100%.

### 5. Curls da apresentação

Para a entidade **Protocolo** (Java), sequência sugerida pro vídeo:

```bash
# 1) Lista vazia
curl http://<IP_VM>:8080/api/protocolos
# → []

# 2) POST insere protocolo #1 (Vacinação anual cães)
curl -X POST http://<IP_VM>:8080/api/protocolos \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Vacinacao Anual Caes","categoria":"PREVENTIVO","especie":"CACHORRO","porte":"MEDIO","sexo":"MACHO","idadeMinMeses":12,"idadeMaxMeses":180}'
# → 201 Created

# 3) POST insere protocolo #2 (Pós-cirúrgico castração)
curl -X POST http://<IP_VM>:8080/api/protocolos \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Pos Cirurgico Castracao","categoria":"POS_CIRURGICO","especie":"GATO","porte":"PEQUENO","sexo":"FEMEA","idadeMinMeses":6,"idadeMaxMeses":120}'
# → 201 Created

# 4) GET lista mostra os 2 inseridos
curl http://<IP_VM>:8080/api/protocolos
# → [...] dois itens

# 5) GET com filtro (busca customizada)
curl 'http://<IP_VM>:8080/api/protocolos/buscar?categoria=PREVENTIVO&especie=CACHORRO'

# 6) PUT atualiza
curl -X PUT http://<IP_VM>:8080/api/protocolos/1 \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Vacinacao Anual Caes Atualizada","categoria":"PREVENTIVO","especie":"CACHORRO","porte":"MEDIO","sexo":"MACHO","idadeMinMeses":12,"idadeMaxMeses":180}'

# 7) DELETE
curl -X DELETE http://<IP_VM>:8080/api/protocolos/2
# → 204 No Content

# 8) Mostrar persistência no Oracle (sqlplus dentro do container)
docker exec -it petbuddies_oracle sqlplus petbuddies/petbuddies123@//localhost:1521/XEPDB1
SQL> SELECT * FROM T_PB_PROTOCOLO;
```

Esses 8 passos cobrem: 2+ inserts significativos, GET, POST, PUT, DELETE, busca parametrizada, evidência de persistência no banco.

### 6. Script Azure CLI parecendo genérico

O script atual **não está genérico** — está completo. O que está parecendo "genérico" é o `REPO_URL` placeholder + comentários sem alinhamento à apresentação. Ajustes pra dar identidade:

- Substituir `REPO_URL="https://github.com/SEU_ORG/SEU_REPO.git"` por URL real do repo
- Adicionar comentário no topo com nome do grupo + RM
- No final, ecoar os comandos curl da demonstração (avaliador vê o que testar)
- Adicionar **comando de delete** comentado no fim (pra mostrar que sabemos que precisa deletar)

O script **bate sim com a apresentação**: cria VM → instala Docker → clona repo → `docker compose up` → app sobe → curls funcionam. A sensação de desconexão vinha do `REPO_URL` placeholder e da falta de README amarrando script ↔ demo.

---

## Trabalho a fazer

### Bloco A — Configuração de profile dos apps (crítico)

1. Criar `teste-devops/petbuddies-ai/src/main/resources/application-docker.yml`:
   - `spring.datasource.url: ${ORACLE_URL}`
   - `spring.datasource.username: ${ORACLE_USER}`
   - `spring.datasource.password: ${ORACLE_PASSWORD}`
   - `spring.jpa.hibernate.ddl-auto: update`
   - `spring.ai.openai.api-key: ${GEMINI_API_KEY}` + demais configs de LLM
   - URLs Evolution: `${EVOLUTION_API_URL}`, `${EVOLUTION_API_KEY}`, `${EVOLUTION_API_INSTANCE}`

2. Criar `teste-devops/PetBuddies-API/PetBuddies-API/appsettings.Docker.json`:
   - `ConnectionStrings.Oracle` ausente (vem do env var `ConnectionStrings__Oracle`)
   - `Logging`, `AllowedHosts` padrão
   - `MotorApi.BaseUrl` ausente (vem do env var)
   - Garante que `Program.cs` faça `Database.Migrate()` no startup (alinhado ao plano anterior)

3. Verificar se `appsettings.Docker.json` precisa estar incluído no `.csproj` com `CopyToOutputDirectory`.

### Bloco B — Polimento do script Azure CLI

1. Substituir `REPO_URL` por URL real do repo (a definir com o usuário)
2. Adicionar comentário-cabeçalho com grupo + RMs
3. Ecoar comandos curl da demo no output final do script
4. Adicionar bloco comentado de deletion no final:
   ```bash
   # Ao finalizar:
   # az group delete --name petbuddies-rg --yes --no-wait
   ```

### Bloco C — README específico de DevOps

Criar `teste-devops/README.md` com:

1. **Descrição do projeto** (PetBuddies + objetivo do challenge)
2. **Benefícios para o negócio** (cuidado contínuo, integração WhatsApp, etc — 3-4 bullets)
3. **Arquitetura macro** — imagem do diagrama (Draw.io) + legenda
4. **Rotas** (tabela de endpoints CRUD do Protocolo + ping dos outros serviços)
5. **How to** (passo a passo):
   - Pré-requisitos (`az login`)
   - Editar `REPO_URL` no script
   - Rodar `bash azure-deploy.sh`
   - Pegar IP da VM no output
   - Editar `.env` na VM (`GEMINI_API_KEY`)
   - Rodar curls da seção 5
   - Conectar no Oracle e mostrar dados
   - **Deletar VM ao final**
6. **Dockerfile/Compose** (link pros arquivos)
7. **Script Azure CLI** (link)
8. **Grupo + RMs**

### Bloco D — Diagrama de arquitetura macro

Criar diagrama em Draw.io exportado como PNG em `teste-devops/docs/arquitetura-macro.png`:

- Camadas: Usuário → Internet → Azure VM → Docker network → containers
- 5 containers visíveis: Oracle XE, Java (Spring), .NET (ASP.NET), Postgres, Evolution
- Volumes nomeados representados (cilindros)
- Setas de fluxo: usuário → port 8080 → Java; Java ↔ Oracle; Java ↔ Evolution
- Legenda explicando cada componente

### Bloco E — Limpeza

1. Avaliar pasta `teste-devops/docker/` — remover ou mover pra `docs/legacy/`
2. Garantir `.env` real **não** está versionado (verificar `.gitignore`)
3. Garantir `.env.example` está versionado

### Bloco F — Pré-entrega (executar quando o plano de APIs terminar)

1. Sincronizar código fechado da raiz (`petbuddies-ai/`, `PetBuddies-API/`) para dentro de `teste-devops/` (cópia ou rsync)
2. Validar build via `docker compose up -d --build` localmente após cada sincronização
3. Na entrega final: promover `teste-devops/` para raiz do workspace ou ajustar README pra apontar `cd teste-devops` no how-to
4. **Criar repo público no GitHub** e substituir `REPO_URL` no `azure-deploy.sh:14`

---

## Roteiro do vídeo (≥720p)

| Bloco | Duração | O que mostrar |
|---|---|---|
| 1. Apresentação | 30s | Quem somos, qual problema, qual disciplina |
| 2. Arquitetura | 60s | Diagrama macro, explicar fluxo |
| 3. Script Azure CLI | 90s | `bash azure-deploy.sh` rodando, mostrar cada passo (RG, VM, portas, Docker, clone, compose up) |
| 4. Verificação dos containers | 30s | `ssh` na VM, `docker compose ps`, mostrar 5 containers `healthy` |
| 5. CRUD Java — Protocolo | 150s | Curls Protocolo (lista, POST x2, GET, filtro, PUT, DELETE) contra `<IP>:8080` |
| 6. CRUD .NET — Clinica | 120s | Curls Clinica (lista, POST x2, GET, GET parametrizada, PUT, DELETE) contra `<IP>:5000` |
| 7. Persistência no Oracle | 45s | `docker exec petbuddies_oracle sqlplus ...` + `SELECT * FROM T_PB_PROTOCOLO` e `T_PB_CLINICA` mostrando inserts dos dois apps no mesmo banco |
| 8. **Bônus — Bot WhatsApp** | 30s | Enviar mensagem no WhatsApp, mostrar bot respondendo com integração Java ↔ Evolution ↔ Gemini |
| 9. Deletar VM | 20s | `az group delete --name petbuddies-rg --yes` + print da remoção |

Total: ~10 minutos.

### Curls .NET — Clinica (complemento da seção 5)

Pré-requisito: cadastrar Endereco antes (FK obrigatória).

```bash
# 0) Cadastra endereço (pré-requisito da clínica)
curl -X POST http://<IP_VM>:5000/api/endereco \
  -H 'Content-Type: application/json' \
  -d '{"rua":"Av Paulista","numero":"1000","cep":"01310100","cidade":"Sao Paulo","estado":"SP"}'
# → 201 Created (anota o id)

# 1) Lista clínicas (vazio)
curl http://<IP_VM>:5000/api/clinica

# 2) POST clínica #1
curl -X POST http://<IP_VM>:5000/api/clinica \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Centro","cnpj":"12345678000100","telefone":"1133334444","email":"centro@petbuddies.com","enderecoId":1}'

# 3) POST clínica #2
curl -X POST http://<IP_VM>:5000/api/clinica \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Zona Sul","cnpj":"12345678000200","telefone":"1155556666","email":"zonasul@petbuddies.com","enderecoId":1}'

# 4) GET lista
curl http://<IP_VM>:5000/api/clinica

# 5) GET por id
curl http://<IP_VM>:5000/api/clinica/1

# 6) GET por CNPJ (3ª variação parametrizada — a criar no plano anterior)
curl http://<IP_VM>:5000/api/clinica/por-cnpj/12345678000100

# 7) PUT atualiza
curl -X PUT http://<IP_VM>:5000/api/clinica/1 \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Centro Renovado","cnpj":"12345678000100","telefone":"1133334444","email":"centro@petbuddies.com","enderecoId":1}'

# 8) DELETE
curl -X DELETE http://<IP_VM>:5000/api/clinica/2
```

---

## Decisões fechadas

1. **Sincronização** — manter `teste-devops/` separado por enquanto. Workflow: (a) fechar as APIs na raiz seguindo o plano anterior, (b) depois sincronizar o código fechado para `teste-devops/petbuddies-ai/` e `teste-devops/PetBuddies-API/`, (c) na hora da entrega final, remover/limpar as cópias da raiz e promover `teste-devops/` para fonte da verdade. Não dá pra fazer agora porque a feature ainda não está pronta na raiz.
2. **Bot WhatsApp no vídeo** — sim, 30s finais como bônus. Stack inteiro vivo na Azure.
3. **CRUD no vídeo** — mostrar **ambos** Java (Protocolo) e .NET (Clinica). Vídeo total ~10 min.
4. **REPO_URL** — **TODO antes de gravar o vídeo**. Repo público no GitHub ainda não criado. Quando criar, substituir em `azure-deploy.sh:14`.

---

## Verificação end-to-end

### Local (antes de subir pra Azure)
1. `cd teste-devops && cp .env.example .env`
2. Preencher `.env` com credenciais Oracle XE (qualquer senha) + GEMINI_API_KEY
3. `docker compose up -d --build`
4. Aguardar `docker compose ps` mostrar todos `healthy`
5. Rodar os 7 curls localmente apontando pra `localhost:8080`
6. `docker exec petbuddies_oracle sqlplus ...` validar dados

### Azure (ensaio do vídeo)
1. `az login`
2. Substituir `REPO_URL` no script
3. `bash azure-deploy.sh`
4. Esperar ~10 min (criação VM + apt-get + Docker pull + Maven build + .NET restore + Oracle startup 300s)
5. SSH na VM: `ssh petbuddies@<IP>`
6. `cd clyvo/teste-devops && nano .env` → preencher GEMINI_API_KEY
7. `docker compose up -d` (se ainda não rodou — o script já roda)
8. Rodar curls da seção 5 contra `<IP>:8080`
9. `docker exec ... sqlplus` mostrar dados
10. `az group delete --name petbuddies-rg --yes --no-wait` + print
