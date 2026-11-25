-- Dados iniciais (espelha vida-plena-backend/prisma/seed.ts).
-- Rodar depois de schema.sql, num banco que já tem as tabelas criadas.

INSERT INTO "profissionais" (
  "id", "nome", "especialidade", "categoria", "experiencia", "avaliacao", "totalAvaliacoes",
  "foto", "nivelOcupacao", "bio", "formacao", "areasAtuacao", "disponibilidade",
  "diasDisponiveis", "horarioInicio", "horarioFim", "valorVisita", "telefone"
) VALUES
(
  'prof-1', 'Ana Paula Santos', 'Enfermagem Geriátrica', 'enfermeiro', '8 anos', 4.9, 127,
  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop', 'livre',
  'Enfermeira especializada em cuidados geriátricos, com foco em curativos, administração de medicamentos e acompanhamento de doenças crônicas.',
  'CRT Enfermagem · Especialização em Geriatria',
  ARRAY['Curativos', 'Administração de medicamentos', 'Acompanhamento de crônicos'],
  'Segunda a sábado, 8h às 18h', ARRAY[1, 2, 3, 4, 5, 6], '08:00', '18:00', 180, '11987654321'
),
(
  'prof-2', 'Carlos Eduardo Silva', 'Cuidador de Idosos', 'cuidador', '5 anos', 4.8, 89,
  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&h=400&fit=crop', 'parcial',
  'Cuidador com experiência em higiene pessoal, mobilidade e apoio em atividades diárias para idosos com Alzheimer e mobilidade reduzida.',
  'Curso Técnico em Cuidados com Idosos · Alzheimer',
  ARRAY['Higiene pessoal', 'Mobilidade', 'Alzheimer'],
  'Todos os dias, período integral', ARRAY[0, 1, 2, 3, 4, 5, 6], '07:00', '21:00', 120, '11976543210'
),
(
  'prof-3', 'Mariana Costa', 'Fisioterapia Motora', 'fisioterapeuta', '10 anos', 5.0, 156,
  'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&h=400&fit=crop', 'lotado',
  'Fisioterapeuta especializada em reabilitação motora e prevenção de quedas, com atendimento domiciliar personalizado.',
  'CRT Fisioterapia · Reabilitação Motora',
  ARRAY['Reabilitação motora', 'Prevenção de quedas', 'Fortalecimento muscular'],
  'Terça a sexta, 9h às 17h', ARRAY[2, 3, 4, 5], '09:00', '17:00', 150, '11965432109'
),
(
  'prof-4', 'Roberto Almeida', 'Acompanhante Noturno', 'acompanhante', '6 anos', 4.7, 73,
  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&h=400&fit=crop', 'livre',
  'Acompanhante noturno com treinamento em primeiros socorros, oferecendo companhia e segurança durante a noite.',
  'Curso Técnico · Primeiros Socorros',
  ARRAY['Companhia noturna', 'Primeiros socorros', 'Monitoramento do sono'],
  'Todas as noites, 20h às 7h', ARRAY[0, 1, 2, 3, 4, 5, 6], '20:00', '07:00', 140, '11954321098'
)
ON CONFLICT ("id") DO UPDATE SET
  "nome" = EXCLUDED."nome",
  "especialidade" = EXCLUDED."especialidade",
  "categoria" = EXCLUDED."categoria",
  "experiencia" = EXCLUDED."experiencia",
  "avaliacao" = EXCLUDED."avaliacao",
  "totalAvaliacoes" = EXCLUDED."totalAvaliacoes",
  "foto" = EXCLUDED."foto",
  "nivelOcupacao" = EXCLUDED."nivelOcupacao",
  "bio" = EXCLUDED."bio",
  "formacao" = EXCLUDED."formacao",
  "areasAtuacao" = EXCLUDED."areasAtuacao",
  "disponibilidade" = EXCLUDED."disponibilidade",
  "diasDisponiveis" = EXCLUDED."diasDisponiveis",
  "horarioInicio" = EXCLUDED."horarioInicio",
  "horarioFim" = EXCLUDED."horarioFim",
  "valorVisita" = EXCLUDED."valorVisita",
  "telefone" = EXCLUDED."telefone";

-- Liga o perfil de catálogo "prof-2" à conta de teste de cuidador, e é isso que autoriza as rotas
-- de /cuidador (aceitar/iniciar/concluir) — sem dono, ninguém consegue agir sobre as solicitações
-- feitas para esse perfil. "prof-2" de propósito: é o mesmo profissional da solicitação de teste
-- abaixo, então membro e cuidador de teste veem OS DOIS LADOS da mesma contratação.
--
-- Não faz nada se a conta ainda não existir (este arquivo não cria usuários: a senha precisa passar
-- pelo hash do fluxo real). Crie cuidador@teste.com pelo app ou por POST /auth/cadastro-cuidador e
-- rode de novo. O UPDATE que zera vínculos anteriores existe porque "usuarioId" é único.
UPDATE "profissionais" SET "usuarioId" = NULL
WHERE "usuarioId" IN (SELECT "id" FROM "usuarios" WHERE "email" = 'cuidador@teste.com')
  AND "id" <> 'prof-2';

UPDATE "profissionais"
SET "usuarioId" = (SELECT "id" FROM "usuarios" WHERE "email" = 'cuidador@teste.com' AND "tipo" = 'cuidador')
WHERE "id" = 'prof-2'
  AND EXISTS (SELECT 1 FROM "usuarios" WHERE "email" = 'cuidador@teste.com' AND "tipo" = 'cuidador');

-- Solicitação de teste para o sistema de GPS em tempo real — mesmo id ("sol-1") do mock em
-- vida-plena-app/src/contexts/AppContext.tsx, servindo de ponte entre o app e o banco real
-- enquanto não existe autenticação/identidade real ligando os dois lados.
-- "inicioEm" 31min no futuro (mesma regra do prisma/seed.ts: AVISO_MINUTOS_ANTES + 1) — uma data
-- no passado faria o agendador nunca disparar o aviso de 30min. A faixa é de 3h, e "valorHora"
-- copia o preço atual de prof-2 (R$ 120,00/hora), com "valorTotal" = 3 × valor/hora.
-- "usuarioId" aponta para a conta de teste do membro quando ela existe: GET /solicitacoes filtra
-- pelo dono, então sem isso a contratação só apareceria para o cuidador. Os dois lados precisam
-- ver a mesma linha.
INSERT INTO "solicitacoes" (
  "id", "cuidadorId", "usuarioId", "membroNome", "status", "observacoes",
  "inicioEm", "fimEm", "valorHora", "valorTotal"
)
VALUES (
  'sol-1', 'prof-2',
  (SELECT "id" FROM "usuarios" WHERE "email" = 'membro@teste.com'),
  COALESCE((SELECT "nome" FROM "usuarios" WHERE "email" = 'membro@teste.com'), 'Maria Oliveira'),
  'aceita',
  'Cuidado para minha mãe, que tem mobilidade reduzida.',
  CURRENT_TIMESTAMP + INTERVAL '31 minutes',
  CURRENT_TIMESTAMP + INTERVAL '31 minutes' + INTERVAL '3 hours',
  120, 360
)
ON CONFLICT ("id") DO UPDATE SET
  "usuarioId" = EXCLUDED."usuarioId",
  "membroNome" = EXCLUDED."membroNome",
  "inicioEm" = EXCLUDED."inicioEm",
  "fimEm" = EXCLUDED."fimEm",
  "valorHora" = EXCLUDED."valorHora",
  "valorTotal" = EXCLUDED."valorTotal",
  "observacoes" = EXCLUDED."observacoes",
  "avisoEnviadoEm" = NULL,
  "compartilhamentoAutorizado" = false;

-- Cobrança da solicitação de teste no estado que o app espera: aceita e aguardando pagamento
-- (é o pagamento que libera a visita — modelo de garantia, ver DEV-NOTES.md 2026-09-10).
INSERT INTO "pagamentos" ("id", "solicitacaoId", "valor", "status", "atualizadoEm")
VALUES ('pag-sol-1', 'sol-1', 360, 'pendente', CURRENT_TIMESTAMP)
ON CONFLICT ("solicitacaoId") DO UPDATE SET
  "valor" = EXCLUDED."valor",
  "status" = 'pendente',
  "forma" = NULL,
  "pagoEm" = NULL,
  "liberadoEm" = NULL,
  "atualizadoEm" = CURRENT_TIMESTAMP;
