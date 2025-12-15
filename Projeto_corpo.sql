CREATE OR REPLACE PACKAGE BODY pkg_colecao IS
num_albuns NUMBER;

   FUNCTION mensagem_erro(mensagem_in IN VARCHAR2, codigo_in IN NUMBER) RETURN VARCHAR2 IS
    v_nome_const VARCHAR2(100);
    v_nome_coluna VARCHAR2(100);
   BEGIN

    v_nome_const := REGEXP_SUBSTR(mensagem_in, '\(([^)]+)\)', 1, 1, NULL, 1);
    IF codigo_in IN (-1400, -1407) THEN
    -- Trata erros de NOT NULL separadamente, pois não têm o formato padrão ('Schema.Tabela.Coluna')
        v_nome_coluna := SUBSTR(v_nome_const, INSTR(v_nome_const, '.', -1) + 1);
        v_nome_coluna := REPLACE(v_nome_coluna, '"', '');
    ELSE
    -- Remove o schema se vier junto (ex: HR.fk_album_ean -> fk_album_ean)
        IF INSTR(v_nome_const, '.') > 0 THEN
        v_nome_const := SUBSTR(v_nome_const, INSTR(v_nome_const, '.') + 1);
        END IF;

    -- Extrai o nome da coluna apartir do constraint (ex: fk_album_ean -> ean)
        v_nome_coluna := SUBSTR(v_nome_const, INSTR(v_nome_const, '_', 1, 2) + 1);
    END IF;

    CASE codigo_in
        WHEN -1 THEN
            RETURN 'Erro: ' || v_nome_coluna || ' já existe na base de dados e não pode ser duplicado.';
        WHEN -2290 THEN
            RETURN 'Erro: ' || v_nome_coluna || ' não cumpre a restrição contratual';
        WHEN -2291 THEN
            RETURN 'Erro: O valor de ' || v_nome_coluna || ' não existe na base de dados.';
        WHEN -2292 THEN
            RETURN 'Erro: O valor de ' || v_nome_coluna || ' está a ser referenciado por uma ou mais tabelas e não pode ser removido.';
        WHEN -1400 THEN
            RETURN 'Erro: ' || v_nome_coluna || ' não pode ser nulo.';
        ELSE
            RETURN 'Erro desconhecido: ' || mensagem_in || ' (Código: ' || codigo_in || ')';
    END CASE;
    END mensagem_erro;


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
    ano_artista NUMBER;
    BEGIN 
        SELECT a.inicio 
        INTO ano_artista 
        FROM artista a 
        WHERE a.isni = artista_in;

        -- Validação do ano do álbum
        IF ano_in < ano_artista THEN
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
            RAISE_APPLICATION_ERROR(-20007, 'Erro: O utilizador tem de ter pelo menos 13 anos.');
        end if;
        INSERT INTO utilizador(username, email, senha, nascimento, artista)
        VALUES (username_in, email_in, senha_in, nascimento_in, artista_in);

        exception
          when dup_val_on_index then
            raise_application_error(-20008, mensagem_erro(SQLERRM, SQLCODE));
          when others then
            if sqlcode = -20007 then
                raise;
            else
                raise_application_error(-20009, mensagem_erro(SQLERRM, SQLCODE));
            end if;
    END regista_utilizador;



    FUNCTION regista_posse (utilizador_in IN possui.utilizador%TYPE, album_in IN possui.album%TYPE, 
    desde_in IN possui.desde%TYPE := SYSDATE) RETURN NUMBER IS
    ano_nascimento NUMBER;
    ano_posse NUMBER;
    BEGIN
        SELECT u.nascimento
        INTO ano_nascimento 
        FROM utilizador u
        WHERE u.username = utilizador_in;

        SELECT a.ano 
        INTO ano_posse
        FROM album a 
        WHERE a.ean = album_in;

        IF Extract(year from desde_in) < ano_posse then --Ria 16
            RAISE_APPLICATION_ERROR(-20010, 'Erro: A data de posse não pode ser anterior ao ano de lançamento do álbum.');
        ELSIF desde_in > SYSDATE then 
            RAISE_APPLICATION_ERROR(-20011, 'Erro: A data de posse não pode ser no futuro.');
        ELSIF EXTRACT(year FROM desde_in) < (ano_nascimento + 13) then --Ria 17
            RAISE_APPLICATION_ERROR(-20012, 'Erro: A data de posse não pode ser anterior à data em que o utilizador tem 13 anos.');
        END IF;
        INSERT INTO possui(utilizador, album, desde)
        VALUES (utilizador_in, album_in, desde_in);
        RETURN conta_albuns(utilizador_in);
        exception
            when no_data_found then
                raise_application_error(-20013,'Erro: O utilizador ou álbum especificado não existe na base de dados.');
            when dup_val_on_index then
                raise_application_error(-20014, 'Erro: A posse já existe na base de dados e não pode ser duplicada.');
            when others then
                if sqlcode = -20010 OR sqlcode = -20011 OR sqlcode = -20012 then
                    raise;
                else
                    raise_application_error(-20013, mensagem_erro(SQLERRM, SQLCODE));
                end if;
    END regista_posse;



    FUNCTION remove_posse (utilizador_in IN possui.utilizador%TYPE, album_in IN possui.album%TYPE) RETURN NUMBER IS
    BEGIN
        DELETE FROM possui WHERE utilizador = utilizador_in AND album = album_in;
        if SQL%NOTFOUND then
            RAISE_APPLICATION_ERROR(-20019,'Erro: A posse especificada não existe na base de dados.');
        end if;
        RETURN conta_albuns(utilizador_in);
        exception
          when others then
            if sqlcode = -20019 then
                raise;
            else
            raise_application_error(-20014, mensagem_erro(SQLERRM, SQLCODE));
            end if;
    END remove_posse;


    PROCEDURE remove_utilizador(username_in IN utilizador.username%TYPE) IS
    CURSOR albuns_utilizador IS
        SELECT album FROM possui WHERE utilizador = username_in;
    retorno NUMBER;
    BEGIN
        for album IN albuns_utilizador LOOP
            retorno := remove_posse(username_in, album.album);
        END LOOP;
        DELETE FROM utilizador WHERE username = username_in;
        exception
          when others then
            raise_application_error(-20015, mensagem_erro(SQLERRM, SQLCODE));
    END remove_utilizador;



    PROCEDURE remove_album(ean_in IN album.ean%TYPE) IS
    CURSOR utilizadores_com_album IS 
        SELECT utilizador FROM possui WHERE album = ean_in;
    retorno NUMBER;
    BEGIN
        for utilizador IN utilizadores_com_album LOOP
            retorno := remove_posse(utilizador.utilizador, ean_in);
        END LOOP;
        DELETE FROM album WHERE ean = ean_in;
        exception
          when others then
            raise_application_error(-20016, mensagem_erro(SQLERRM, SQLCODE));
    END remove_album;



    PROCEDURE remove_artista(isni_in IN artista.isni%TYPE) IS
    CURSOR albuns_artista IS
        SELECT ean FROM album WHERE artista = isni_in;
    BEGIN
        for album IN albuns_artista LOOP
            remove_album(album.ean);
        END LOOP;
        DELETE FROM artista WHERE isni = isni_in;
        exception
          when others then
            raise_application_error(-20017, mensagem_erro(SQLERRM, SQLCODE));
    END remove_artista;

    FUNCTION lista_albuns (utilizador_in IN possui.utilizador%TYPE) RETURN SYS_REFCURSOR IS
    resultado SYS_REFCURSOR;
    BEGIN
        OPEN resultado for 
        SELECT a.ean, a.titulo, a.tipo, a.ano, a.suporte, a.versao, 
            CASE when ar.nome = u.artista then ar.nome || '*'
            else ar.nome END as nome_artista
        FROM album a, artista ar, possui p, utilizador u
        WHERE a.artista = ar.isni
        AND a.ean = p.album
        AND u.username = p.utilizador
        AND p.utilizador = utilizador_in
        ORDER BY a.ano DESC, a.titulo ASC, ar.nome ASC;

        RETURN resultado;
    END lista_albuns;
END pkg_colecao;
/
