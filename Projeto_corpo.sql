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
