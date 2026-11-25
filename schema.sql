-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "CategoriaProfissional" AS ENUM ('cuidador', 'enfermeiro', 'fisioterapeuta', 'acompanhante');

-- CreateEnum
CREATE TYPE "NivelOcupacao" AS ENUM ('livre', 'parcial', 'lotado');

-- CreateEnum
CREATE TYPE "StatusSolicitacao" AS ENUM ('pendente', 'aceita', 'em_andamento', 'concluida', 'recusada', 'cancelada');

-- CreateEnum
CREATE TYPE "AutorAvaliacao" AS ENUM ('membro', 'cuidador');

-- CreateEnum
CREATE TYPE "FormaPagamento" AS ENUM ('pix', 'cartao');

-- CreateEnum
CREATE TYPE "StatusPagamento" AS ENUM ('pendente', 'pago', 'liberado', 'estornado', 'cancelado');

-- CreateEnum
CREATE TYPE "StatusResgate" AS ENUM ('processando', 'concluido', 'falhou');

-- CreateEnum
CREATE TYPE "CategoriaCuidador" AS ENUM ('cuidador', 'tecnico', 'enfermeiro');

-- CreateEnum
CREATE TYPE "StatusVerificacaoCadastro" AS ENUM ('em_analise', 'aprovado', 'reprovado');

-- CreateEnum
CREATE TYPE "TipoDocumentoCadastro" AS ENUM ('rg_cnh', 'comprovante_endereco', 'antecedentes_criminais', 'certificado_cuidador', 'coren_comprovante', 'diploma', 'situacao_cadastral');

-- CreateEnum
CREATE TYPE "TipoUsuario" AS ENUM ('membro', 'cuidador');

-- CreateEnum
CREATE TYPE "StatusDocumentoMembro" AS ENUM ('pendente', 'verificado');

-- CreateTable
CREATE TABLE "profissionais" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT,
    "nome" TEXT NOT NULL,
    "especialidade" TEXT NOT NULL,
    "categoria" "CategoriaProfissional" NOT NULL,
    "experiencia" TEXT NOT NULL,
    "avaliacao" DOUBLE PRECISION NOT NULL,
    "totalAvaliacoes" INTEGER NOT NULL,
    "foto" TEXT NOT NULL,
    "nivelOcupacao" "NivelOcupacao" NOT NULL,
    "bio" TEXT NOT NULL,
    "formacao" TEXT NOT NULL,
    "areasAtuacao" TEXT[],
    "disponibilidade" TEXT NOT NULL,
    "diasDisponiveis" INTEGER[],
    "horarioInicio" TEXT NOT NULL,
    "horarioFim" TEXT NOT NULL,
    "valorVisita" DOUBLE PRECISION NOT NULL,
    "telefone" TEXT NOT NULL,

    CONSTRAINT "profissionais_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "solicitacoes" (
    "id" TEXT NOT NULL,
    "cuidadorId" TEXT NOT NULL,
    "usuarioId" TEXT,
    "membroNome" TEXT NOT NULL,
    "status" "StatusSolicitacao" NOT NULL DEFAULT 'aceita',
    "observacoes" TEXT,
    "ultimaLatitude" DOUBLE PRECISION,
    "ultimaLongitude" DOUBLE PRECISION,
    "atualizadoEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "inicioEm" TIMESTAMP(3) NOT NULL,
    "fimEm" TIMESTAMP(3) NOT NULL,
    "valorHora" DOUBLE PRECISION NOT NULL,
    "valorTotal" DOUBLE PRECISION NOT NULL,
    "avisoEnviadoEm" TIMESTAMP(3),
    "compartilhamentoAutorizado" BOOLEAN NOT NULL DEFAULT false,
    "selfieInicio" TEXT,
    "selfieInicioEm" TIMESTAMP(3),

    CONSTRAINT "solicitacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "avaliacoes" (
    "id" TEXT NOT NULL,
    "solicitacaoId" TEXT NOT NULL,
    "autor" "AutorAvaliacao" NOT NULL,
    "nota" INTEGER NOT NULL,
    "comentario" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "avaliacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pagamentos" (
    "id" TEXT NOT NULL,
    "solicitacaoId" TEXT NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "valorRepasse" DOUBLE PRECISION,
    "forma" "FormaPagamento",
    "status" "StatusPagamento" NOT NULL DEFAULT 'pendente',
    "pagoEm" TIMESTAMP(3),
    "liberadoEm" TIMESTAMP(3),
    "asaasCobrancaId" TEXT,
    "asaasUrlPagamento" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "pagamentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "resgates" (
    "id" TEXT NOT NULL,
    "cuidadorId" TEXT NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "chavePix" TEXT NOT NULL,
    "status" "StatusResgate" NOT NULL DEFAULT 'processando',
    "asaasTransferenciaId" TEXT,
    "motivoFalha" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "concluidoEm" TIMESTAMP(3),

    CONSTRAINT "resgates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_asaas_eventos" (
    "id" TEXT NOT NULL,
    "evento" TEXT NOT NULL,
    "recebidoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "webhook_asaas_eventos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "localizacao_pings" (
    "id" TEXT NOT NULL,
    "solicitacaoId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "localizacao_pings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "push_tokens" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "push_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cadastros_cuidador" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT,
    "nome" TEXT NOT NULL,
    "cpf" TEXT NOT NULL,
    "telefone" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "categoria" "CategoriaCuidador" NOT NULL,
    "corenNumero" TEXT,
    "chavePix" TEXT NOT NULL,
    "statusVerificacao" "StatusVerificacaoCadastro" NOT NULL DEFAULT 'em_analise',
    "motivos" TEXT[],
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "cadastros_cuidador_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cadastro_documentos" (
    "id" TEXT NOT NULL,
    "cadastroId" TEXT NOT NULL,
    "tipo" "TipoDocumentoCadastro" NOT NULL,
    "enviadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cadastro_documentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cadastro_quiz_respostas" (
    "id" TEXT NOT NULL,
    "cadastroId" TEXT NOT NULL,
    "questaoId" TEXT NOT NULL,
    "respostaId" TEXT NOT NULL,
    "correta" BOOLEAN NOT NULL,
    "critica" BOOLEAN NOT NULL,

    CONSTRAINT "cadastro_quiz_respostas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "membros" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "idade" INTEGER,
    "fotoUrl" TEXT,
    "endereco" TEXT,
    "alergias" TEXT[],
    "documentoStatus" "StatusDocumentoMembro" NOT NULL DEFAULT 'pendente',
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "membros_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "condicoes_medicas" (
    "id" TEXT NOT NULL,
    "membroId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,

    CONSTRAINT "condicoes_medicas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "medicamentos" (
    "id" TEXT NOT NULL,
    "membroId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "dosagem" TEXT NOT NULL,
    "horarios" TEXT[],
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "medicamentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contatos_emergencia" (
    "id" TEXT NOT NULL,
    "membroId" TEXT NOT NULL,
    "nome" TEXT NOT NULL,
    "relacao" TEXT NOT NULL,
    "telefone" TEXT NOT NULL,
    "principal" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "contatos_emergencia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios" (
    "id" TEXT NOT NULL,
    "tipo" "TipoUsuario" NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "senhaHash" TEXT NOT NULL,
    "telefone" TEXT NOT NULL,
    "cpf" TEXT,
    "asaasClienteId" TEXT,
    "fotoPerfil" TEXT,
    "fotoPerfilEm" TIMESTAMP(3),
    "termosVersao" TEXT,
    "termosAceitosEm" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ultimoLoginEm" TIMESTAMP(3),

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessoes_dispositivo" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revogadoEm" TIMESTAMP(3),

    CONSTRAINT "sessoes_dispositivo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cuidadores" (
    "id" TEXT NOT NULL,
    "usuarioId" TEXT NOT NULL,
    "categoria" "CategoriaCuidador" NOT NULL,
    "corenNumero" TEXT,
    "chavePix" TEXT,
    "statusVerificacao" "StatusVerificacaoCadastro" NOT NULL DEFAULT 'em_analise',
    "motivos" TEXT[],
    "senhaResgateHash" TEXT,
    "senhaResgateTentativas" INTEGER NOT NULL DEFAULT 0,
    "senhaResgateBloqueadaAte" TIMESTAMP(3),
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "cuidadores_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "profissionais_usuarioId_key" ON "profissionais"("usuarioId");

-- CreateIndex
CREATE INDEX "solicitacoes_cuidadorId_inicioEm_idx" ON "solicitacoes"("cuidadorId", "inicioEm");

-- CreateIndex
CREATE UNIQUE INDEX "avaliacoes_solicitacaoId_autor_key" ON "avaliacoes"("solicitacaoId", "autor");

-- CreateIndex
CREATE UNIQUE INDEX "pagamentos_solicitacaoId_key" ON "pagamentos"("solicitacaoId");

-- CreateIndex
CREATE UNIQUE INDEX "pagamentos_asaasCobrancaId_key" ON "pagamentos"("asaasCobrancaId");

-- CreateIndex
CREATE INDEX "pagamentos_status_idx" ON "pagamentos"("status");

-- CreateIndex
CREATE UNIQUE INDEX "resgates_asaasTransferenciaId_key" ON "resgates"("asaasTransferenciaId");

-- CreateIndex
CREATE INDEX "resgates_cuidadorId_criadoEm_idx" ON "resgates"("cuidadorId", "criadoEm");

-- CreateIndex
CREATE INDEX "localizacao_pings_solicitacaoId_criadoEm_idx" ON "localizacao_pings"("solicitacaoId", "criadoEm");

-- CreateIndex
CREATE UNIQUE INDEX "push_tokens_token_key" ON "push_tokens"("token");

-- CreateIndex
CREATE UNIQUE INDEX "cadastros_cuidador_usuarioId_key" ON "cadastros_cuidador"("usuarioId");

-- CreateIndex
CREATE UNIQUE INDEX "cadastros_cuidador_cpf_key" ON "cadastros_cuidador"("cpf");

-- CreateIndex
CREATE UNIQUE INDEX "membros_usuarioId_key" ON "membros"("usuarioId");

-- CreateIndex
CREATE INDEX "condicoes_medicas_membroId_idx" ON "condicoes_medicas"("membroId");

-- CreateIndex
CREATE INDEX "medicamentos_membroId_idx" ON "medicamentos"("membroId");

-- CreateIndex
CREATE INDEX "contatos_emergencia_membroId_idx" ON "contatos_emergencia"("membroId");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_cpf_key" ON "usuarios"("cpf");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_asaasClienteId_key" ON "usuarios"("asaasClienteId");

-- CreateIndex
CREATE UNIQUE INDEX "sessoes_dispositivo_tokenHash_key" ON "sessoes_dispositivo"("tokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "cuidadores_usuarioId_key" ON "cuidadores"("usuarioId");

-- AddForeignKey
ALTER TABLE "profissionais" ADD CONSTRAINT "profissionais_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "solicitacoes" ADD CONSTRAINT "solicitacoes_cuidadorId_fkey" FOREIGN KEY ("cuidadorId") REFERENCES "profissionais"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "solicitacoes" ADD CONSTRAINT "solicitacoes_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "avaliacoes" ADD CONSTRAINT "avaliacoes_solicitacaoId_fkey" FOREIGN KEY ("solicitacaoId") REFERENCES "solicitacoes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pagamentos" ADD CONSTRAINT "pagamentos_solicitacaoId_fkey" FOREIGN KEY ("solicitacaoId") REFERENCES "solicitacoes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "resgates" ADD CONSTRAINT "resgates_cuidadorId_fkey" FOREIGN KEY ("cuidadorId") REFERENCES "cuidadores"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "localizacao_pings" ADD CONSTRAINT "localizacao_pings_solicitacaoId_fkey" FOREIGN KEY ("solicitacaoId") REFERENCES "solicitacoes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cadastros_cuidador" ADD CONSTRAINT "cadastros_cuidador_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cadastro_documentos" ADD CONSTRAINT "cadastro_documentos_cadastroId_fkey" FOREIGN KEY ("cadastroId") REFERENCES "cadastros_cuidador"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cadastro_quiz_respostas" ADD CONSTRAINT "cadastro_quiz_respostas_cadastroId_fkey" FOREIGN KEY ("cadastroId") REFERENCES "cadastros_cuidador"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "membros" ADD CONSTRAINT "membros_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "condicoes_medicas" ADD CONSTRAINT "condicoes_medicas_membroId_fkey" FOREIGN KEY ("membroId") REFERENCES "membros"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "medicamentos" ADD CONSTRAINT "medicamentos_membroId_fkey" FOREIGN KEY ("membroId") REFERENCES "membros"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contatos_emergencia" ADD CONSTRAINT "contatos_emergencia_membroId_fkey" FOREIGN KEY ("membroId") REFERENCES "membros"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessoes_dispositivo" ADD CONSTRAINT "sessoes_dispositivo_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cuidadores" ADD CONSTRAINT "cuidadores_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios"("id") ON DELETE CASCADE ON UPDATE CASCADE;


-- Agenda sem sobreposição: o banco recusa duas reservas do mesmo profissional que se cruzem no
-- tempo. É o que impede dois membros diferentes de fecharem o mesmo horário ao mesmo tempo — a
-- checagem na tela do app sozinha não garante isso (dois aparelhos podem enviar juntos).
--
-- `[)` = início incluído, fim excluído: uma visita das 12h às 14h e outra das 14h às 17h NÃO se
-- sobrepõem. Só vale para os status que realmente seguram o horário — `pendente` fica de fora de
-- propósito (vários membros podem pedir o mesmo horário; só um vai ser aceito), assim como
-- `recusada` e `cancelada`, que liberam a vaga.
--
-- ⚠️ Esta parte NÃO é gerada pelo `prisma migrate diff` (o Prisma não representa EXCLUDE no
-- schema). Ao regenerar este arquivo, copiar este bloco de volta para o fim dele.
CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE "solicitacoes"
  ADD CONSTRAINT "solicitacoes_sem_sobreposicao"
  EXCLUDE USING gist (
    "cuidadorId" WITH =,
    tsrange("inicioEm", "fimEm", '[)') WITH &&
  )
  WHERE ("status" IN ('aceita', 'em_andamento', 'concluida'));


-- Row Level Security (RLS) ligado em TODAS as tabelas, sem nenhuma política, de propósito.
-- O Supabase publica uma API REST automática (PostgREST) sobre as tabelas do schema `public`,
-- acessível com a chave "anon". Sem RLS, qualquer um com essa chave leria/escreveria direto nas
-- tabelas. O back-end não é afetado: ele conecta como dono do banco (DATABASE_URL) e ignora RLS.
--
-- ⚠️ Esta parte também NÃO é gerada pelo `prisma migrate diff`. Toda tabela nova precisa entrar
-- aqui (e ganhar o mesmo ALTER na migration dela).
ALTER TABLE "profissionais" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "solicitacoes" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "pagamentos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "resgates" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "webhook_asaas_eventos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "localizacao_pings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "push_tokens" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "cadastros_cuidador" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "cadastro_documentos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "cadastro_quiz_respostas" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "membros" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "condicoes_medicas" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "medicamentos" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "contatos_emergencia" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "usuarios" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "sessoes_dispositivo" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "cuidadores" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "avaliacoes" ENABLE ROW LEVEL SECURITY;

-- Nota da avaliação de 1 a 5 também no banco (o Prisma não representa CHECK — ver a migration
-- 20260930210000_avaliacoes). Ao regenerar este arquivo, manter este bloco.
ALTER TABLE "avaliacoes" ADD CONSTRAINT "avaliacoes_nota_1_a_5" CHECK ("nota" BETWEEN 1 AND 5);
