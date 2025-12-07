CREATE OR REPLACE PACKAGE pkg_colecao IS
num_albuns NUMBER;

--Defenição de um dicionário de erros temporários:
    TYPE t_dicionario_erros IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(128);
    dicionario_erros t_dicionario_erros;

    --Defenição de funções e procedimentos:
    FUNCTION mensagem_erro (raw_error VARCHAR2, code_error NUMBER) RETURN VARCHAR2 IS
    mensagem VARCHAR2(100);
    BEGIN
        CASE code_error
            WHEN -1 THEN
                mensagem := 'Erro: Valor já existe na base de dados e não pode ser duplicado. ';
            WHEN -1400 THEN
                mensagem := 'Erro: Valor nulo não permitido. Adicione um valor válido.';
            WHEN -2290 THEN
              mensagem := 'Erro: Violação da restrição de verificação.';  
            WHEN -2291 THEN
                mensagem := 'Erro: O valor referenciado não existe na tabela pai.';
            WHEN -2292 THEN
                mensagem := 'Erro: O valor está a ser referenciado por outra tabela e não pode ser eliminado.';
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

BEGIN
   dicionario_erros('ck_artista_isni') := 'ISNI inválido. Deve conter 15 dígitos seguidos de um dígito verificador (0-9 ou X).';
   dicionario_erros('ck_artista_inicio') := 'Ano de início inválido. Deve ser um valor positivo.';
   dicionario_erros('ck_versao_ean') := 'EAN inválido. Deve conter exatamente 13 dígitos.';
   dicionario_erros('ck_album_tipo') := 'Tipo de álbum inválido. Deve ser "single", "EP" ou "LP".';
   dicionario_erros('ck_album_ano') := 'Ano de álbum inválido. Deve ser maior ou igual a 1900.';
   dicionario_erros('ck_album_suporte') := 'Suporte inválido. Deve ser "CD", "vinil" ou "cassete".';
   dicionario_erros('ck_utilizador_username') := 'Nome de utilizador inválido, tem de coter apenas letras e números.';
   dicionario_erros('ck_utilizador_nascimento') := 'Ano de nascimento inválido. Deve ser um valor maior ou igual a 1900 e menor ou igual ao ano atual.';
   dicionario_erros('ck_possui_desde') := 'Data inválida. Um registo de coleção tem de ser posterior a 1990 e não pode ser no futuro.';

END pkg_colecao;
/
