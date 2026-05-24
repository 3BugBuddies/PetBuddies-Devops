# PetBuddies — Cheatsheet de Demo

> Substitua `<IP>` pelo IP exibido ao final do `azure-deploy.sh`.

---

## 1. Acesso à VM

```bash
ssh petbuddies@<IP>
# senha: PetBuddies@2026
```

### Bootstrap (executar uma vez após SSH)

```bash
git clone https://github.com/3BugBuddies/PetBuddies-Devops.git petbuddies
cd petbuddies
cp .env.example .env
nano .env
# Preencher:
#   ORACLE_ROOT_PASSWORD, ORACLE_APP_USER, ORACLE_APP_PASSWORD
#   ORACLE_USER  (mesmo valor que ORACLE_APP_USER)
#   GEMINI_API_KEY
#   POSTGRES_USER, POSTGRES_PASSWORD
docker compose up -d --build
```

---

## 2. Monitorar containers

```bash
docker compose ps
docker compose logs -f petbuddies-java   # acompanhar Java em tempo real
docker compose logs -f petbuddies-net
docker compose logs petbuddies_oracle    # checar se Oracle está healthy
```

---

## 3. Java — Protocolo (porta 8080)

```bash
# Lista vazia
curl http://<IP>:8080/api/protocolos

# POST 1 — vacinação anual cães
curl -X POST http://<IP>:8080/api/protocolos \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Vacinacao Anual Caes","categoria":"PREVENTIVO","especie":"CACHORRO","porte":"MEDIO","sexo":"MACHO","idadeMinMeses":12,"idadeMaxMeses":180}'

# POST 2 — pós-cirúrgico castração gato
curl -X POST http://<IP>:8080/api/protocolos \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Pos Cirurgico Castracao","categoria":"POS_CIRURGICO","especie":"GATO","porte":"PEQUENO","sexo":"FEMEA","idadeMinMeses":6,"idadeMaxMeses":120}'

# GET — lista os 2
curl http://<IP>:8080/api/protocolos

# GET — filtro
curl "http://<IP>:8080/api/protocolos/buscar?categoria=PREVENTIVO&especie=CACHORRO"

# PUT — atualiza protocolo 1
curl -X PUT http://<IP>:8080/api/protocolos/1 \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Vacinacao Anual Caes Atualizada","categoria":"PREVENTIVO","especie":"CACHORRO","porte":"MEDIO","sexo":"MACHO","idadeMinMeses":12,"idadeMaxMeses":180}'

# DELETE — remove protocolo 2
curl -X DELETE http://<IP>:8080/api/protocolos/2

# GET — confirma que restou só o 1
curl http://<IP>:8080/api/protocolos
```

---

## 4. .NET — Endereço e Clínica (porta 5000)

> CEP: 8 dígitos sem traço. CNPJ: 14 dígitos sem pontuação. Endereço deve ser criado antes da clínica.

```bash
# POST — endereço (pré-requisito)
curl -X POST http://<IP>:5000/api/endereco \
  -H 'Content-Type: application/json' \
  -d '{"logradouro":"Av. Paulista","numero":"1000","cidade":"Sao Paulo","estado":"SP","cep":"01310100"}'

# POST — clínica 1
curl -X POST http://<IP>:5000/api/clinica \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Centro","cnpj":"12345678000100","telefone":"1133334444","email":"centro@petbuddies.com","enderecoId":1}'

# POST — clínica 2
curl -X POST http://<IP>:5000/api/clinica \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Zona Sul","cnpj":"98765432000100","telefone":"1155556666","email":"zonasul@petbuddies.com","enderecoId":1}'

# GET — lista as 2
curl http://<IP>:5000/api/clinica

# GET — busca por nome
curl "http://<IP>:5000/api/clinica/buscar?nome=Centro"

# PUT — atualiza clínica 1
curl -X PUT http://<IP>:5000/api/clinica/1 \
  -H 'Content-Type: application/json' \
  -d '{"nome":"PetBuddies Centro Renovado","cnpj":"12345678000100","telefone":"1133334444","email":"centro@petbuddies.com","enderecoId":1}'

# DELETE — remove clínica 2
curl -X DELETE http://<IP>:5000/api/clinica/2

# GET — confirma que restou só a 1
curl http://<IP>:5000/api/clinica
```

---

## 5. Persistência no Oracle

```bash
# Conectar ao Oracle (executar dentro da VM)
docker exec -it petbuddies_oracle sqlplus <ORACLE_APP_USER>/<ORACLE_APP_PASSWORD>@//localhost:1521/XEPDB1
```

```sql
-- Protocolos (Java)
SELECT id, nome, categoria, especie FROM T_PB_PROTOCOLO;

-- Clínicas (.NET)
SELECT id, nome, cnpj FROM T_PB_CLINICA;

EXIT;
```

---

## 6. Remoção da VM (obrigatório ao final)

```bash
az group delete --name petbuddies-rg --yes --no-wait
```

Aguardar exclusão no portal Azure e capturar print como evidência para o PDF.
