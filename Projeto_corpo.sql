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
