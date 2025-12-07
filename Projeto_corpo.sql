CREATE OR REPLACE PACKAGE pkg_colecao IS
num_albuns NUMBER;

    --Defenição de funções e procedimentos:
    FUNCTION mensagem_erro (raw_error VARCHAR2, code_error NUMBER) RETURN VARCHAR2 IS
    mensagem VARCHAR2(100);
    BEGIN
        CASE code_error
            WHEN 1 THEN
                mensagem := 'Erro de integridade: ' || raw_error;
            WHEN 1400 THEN
                mensagem := 'Erro: Valor nulo não permitido. ' || raw_error;
            WHEN 2291 THEN
                mensagem := 'Erro: Chave estrangeira violada. ' || raw_error;
            WHEN 1 THEN
                mensagem := 'Erro: Violação de chave primária. ' || raw_error;
            ELSE
                mensagem := 'Erro desconhecido: ' || raw_error;
        END CASE;
        RETURN mensagem;
    END mensagem_erro;


    PROCEDURE regista_artista(isni_in IN artista.isni%TYPE, nome_in IN artista.nome%TYPE, inicio_in IN artista.inicio%TYPE)
    IS
    BEGIN
        INSERT INTO artista (isni, nome, inicio) VALUES (isni_in, nome_in, inicio_in);

    exception
      when others then
        DBMS_OUTPUT.PUT_LINE(mensagem_erro(SQLERRM, SQLCODE));
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

