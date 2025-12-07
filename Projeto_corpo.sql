CREATE OR REPLACE PACKAGE pkg_colecao IS
num_albuns NUMBER;

    --Defenição de funções e procedimentos:
    FUNCTION mensagem_erro (raw_error VARCHAR2) RETURN VARCHAR2 IS
    mensagem VARCHAR2(100);
    BEGIN
    -- Processa a mensagem de erro e devolve uma mensagem mais amigável.
    END mensagem_erro;




    PROCEDURE regista_artista(isni_in IN artista.isni%TYPE, nome_in IN artista.nome%TYPE, inicio_in IN artista.inicio%TYPE)
    IS
    BEGIN
        INSERT INTO artista (isni, nome, inicio) VALUES (isni_in, nome_in, inicio_in);
    END regista_artista;


    PROCEDURE regista_album(
        ean_in IN album.ean%TYPE, titulo_in IN album.titulo%TYPE, tipo_in IN album.tipo%TYPE, ano_in IN album.ano%TYPE, 
        artista_in IN album.artista%TYPE, suporte_in IN album.suporte%TYPE, versao_in IN album.versao%TYPE := NULL)
    IS
    BEGIN 
        INSERT INTO album (ean, titulo, tipo, ano, artista, suporte, versao)
        VALUES (ean_in, titulo_in, tipo_in, ano_in, artista_in, suporte_in, versao_in);
    END regista_album;


    PROCEDURE regista_utilizador(username_in IN utilizador.username%TYPE, email_in IN utilizador.email%TYPE, 
    senha_in IN utilizador.senha%TYPE, nascimento_in IN utilizador.nascimento%TYPE, 
    artista_in IN utilizador.artista%TYPE := NULL)
    IS
    BEGIN
        INSERT INTO utilizador(username, email, senha, nascimento, artista)
        VALUES (username_in, email_in, senha_in, nascimento_in, artista_in)
    END regista_utilizador

