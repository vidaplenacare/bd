# BD — SQL do banco de dados (Vida Plena)

Esta pasta é um **snapshot gerado** do schema do banco, pronto para copiar e colar direto num
Postgres (local, Supabase, ou qualquer outro) — não depende de Node, Prisma ou de rodar nenhum
comando além do `psql`/editor SQL do seu provedor.

⚠️ **Não editar os arquivos aqui manualmente.** A fonte de verdade é
`vida-plena-backend/prisma/schema.prisma`. Se o schema mudar, regenerar `schema.sql` com:

```
cd vida-plena-backend
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > ../BD/schema.sql
```

E atualizar `seed.sql` manualmente para bater com `vida-plena-backend/prisma/seed.ts`.

⚠️ **Duas exceções ao "gerado"** — os dois blocos finais de `schema.sql` **não** saem do
`prisma migrate diff`. Depois de regenerar, copiar os dois de volta para o fim do arquivo:

1. Extensão `btree_gist` + constraint `solicitacoes_sem_sobreposicao` (o Prisma não representa
   `EXCLUDE`). Sem ele, o banco criado do zero fica sem a proteção contra reservas sobrepostas.
2. `ENABLE ROW LEVEL SECURITY` em todas as tabelas (bloqueia a API pública automática do
   Supabase). Sem ele, o Supabase marca o banco como inseguro. **Tabela nova = linha nova aqui.**

Última regeneração: **2026-10-22** (inclui o aceite dos termos em `usuarios`: `termosVersao` e
`termosAceitosEm`). Antes: 2026-09-30 (Asaas, `webhook_asaas_eventos`, senha de resgate,
`situacao_cadastral`).

> **Produção:** o caminho recomendado é o do back-end — apontar `DATABASE_URL` para o banco novo e
> rodar `npx prisma migrate deploy`, que aplica as migrations em ordem e deixa o Prisma sabendo o
> que já foi aplicado. Use este `schema.sql` só quando não der para rodar o Prisma. **Nunca** rode
> o `seed.sql` em produção (são dados de teste).

## "No SQL Editor do Supabase eu só vejo tabelas, cadê as queries?"

Isso confunde bastante, mas é o comportamento normal: **o Postgres não guarda o SQL que você
rodou**. Quando um `CREATE TABLE` executa, o banco guarda a *estrutura resultante* (no catálogo
interno), não o texto do comando. Não existe um "arquivo de queries" dentro do banco.

Então:

- **SQL Editor** = uma folha em branco para *escrever e rodar* comandos. A lista lateral mostra só
  os snippets que **você salvou** ali dentro. Como o schema deste projeto é aplicado pelo Prisma
  (a partir do back-end, ver abaixo), nunca passou pelo editor — por isso não aparece nada.
- **Table Editor** = mostra as tabelas porque lê o catálogo do banco, que é o que de fato existe.

**Onde está o "código" do banco, então:** aqui nesta pasta. `schema.sql` é exatamente o SQL que
recria tudo do zero, e `vida-plena-backend/prisma/migrations/` tem o histórico passo a passo. Essa
é a fonte de verdade — não o Supabase.

Se quiser ver o SQL de uma tabela **que já está no banco**, dá para reconstruir a partir do
catálogo. Colar no SQL Editor:

```sql
-- Colunas, tipos e obrigatoriedade de uma tabela
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'solicitacoes'
ORDER BY ordinal_position;

-- Todas as constraints (incluindo a EXCLUDE de agenda) e sua definição
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'solicitacoes'::regclass;
```

## Como usar

Num banco Postgres vazio (novo projeto Supabase, instância local, etc.):

```
psql "<sua connection string>" -f schema.sql
psql "<sua connection string>" -f seed.sql
```

Ou cole o conteúdo de cada arquivo, nessa ordem, no editor SQL do painel do Supabase.

## O que tem aqui

- **`schema.sql`** — cria do zero todas as tabelas atuais (enums, tabelas, índices, chaves
  estrangeiras):
  - **Catálogo e atendimento**: `profissionais`, `solicitacoes`, `localizacao_pings`.
  - **Contas**: `usuarios`, `sessoes_dispositivo`, `cuidadores`.
  - **Perfil e saúde do membro**: `membros`, `condicoes_medicas`, `medicamentos`,
    `contatos_emergencia` — é daqui que sai a ficha que o cuidador vê de quem vai atender.
  - **Verificação profissional**: `cadastros_cuidador`, `cadastro_documentos`,
    `cadastro_quiz_respostas`.
  - **Dinheiro**: `pagamentos` (cobrança de cada contratação no Asaas, com a retenção até a
    conclusão), `resgates` (saque do cuidador para a chave Pix, protegido pela senha de resgate
    guardada em `cuidadores`) e `webhook_asaas_eventos` (avisos do Asaas já processados, para não
    aplicar o mesmo aviso duas vezes).
  - **Outros**: `push_tokens`.
- **`seed.sql`** — os 4 profissionais mock + 1 solicitação de teste (`sol-1`, faixa de 3h) com sua
  cobrança pendente, usada para validar o GPS em tempo real e o fluxo de pagamento.

### Agenda: como o horário fica reservado

Cada linha de `solicitacoes` é uma faixa contratada (`inicioEm` → `fimEm`), e é isso que monta a
agenda do profissional. A constraint `solicitacoes_sem_sobreposicao` faz o **banco** recusar duas
reservas do mesmo profissional que se cruzem no tempo, considerando só os status que seguram o
horário (`aceita`, `em_andamento`, `concluida`) — `pendente` fica de fora porque vários membros
podem pedir o mesmo horário e só um será aceito. Isso é o que evita que dois aparelhos fechem o
mesmo horário ao mesmo tempo; a checagem na tela do app sozinha não garante.

O preço fica congelado na contratação (`valorHora` + `valorTotal`): mudar o preço do profissional
depois não altera o que já foi combinado.

## O que isso NÃO cobre

Este é só o modelo mínimo que já está implementado e rodando (ver `INTEGRACOES-EXTERNAS.md` e
`BACKEND-ARQUITETURA.md` em `vida-plena-app/` para o resto do que ainda falta — autenticação,
solicitações completas, cuidadores/documentos, notificações etc.).
