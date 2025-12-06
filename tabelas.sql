DROP TABLE possui;
DROP TABLE utilizador;
DROP TABLE album;
DROP TABLE artista;

-- ----------------------------------------------------------------------------

CREATE TABLE artista (
  isni      CHAR (16),
  nome   VARCHAR (80)  CONSTRAINT nn_artista_nome   NOT NULL,
  inicio  NUMBER (4)   CONSTRAINT nn_artista_inicio NOT NULL,
                       -- Ano de início de atividade.
--
  CONSTRAINT pk_artista
    PRIMARY KEY (isni),
--
  CONSTRAINT ck_artista_isni  -- RIA 07.
    CHECK (REGEXP_LIKE(isni, '[0-9]{15}[0-9X]', 'i')),
--
  CONSTRAINT ck_artista_inicio  -- Impede erros básicos.
    CHECK (inicio > 0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE album (
  -- Adaptação dos conjuntos de entidades Álbum, Suporte Físico, e Versão, e
  -- dos conjuntos de associações Em e De. O MBID foi omitido por simplicidade.
  ean        CHAR (13),
  titulo  VARCHAR (80)  CONSTRAINT nn_album_titulo  NOT NULL,
  tipo    VARCHAR (6)   CONSTRAINT nn_album_tipo    NOT NULL,
  ano      NUMBER (4)   CONSTRAINT nn_album_ano     NOT NULL,
  artista               CONSTRAINT nn_album_artista NOT NULL,  -- Intérprete.
  suporte VARCHAR (7)   CONSTRAINT nn_album_suporte NOT NULL,
  versao  VARCHAR (80), -- Pode não estar preenchida.
--
  CONSTRAINT pk_album
    PRIMARY KEY (ean),
--
  CONSTRAINT fk_album_artista
    FOREIGN KEY (artista)
    REFERENCES artista (isni),
--
  CONSTRAINT ck_versao_ean  -- RIA 12.
    CHECK (REGEXP_LIKE(ean, '[0-9]{13}', 'i')),
--
  CONSTRAINT ck_album_tipo
    CHECK (tipo IN ('single', 'EP', 'LP')),  -- RIA 02.
--
  CONSTRAINT ck_album_ano  -- Impede erros básicos.
    CHECK (ano >= 1900),
--
  CONSTRAINT ck_album_suporte  -- RIA 11.
    CHECK (suporte IN ('CD', 'vinil', 'cassete'))
);

-- ----------------------------------------------------------------------------

CREATE TABLE utilizador (
  username   VARCHAR (40),
  email      VARCHAR (80) CONSTRAINT nn_utilizador_email NOT NULL,  -- RIA 13.
  senha      VARCHAR (40) CONSTRAINT nn_utilizador_senha NOT NULL,
  nascimento  NUMBER (4)  CONSTRAINT nn_utilizador_nascimento NOT NULL,
                          -- Só o ano da data de nascimento, por simplicidade.
  artista,                -- Favorito.
--
  CONSTRAINT pk_utilizador
    PRIMARY KEY (username),
--
  CONSTRAINT fk_utilizador_artista
    FOREIGN KEY (artista)
    REFERENCES artista (isni),
--
  CONSTRAINT un_utilizador_email  -- RIA 13.
    UNIQUE (email),
--
  CONSTRAINT ck_utilizador_username  -- RIA 14.
    CHECK (REGEXP_LIKE(username, '[a-z0-9]+', 'i')),
--
  CONSTRAINT ck_utilizador_nascimento  -- Impede erros básicos.
    CHECK (nascimento >= 1900)
);

-- ----------------------------------------------------------------------------

CREATE TABLE possui (
  utilizador,
  album,
  desde       DATE CONSTRAINT nn_possui_desde NOT NULL,  -- Data de registo.
--
  CONSTRAINT pk_possui
    PRIMARY KEY (utilizador, album),
--
  CONSTRAINT fk_possui_utilizador
    FOREIGN KEY (utilizador)
    REFERENCES utilizador (username),
--
  CONSTRAINT fk_possui_album
    FOREIGN KEY (album)
    REFERENCES album (ean),
--
  CONSTRAINT ck_possui_desde  -- Impede erros básicos.
    CHECK (desde >= TO_DATE('01.01.1900', 'DD.MM.YYYY'))
);

-- ----------------------------------------------------------------------------