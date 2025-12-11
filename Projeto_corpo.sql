CREATE OR REPLACE PACKAGE pkg_colecao IS
num_albuns NUMBER;

    --Defenição de funções e procedimentos:
    FUNCTION mensagem_erro (raw_error IN VARCHAR2, code_error IN NUMBER) RETURN VARCHAR2 IS
    nome_constraint  VARCHAR2(128); -- Ex: PK_CLIENTE_ID
    nome_coluna   VARCHAR2(128); -- Ex: CLIENTE_ID (sem o prefixo)
    mensagem        VARCHAR2(4000);
BEGIN
    -- Extrai o nome do constraint do erro original
    nome_constraint := extrair_identificador(raw_error);

    -- Se não encontrou nada entre parênteses, devolve o erro original
    IF nome_constraint IS NULL THEN
        RETURN 'Erro de Sistema (' || code_error || '): ' || raw_error;
    END IF;

    -- Remove o prefixo do nome do constraint
    nome_coluna := REGEXP_SUBSTR(nome_constraint, '_(.+)', 1, 1, NULL, 1);
    
    -- Para o caso dos erros -1400 e -1407, onde a formatação segue o padrão TABLE.COLUMN
    IF nome_coluna IS NULL THEN 
        nome_coluna := nome_constraint; 
    END IF;

    -- Os erros -1400 e -1407 têm uma formatação diferente dos restantes.
    IF code_error IN (-1400, -1407) THEN
        RETURN 'Campo obrigatório: O campo ' || nome_coluna || ' não pode ficar vazio.';
    END IF;

    -- Erros tratados com base no nome do constraint
    CASE 
        WHEN LOWER(nome_constraint) LIKE 'ck_%' THEN
            mensagem := 'Erro: O valor de ' || nome_coluna || ' não segue a restrição contratual';

        WHEN LOWER(nome_constraint) LIKE 'fk_%' THEN
            IF code_error = -2291 THEN
                mensagem := 'Erro: O ' || nome_coluna || ' indicado não existe na base de dados.';
            ELSE
                mensagem := 'Erro: O registo ' || nome_coluna || ' está a ser usado por uma ou mais tabelas e não pode ser apagado.';
            END IF;

        WHEN LOWER(nome_constraint) LIKE 'pk_%' THEN
            mensagem := 'Duplicação: O registo ' || nome_coluna || ' já existe e não pode ser duplicado.';

        WHEN LOWER(nome_constraint) LIKE 'un_%' OR LOWER(nome_constraint) LIKE 'uk_%' THEN
            mensagem := 'Duplicação: O valor de ' || nome_coluna || ' já existe no sistema.';

        ELSE
            mensagem := 'Erro desconhecido (' || nome_constraint || '). Código: ' || code_error;
    END CASE;

    RETURN mensagem;
END mensagem_erro;

    FUNCTION extrair_identificador (p_raw_error IN VARCHAR2) RETURN VARCHAR2 IS
    v_conteudo_full VARCHAR2(256);
BEGIN
    -- Extrai o conteúdo entre parênteses do erro.
    v_conteudo_full := REGEXP_SUBSTR(p_raw_error, '\(([^)]+)\)', 1, 1, NULL, 1);
    
    -- Remove aspas duplas, se existirem.
    v_conteudo_full := REPLACE(v_conteudo_full, '"', '');

    -- Separa o nome do constraint 
    IF INSTR(v_conteudo_full, '.') > 0 THEN
        RETURN SUBSTR(v_conteudo_full, INSTR(v_conteudo_full, '.', -1) + 1);
    ELSE
        RETURN v_conteudo_full;
    END IF;
END extrair_identificador;

    --Função que conta o número de álbuns possuídos por um utilizador
    FUNCTION conta_albuns (utilizador_in IN possui.utilizador%TYPE) RETURN NUMBER IS
    numero_albuns NUMBER;
    BEGIN
        SELECT COUNT(*) INTO numero_albuns FROM possui WHERE utilizador = utilizador_in;
        RETURN numero_albuns;
    END conta_albuns;


    PROCEDURE regista_artista(isni_in IN artista.isni%TYPE, nome_in IN artista.nome%TYPE, inicio_in IN artista.inicio%TYPE)
    IS
    BEGIN
        -- Validação do ano de início
        IF inicio_in > EXTRACT(YEAR FROM SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20000, 'Erro: Ano de início não pode ser no futuro.');
        END IF;

        INSERT INTO artista (isni, nome, inicio) VALUES (isni_in, nome_in, inicio_in);

    exception
        when dup_val_on_index then
        raise_application_error(-20001,'Erro: O código ISNI já existe na base de dados e não pode ser duplicado.');
        when others then
        if sqlcode = -20000 then
            raise;
        else
            raise_application_error(-20002, mensagem_erro(SQLERRM, SQLCODE));
        end if;
        
    END regista_artista;

    PROCEDURE regista_album(
        ean_in IN album.ean%TYPE, titulo_in IN album.titulo%TYPE, tipo_in IN album.tipo%TYPE, ano_in IN album.ano%TYPE, 
        artista_in IN album.artista%TYPE, suporte_in IN album.suporte%TYPE, versao_in IN album.versao%TYPE := NULL)
    IS
    BEGIN 
        -- Validação do ano do álbum
        IF ano_in < (SELECT a.inicio FROM artista a WHERE a.isni = artista_in) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Erro: Ano do álbum não pode ser anterior ao ano de início de atividade do artista.');
        ELSIF ano_in > EXTRACT(YEAR FROM SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20004, 'Erro: Ano do álbum não pode ser no futuro.');
        END IF;

        INSERT INTO album (ean, titulo, tipo, ano, artista, suporte, versao)
        VALUES (ean_in, titulo_in, tipo_in, ano_in, artista_in, suporte_in, versao_in);
        
    exception
        when no_data_found then
            raise_application_error(-20005,'Erro: O artista especificado não existe na base de dados.');
        when dup_val_on_index then
            raise_application_error(-20006,'Erro: O código EAN já existe na base de dados e não pode ser duplicado.');
        when others then
            if sqlcode = -20003 OR sqlcode = -20004 then
                raise;
            else
                raise_application_error(-20006, mensagem_erro(SQLERRM, SQLCODE));
            end if;
    END regista_album;


    PROCEDURE regista_utilizador(username_in IN utilizador.username%TYPE, email_in IN utilizador.email%TYPE, 
    senha_in IN utilizador.senha%TYPE, nascimento_in IN utilizador.nascimento%TYPE, 
    artista_in IN utilizador.artista%TYPE := NULL)
    IS
    BEGIN
        -- Validação da idade mínima
        if (extract(year from SYSDATE) - nascimento_in) < 13 then
            RAISE_APPLICATION_ERROR(-20006, 'Erro: O utilizador tem de ter pelo menos 13 anos.');
        end if;
        INSERT INTO utilizador(username, email, senha, nascimento, artista)
        VALUES (username_in, email_in, senha_in, nascimento_in, artista_in);

        exception
          when dup_val_on_index then
            raise_application_error(-20007, mensagem_erro(SQLERRM, SQLCODE));
          when others then
            if sqlcode = -20006 then
                raise;
            else
                raise_application_error(-20008, mensagem_erro(SQLERRM, SQLCODE));
            end if;
    END regista_utilizador;

    FUNCTION regista_posse (utilizador_in IN possui.utilizador%TYPE, album_in IN possui.album%TYPE, 
    desde_in IN possui.desde%TYPE := SYSDATE) RETURN NUMBER IS
    BEGIN
        IF Extract(year from desde_in) < (SELECT a.ano FROM album a WHERE a.ean = album_in) then --Ria 16
            RAISE_APPLICATION_ERROR(-20009, 'Erro: A data de posse não pode ser anterior ao ano de lançamento do álbum.');
        ELSIF desde_in > SYSDATE then 
            RAISE_APPLICATION_ERROR(-20010, 'Erro: A data de posse não pode ser no futuro.');
        ELSIF EXTRACT(year FROM desde_in) < ((SELECT u.nascimento FROM utilizador u WHERE u.username = utilizador_in) + 13) then --Ria 17
            RAISE_APPLICATION_ERROR(-20013, 'Erro: A data de posse não pode ser anterior à data em que o utilizador tem 13 anos.');
        END IF;
        INSERT INTO possui(utilizador, album, desde)
        VALUES (utilizador_in, album_in, desde_in);
        RETURN conta_albuns(utilizador_in);
        exception
            when no_data_found then
                raise_application_error(-20011,'Erro: O utilizador ou álbum especificado não existe na base de dados.');
            when dup_val_on_index then
                raise_application_error(-20011, 'Erro: A posse já existe na base de dados e não pode ser duplicada.');
            when others then
                if sqlcode = -20009 OR sqlcode = -20010 then
                    raise;
                else
                    raise_application_error(-20012, mensagem_erro(SQLERRM, SQLCODE));
                end if;
    END regista_posse;



END pkg_colecao;
/
