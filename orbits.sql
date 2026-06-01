CREATE TABLE TB_USUARIO (
    usuario_id    INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome_usuario  VARCHAR(150) NOT NULL,
    email_usuario VARCHAR(150) NOT NULL,
    logradouro    VARCHAR(100) NOT NULL,
    telefone      VARCHAR(20)  NOT NULL,
    senha         VARCHAR(150) NOT NULL,
    data_cadastro DATE         NOT NULL,
    CONSTRAINT TB_USUARIO_PK PRIMARY  KEY (usuario_id),
    CONSTRAINT TB_USUARIO_EMAIL_UK    UNIQUE (email_usuario),
    CONSTRAINT TB_USUARIO_TELEFONE_UK UNIQUE (telefone)
);

DROP TABLE TB_USUARIO

CREATE TABLE TB_OBJETO (
    objeto_id        INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome_objeto      VARCHAR(50)   NOT NULL,
    categoria_objeto VARCHAR(50)   NOT NULL,
    status_objeto    VARCHAR(50)   NOT NULL,
    tamanho          DECIMAL(10,2) NOT NULL,
    velocidade       DECIMAL(8,4)  NOT NULL,
    altitude_orbital DECIMAL(10,2) NOT NULL,
    risco_colisao    VARCHAR(30),
    data_registro    DATE          NOT NULL,
    CONSTRAINT TB_OBJETO_PK PRIMARY KEY (objeto_id),
    CONSTRAINT TB_OBJETO_CATEGORIA_CHECK
        CHECK(categoria_objeto in (
            'fragmento orbital', 
            'foguete', 'lixo_espacial', 
            'meteorito', 
            'meteoro', 
            'satelite_artificial')),
    CONSTRAINT TB_OBJETO_STATUS_CHECK
        CHECK(status_objeto in ('Interceptado', 'Rastreado')),
    CONSTRAINT TB_OBJETO_RISCO_CHECK
        CHECK(risco_colisao in ('alta', 'media', 'baixa', 'nula')),
    CONSTRAINT TB_OBJETO_NOME_UK UNIQUE (nome_objeto)
);

DROP TABLE TB_OBJETO

CREATE TABLE TB_RELATORIO (
    id_relatorio        INTEGER      GENERATED ALWAYS AS IDENTITY,
    titulo_relatorio    VARCHAR(100) NOT NULL,
    descricao_relatorio VARCHAR(200) NOT NULL,
    data_emissao        Date         NOT NULL,
    tipo_relatorio      VARCHAR(100) NOT NULL,
    usuario_id          INTEGER      NOT NULL,
    objeto_id           INTEGER      NOT NULL,
    CONSTRAINT TB_RELATORIO_PK PRIMARY KEY (id_relatorio),
    CONSTRAINT TB_RELATORIO_USUARIO_FK
        FOREIGN KEY (usuario_id)
        REFERENCES TB_USUARIO (usuario_id),
    CONSTRAINT TB_RELATORIO_OBJETO_FK
        FOREIGN KEY (objeto_id)
        REFERENCES TB_OBJETO (objeto_id),
    CONSTRAINT TB_RELATORIO_CHECK
        CHECK (tipo_relatorio IN (
            'operacional',
            'poluicao_espacial',
            'risco_colisao',
            'status_orbital',
            'manutencao',
            'incidente',
            'desempenho',
            'conformidade',
            'geral'
        ))
);

DROP TABLE TB_RELATORIO

CREATE TABLE TB_INICIATIVA_ESPACIAL (
    iniciativa_id     INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome_iniciativa   VARCHAR(150) NOT NULL,
    descricao         VARCHAR(150) NOT NULL,
    area_atuacao      VARCHAR(50)  NOT NULL,
    data_inicio       DATE         NOT NULL,
    status_iniciativa VARCHAR(40)  NOT NULL,
    CONSTRAINT TB_INICIATIVA_ESPACIAL PRIMARY KEY (iniciativa_id),
    CONSTRAINT TB_INICIATIVA_CHECK
        CHECK(status_iniciativa IN ('Ativa', 'inativa', 'em_analise')),
    CONSTRAINT TB_INICIATIVA_NOME_UK UNIQUE (nome_iniciativa)
);

DROP TABLE TB_INICIATIVA_ESPACIAL

CREATE TABLE TB_EMPRESA (
    empresa_id     INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome_empresa   VARCHAR(150) NOT NULL,
    pais_origem    VARCHAR(50)  NOT NULL,
    status_empresa VARCHAR(30)  NOT NULL,
    email_empresa  VARCHAR(150) NOT NULL,
    telefone       VARCHAR(20)  NOT NULL,
    tipo_empresa   VARCHAR(50)  NOT NULL,
    data_fundacao  DATE         NOT NULL,
    descricao      VARCHAR(500) NOT NULL,
    site_oficial   VARCHAR(350) NOT NULL,
    cnpj           VARCHAR(18)  NOT NULL,
    score          INTEGER      NOT NULL,
    CONSTRAINT TB_EMPRESA_PK PRIMARY KEY (empresa_id),
    CONSTRAINT TB_EMPRESA_STATUS_CK
        CHECK (status_empresa IN (
            'confiavel', 
            'em_analise', 
            'nao_confiavel', 
            'suspeita')),
    CONSTRAINT TB_EMPRESA_SCORE_CK
        CHECK ( (score) >= 0),
    CONSTRAINT TB_EMPRESA_CNPJ_UK  UNIQUE (cnpj),
    CONSTRAINT TB_EMPRESA_EMAIL_UK UNIQUE (email_empresa),
    CONSTRAINT TB_EMPRESA_SITE_UK  UNIQUE (site_oficial)
);

CREATE TABLE TB_EMPRESA_INICIATIVA (
    empresa_id    INTEGER      NOT NULL,
    iniciativa_id INTEGER      NOT NULL,
    papel_empresa VARCHAR(100) NOT NULL,
    CONSTRAINT TB_EMPRESA_INICIATIVA_PK PRIMARY KEY (empresa_id, iniciativa_id),
    CONSTRAINT TB_EMPRESA_FK
        FOREIGN KEY (empresa_id)
        REFERENCES TB_EMPRESA (empresa_id),
    CONSTRAINT TB_EMPRESA_INICIATIVA_FK
        FOREIGN KEY (iniciativa_id)
        REFERENCES TB_INICIATIVA_ESPACIAL (iniciativa_id)
);

CREATE TABLE TB_SATELITE (
    satelite_id           INTEGER       GENERATED ALWAYS AS IDENTITY,
    finalidade            VARCHAR(100)  NOT NULL,
    nome_satelite         VARCHAR(100)  NOT NULL,
    trajeto               VARCHAR(200)  NOT NULL,
    altitude_km_orbital   DECIMAL(10,2) NOT NULL,
    velocidade_km_orbital DECIMAL(8,4)  NOT NULL,
    data_lancamento       DATE          NOT NULL,
    tempo_de_vida         DATE          NOT NULL,
    tipo_orbita           VARCHAR(30)   NOT NULL,
    status_operacao       VARCHAR(30)   NOT NULL,
    empresa_id            INTEGER       NOT NULL,
    CONSTRAINT TB_SATELITE PRIMARY KEY (satelite_id),
    CONSTRAINT TB_SATELITE_EMPRESA_FK
        FOREIGN KEY (empresa_id)
        REFERENCES TB_EMPRESA (empresa_id),
    CONSTRAINT TB_SATELITE_TIPO_ORBITA_CK
        CHECK(tipo_orbita IN ('alta', 'media', 'baixa', 'geoestacionaria')),
    CONSTRAINT TB_SATELITE_STATUS_CK
        CHECK(status_operacao IN ('ativo', 'inativo')),
    CONSTRAINT TB_SATELITE_NOME_UK UNIQUE (nome_satelite)
);

DROP TABLE TB_SATELITE

CREATE TABLE TB_SCORE (
    score_id    INTEGER      GENERATED ALWAYS AS IDENTITY,
    penalidade  VARCHAR(100) NOT NULL,
    bonificacao VARCHAR(100) NOT NULL,
    empresa_id  INTEGER      NOT NULL,
    satelite_id INTEGER      NOT NULL,
    CONSTRAINT TB_SCORE_PK PRIMARY KEY (score_id),
    CONSTRAINT TB_SCORE_EMPRESA_FK
        FOREIGN KEY (empresa_id)
        REFERENCES TB_EMPRESA (empresa_id),
    CONSTRAINT TB_SOCRE_SATELITE
        FOREIGN KEY (satelite_id)
        REFERENCES TB_SATELITE (satelite_id),
    CONSTRAINT TB_SCORE_BONIFICACAO_CK
        CHECK (bonificacao IN (
                'Desorbitacao responsavel',
                'Baixo risco de colisao',
                'Satelite ativo e regularizado',
                'Plano de mitigacao aprovado',
                'Baixa geracao de lixo espacial',
                'Registro orbital regular',
                'Transparencia de dados',
                'Participacao em iniciativa sustentavel',
                'Conformidade regulatoria')),
    CONSTRAINT TB_SCORE_PENALIDADE_CK
        CHECK (penalidade IN (
                'Alto risco de colisao',
                'Geracao de lixo espacial',
                'Satelite sem plano de desorbitacao',
                'Registro orbital irregular',
                'Falta de transparencia',
                'Geracao de fragmentos orbitais',
                'Descumprimento regulatorio',
                'Uso suspeito da infraestrutura espacial',
                'Satelite inativo em orbita'))
);

DROP TABLE TB_SCORE;
DROP TABLE TB_RELATORIO;
DROP TABLE TB_EMPRESA_INICIATIVA;
DROP TABLE TB_SATELITE;
DROP TABLE TB_INICIATIVA_ESPACIAL;
DROP TABLE TB_EMPRESA;
DROP TABLE TB_OBJETO;
DROP TABLE TB_USUARIO;