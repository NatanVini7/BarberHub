-- =================================================================================================
-- SCRIPT DE CRIAÇÃO DO BANCO DE DADOS COMPLETO - GESTÃO DE BELEZA
-- Versão Final, Corrigida e Otimizada
-- =================================================================================================

-- Inicia a configuração do ambiente SQL para garantir a compatibilidade e a integridade.
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Criação do Schema (Banco de Dados)
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `gestao_beleza_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `gestao_beleza_db` ;

-- -----------------------------------------------------
-- Tabela 1: estabelecimentos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`estabelecimentos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome_fantasia` VARCHAR(255) NOT NULL,
  `razao_social` VARCHAR(255) NULL,
  `documento` VARCHAR(20) NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `documento_UNIQUE` (`documento` ASC) VISIBLE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 2: pessoas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`pessoas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome_completo` VARCHAR(255) NOT NULL,
  `documento` VARCHAR(20) NULL,
  `tipo_documento` ENUM('CPF', 'CNPJ') NULL,
  `data_nascimento` DATE NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `documento_UNIQUE` (`documento` ASC) VISIBLE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 3: usuarios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`usuarios` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_pessoa` INT NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(255) NOT NULL COMMENT 'IMPORTANTE: Armazenar um HASH da senha (ex: bcrypt), nunca a senha em texto puro.',
  `ultimo_login_em` TIMESTAMP NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  INDEX `fk_usuario_pessoa_idx` (`id_pessoa` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_pessoa`
    FOREIGN KEY (`id_pessoa`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 4: vinculos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`vinculos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_pessoa` INT NOT NULL,
  `id_estabelecimento` INT NOT NULL,
  `perfil` ENUM('admin', 'profissional', 'cliente') NOT NULL,
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_vinculo_pessoa_idx` (`id_pessoa` ASC) VISIBLE,
  INDEX `fk_vinculo_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  UNIQUE INDEX `uk_pessoa_estabelecimento_perfil` (`id_pessoa` ASC, `id_estabelecimento` ASC, `perfil` ASC) VISIBLE,
  CONSTRAINT `fk_vinculo_pessoa`
    FOREIGN KEY (`id_pessoa`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_vinculo_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 5: enderecos (Polimórfica - CORRIGIDA)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`enderecos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `entidade_id` INT NOT NULL COMMENT 'ID do "dono" do endereço (pessoa ou estabelecimento).',
  `entidade_tipo` VARCHAR(50) NOT NULL COMMENT 'Nome da tabela do "dono" (ex: "pessoas", "estabelecimentos").',
  `cep` VARCHAR(9) NULL,
  `rua` VARCHAR(255) NOT NULL,
  `numero` VARCHAR(20) NULL,
  `complemento` VARCHAR(100) NULL,
  `bairro` VARCHAR(100) NULL,
  `cidade` VARCHAR(100) NOT NULL,
  `estado` VARCHAR(50) NOT NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_entidade_endereco` (`entidade_id` ASC, `entidade_tipo` ASC) VISIBLE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 6: contatos (Polimórfica e Flexível - CORRIGIDA)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`contatos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `entidade_id` INT NOT NULL COMMENT 'ID do "dono" do contato.',
  `entidade_tipo` VARCHAR(50) NOT NULL COMMENT 'Nome da tabela do "dono".',
  `tipo` ENUM('email', 'telefone', 'whatsapp', 'instagram', 'tiktok', 'facebook') NOT NULL,
  `valor` VARCHAR(255) NOT NULL,
  `eh_principal` BOOLEAN NOT NULL DEFAULT FALSE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_entidade_contato` (`entidade_id` ASC, `entidade_tipo` ASC) VISIBLE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 7: horarios_funcionamento
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`horarios_funcionamento` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `dia_semana` ENUM('DOMINGO', 'SEGUNDA', 'TERCA', 'QUARTA', 'QUINTA', 'SEXTA', 'SABADO') NOT NULL,
  `horario_abertura` TIME NULL,
  `horario_fechamento` TIME NULL,
  `horario_inicio_pausa` TIME NULL,
  `horario_fim_pausa` TIME NULL,
  `esta_aberto` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_horarios_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  UNIQUE INDEX `uk_estabelecimento_dia_semana` (`id_estabelecimento` ASC, `dia_semana` ASC) VISIBLE,
  CONSTRAINT `fk_horarios_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 8: horarios_excecao
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`horarios_excecao` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `data_excecao` DATE NOT NULL,
  `descricao` VARCHAR(255) NULL,
  `esta_aberto` BOOLEAN NOT NULL,
  `horario_abertura` TIME NULL,
  `horario_fechamento` TIME NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_excecao_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  UNIQUE INDEX `uk_excecao_estabelecimento_data` (`id_estabelecimento` ASC, `data_excecao` ASC) VISIBLE,
  CONSTRAINT `fk_excecao_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 9: registros_jornada_diaria
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`registros_jornada_diaria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `data_jornada` DATE NOT NULL,
  `hora_abertura_real` TIME NULL,
  `hora_fechamento_real` TIME NULL,
  `status_dia` ENUM('PLANEJADO', 'EM_ANDAMENTO', 'CONCLUIDO', 'CANCELADO') NOT NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_jornada_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  UNIQUE INDEX `uk_estabelecimento_data` (`id_estabelecimento` ASC, `data_jornada` ASC) VISIBLE,
  CONSTRAINT `fk_jornada_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 10: categorias_servicos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`categorias_servicos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `nome` VARCHAR(100) NOT NULL,
  `ordem_exibicao` INT NOT NULL DEFAULT 0,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_categoria_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  CONSTRAINT `fk_categoria_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 11: servicos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`servicos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `id_categoria` INT NULL,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT NULL,
  `preco` DECIMAL(10, 2) NOT NULL,
  `duracao_minutos` INT NOT NULL,
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_servico_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  INDEX `fk_servico_categoria_idx` (`id_categoria` ASC) VISIBLE,
  CONSTRAINT `fk_servico_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_servico_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `gestao_beleza_db`.`categorias_servicos` (`id`)
    ON DELETE SET NULL
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 12: profissionais_servicos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`profissionais_servicos` (
  `id_pessoa_profissional` INT NOT NULL,
  `id_servico` INT NOT NULL,
  PRIMARY KEY (`id_pessoa_profissional`, `id_servico`),
  INDEX `fk_ps_servico_idx` (`id_servico` ASC) VISIBLE,
  INDEX `fk_ps_pessoa_idx` (`id_pessoa_profissional` ASC) VISIBLE,
  CONSTRAINT `fk_ps_pessoa`
    FOREIGN KEY (`id_pessoa_profissional`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_ps_servico`
    FOREIGN KEY (`id_servico`)
    REFERENCES `gestao_beleza_db`.`servicos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 13: comandas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`comandas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `id_pessoa_cliente` INT NOT NULL,
  `valor_total` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `valor_desconto` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `valor_final` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  `status` ENUM('ABERTA', 'FECHADA', 'PAGA', 'CANCELADA') NOT NULL DEFAULT 'ABERTA',
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_comanda_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  INDEX `fk_comanda_cliente_idx` (`id_pessoa_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_comanda_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_comanda_cliente`
    FOREIGN KEY (`id_pessoa_cliente`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE RESTRICT
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 14: agendamentos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`agendamentos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `id_pessoa_cliente` INT NOT NULL,
  `id_pessoa_profissional` INT NOT NULL,
  `id_servico` INT NOT NULL,
  `id_comanda` INT NULL DEFAULT NULL,
  `data_hora_inicio` DATETIME NOT NULL,
  `data_hora_fim` DATETIME NOT NULL,
  `status` ENUM('AGENDADO', 'CONFIRMADO', 'CONCLUIDO', 'CANCELADO_CLIENTE', 'CANCELADO_SALAO', 'NAO_COMPARECEU') NOT NULL DEFAULT 'AGENDADO',
  `observacoes_cliente` TEXT NULL,
  `observacoes_internas` TEXT NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_agendamento_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  INDEX `fk_agendamento_cliente_idx` (`id_pessoa_cliente` ASC) VISIBLE,
  INDEX `fk_agendamento_profissional_idx` (`id_pessoa_profissional` ASC) VISIBLE,
  INDEX `fk_agendamento_servico_idx` (`id_servico` ASC) VISIBLE,
  INDEX `fk_agendamento_comanda_idx` (`id_comanda` ASC) VISIBLE,
  CONSTRAINT `fk_agendamento_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_agendamento_cliente`
    FOREIGN KEY (`id_pessoa_cliente`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_agendamento_profissional`
    FOREIGN KEY (`id_pessoa_profissional`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_agendamento_servico`
    FOREIGN KEY (`id_servico`)
    REFERENCES `gestao_beleza_db`.`servicos` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_agendamento_comanda`
    FOREIGN KEY (`id_comanda`)
    REFERENCES `gestao_beleza_db`.`comandas` (`id`)
    ON DELETE SET NULL
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 15: pagamentos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`pagamentos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_comanda` INT NOT NULL,
  `valor_pago` DECIMAL(10, 2) NOT NULL,
  `metodo_pagamento` ENUM('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX') NOT NULL,
  `status` ENUM('PENDENTE', 'PAGO_EM_CUSTODIA', 'LIBERADO_PARA_SALAO', 'REEMBOLSADO', 'EM_DISPUTA') NOT NULL DEFAULT 'PENDENTE',
  `data_pagamento` DATETIME NULL,
  `data_liberacao` DATETIME NULL,
  `id_transacao_gateway` VARCHAR(255) NULL,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_pagamento_comanda_idx` (`id_comanda` ASC) VISIBLE,
  CONSTRAINT `fk_pagamento_comanda`
    FOREIGN KEY (`id_comanda`)
    REFERENCES `gestao_beleza_db`.`comandas` (`id`)
    ON DELETE RESTRICT
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 16: avaliacoes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`avaliacoes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_agendamento` INT NOT NULL,
  `id_pessoa_cliente` INT NOT NULL,
  `nota_profissional` TINYINT UNSIGNED NULL,
  `nota_estabelecimento` TINYINT UNSIGNED NULL,
  `comentario` TEXT NULL,
  `resposta_estabelecimento` TEXT NULL,
  `esta_visivel` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_agendamento_id` (`id_agendamento` ASC) VISIBLE,
  INDEX `fk_avaliacao_cliente_idx` (`id_pessoa_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_avaliacao_agendamento`
    FOREIGN KEY (`id_agendamento`)
    REFERENCES `gestao_beleza_db`.`agendamentos` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_avaliacao_cliente`
    FOREIGN KEY (`id_pessoa_cliente`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 17: produtos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`produtos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT NULL,
  `codigo_barras` VARCHAR(100) NULL UNIQUE,
  `preco_venda` DECIMAL(10, 2) NOT NULL,
  `preco_custo` DECIMAL(10, 2) NULL,
  `quantidade_estoque` INT NOT NULL DEFAULT 0,
  `estoque_minimo` INT NOT NULL DEFAULT 0,
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_produto_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  CONSTRAINT `fk_produto_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 18: comanda_itens
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`comanda_itens` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_comanda` INT NOT NULL,
  `id_servico` INT NULL,
  `id_produto` INT NULL,
  `id_pessoa_profissional` INT NULL,
  `preco_unitario` DECIMAL(10, 2) NOT NULL,
  `quantidade` INT NOT NULL DEFAULT 1,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_item_comanda_idx` (`id_comanda` ASC) VISIBLE,
  INDEX `fk_item_servico_idx` (`id_servico` ASC) VISIBLE,
  INDEX `fk_item_produto_idx` (`id_produto` ASC) VISIBLE,
  INDEX `fk_item_profissional_idx` (`id_pessoa_profissional` ASC) VISIBLE,
  CONSTRAINT `fk_item_comanda`
    FOREIGN KEY (`id_comanda`)
    REFERENCES `gestao_beleza_db`.`comandas` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_item_servico`
    FOREIGN KEY (`id_servico`)
    REFERENCES `gestao_beleza_db`.`servicos` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_item_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `gestao_beleza_db`.`produtos` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_item_profissional`
    FOREIGN KEY (`id_pessoa_profissional`)
    REFERENCES `gestao_beleza_db`.`pessoas` (`id`)
    ON DELETE RESTRICT
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 19: recursos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`recursos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `nome` VARCHAR(100) NOT NULL COMMENT 'Ex: "Sala de Massagem 1", "Aparelho de Laser X".',
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_recurso_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  CONSTRAINT `fk_recurso_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 20: agendamentos_recursos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`agendamentos_recursos` (
  `id_agendamento` INT NOT NULL,
  `id_recurso` INT NOT NULL,
  PRIMARY KEY (`id_agendamento`, `id_recurso`),
  INDEX `fk_ag_re_recurso_idx` (`id_recurso` ASC) VISIBLE,
  CONSTRAINT `fk_ag_re_agendamento`
    FOREIGN KEY (`id_agendamento`)
    REFERENCES `agendamentos` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_ag_re_recurso`
    FOREIGN KEY (`id_recurso`)
    REFERENCES `recursos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 21: pacotes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`pacotes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `nome` VARCHAR(255) NOT NULL COMMENT 'Ex: "Pacote 5 Sessões de Drenagem Linfática".',
  `preco` DECIMAL(10, 2) NOT NULL,
  `quantidade_sessoes` INT NOT NULL,
  `validade_dias` INT NOT NULL COMMENT 'Número de dias que o cliente tem para usar o pacote após a compra.',
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_pacote_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  CONSTRAINT `fk_pacote_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 22: pacotes_clientes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`pacotes_clientes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_pacote` INT NOT NULL,
  `id_pessoa_cliente` INT NOT NULL,
  `id_comanda_compra` INT NOT NULL COMMENT 'ID da comanda onde a compra do pacote foi registrada.',
  `sessoes_total` INT NOT NULL,
  `sessoes_utilizadas` INT NOT NULL DEFAULT 0,
  `data_compra` DATE NOT NULL,
  `data_validade` DATE NOT NULL,
  `status` ENUM('ATIVO', 'CONCLUIDO', 'EXPIRADO') NOT NULL DEFAULT 'ATIVO',
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_pc_pacote_idx` (`id_pacote` ASC) VISIBLE,
  INDEX `fk_pc_cliente_idx` (`id_pessoa_cliente` ASC) VISIBLE,
  INDEX `fk_pc_comanda_idx` (`id_comanda_compra` ASC) VISIBLE,
  CONSTRAINT `fk_pc_pacote`
    FOREIGN KEY (`id_pacote`)
    REFERENCES `pacotes` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_pc_cliente`
    FOREIGN KEY (`id_pessoa_cliente`)
    REFERENCES `pessoas` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_pc_comanda`
    FOREIGN KEY (`id_comanda_compra`)
    REFERENCES `comandas` (`id`)
    ON DELETE RESTRICT
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 23: despesas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`despesas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_estabelecimento` INT NOT NULL,
  `descricao` VARCHAR(255) NOT NULL,
  `valor` DECIMAL(10, 2) NOT NULL,
  `data_vencimento` DATE NOT NULL,
  `data_pagamento` DATE NULL,
  `status` ENUM('PENDENTE', 'PAGA', 'ATRASADA') NOT NULL DEFAULT 'PENDENTE',
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_despesa_estabelecimento_idx` (`id_estabelecimento` ASC) VISIBLE,
  CONSTRAINT `fk_despesa_estabelecimento`
    FOREIGN KEY (`id_estabelecimento`)
    REFERENCES `gestao_beleza_db`.`estabelecimentos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela 24: fichas_anamnese
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`fichas_anamnese` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_pessoa_cliente` INT NOT NULL,
  `id_pessoa_profissional` INT NOT NULL,
  `titulo` VARCHAR(255) NOT NULL COMMENT 'Ex: "Anamnese Corporal - 1ª Avaliação".',
  `observacoes_gerais` TEXT NULL,
  `data_preenchimento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `criado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_fa_cliente_idx` (`id_pessoa_cliente` ASC) VISIBLE,
  INDEX `fk_fa_profissional_idx` (`id_pessoa_profissional` ASC) VISIBLE,
  CONSTRAINT `fk_fa_cliente`
    FOREIGN KEY (`id_pessoa_cliente`)
    REFERENCES `pessoas` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_fa_profissional`
    FOREIGN KEY (`id_pessoa_profissional`)
    REFERENCES `pessoas` (`id`)
    ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `gestao_beleza_db`.`servico_variacoes` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_servico` INT NOT NULL COMMENT 'Chave estrangeira para a tabela "servicos" (o serviço pai).',
  `nome_variacao` VARCHAR(100) NOT NULL COMMENT 'Ex: "Cabelo Curto", "Cabelo Médio", "Cabelo Longo e Volumoso".',
  `descricao` TEXT NULL,
  `preco` DECIMAL(10, 2) NOT NULL,
  `duracao_minutos` INT NOT NULL,
  `ordem_exibicao` INT NOT NULL DEFAULT 0,
  `esta_ativo` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`id`),
  INDEX `fk_variacao_servico_idx` (`id_servico` ASC) VISIBLE,
  CONSTRAINT `fk_variacao_servico`
    FOREIGN KEY (`id_servico`)
    REFERENCES `gestao_beleza_db`.`servicos` (`id`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- Torna as colunas opcionais na tabela de serviços
ALTER TABLE `gestao_beleza_db`.`servicos` 
MODIFY COLUMN `preco` DECIMAL(10, 2) NULL,
MODIFY COLUMN `duracao_minutos` INT NULL;

-- Adiciona a chave estrangeira para a variação na tabela de agendamentos
ALTER TABLE `gestao_beleza_db`.`agendamentos` 
ADD COLUMN `id_servico_variacao` INT NULL AFTER `id_servico`,
ADD INDEX `fk_agendamento_variacao_idx` (`id_servico_variacao` ASC) VISIBLE;

ALTER TABLE `gestao_beleza_db`.`agendamentos`
ADD CONSTRAINT `fk_agendamento_variacao`
  FOREIGN KEY (`id_servico_variacao`)
  REFERENCES `gestao_beleza_db`.`servico_variacoes` (`id`)
  ON DELETE RESTRICT;

-- Finaliza o script restaurando as configurações originais do ambiente.
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
