CREATE OR REPLACE PACKAGE pkg_colecao IS
    --Assinatura de funções e procedimentos:
    PROCEDURE regista_artista(isni_in IN artista.isni%TYPE, nome_in IN artista.nome%TYPE, inicio_in IN artista.inicio%TYPE);

    PROCEDURE regista_album(
        ean_in IN album.ean%TYPE, titulo_in IN album.titulo%TYPE, tipo_in IN album.tipo%TYPE, ano_in IN album.ano%TYPE, 
        artista_in IN album.artista%TYPE, suporte_in IN album.suporte%TYPE, versao_in IN album.versao%TYPE := NULL);

    PROCEDURE regista_utilizador(username_in IN utilizador.username%TYPE, email_in IN utilizador.email%TYPE, 
    senha_in IN utilizador.senha%TYPE, nascimento_in IN utilizador.nascimento%TYPE, 
    artista_in IN utilizador.artista%TYPE := NULL);

    PROCEDURE remove_utilizador(username_in IN utilizador.username%TYPE);

    PROCEDURE remove_album(ean_in IN album.ean%TYPE);

    PROCEDURE remove_artista(isni_in IN artista.isni%TYPE);

    FUNCTION regista_posse(utilizador_in IN possui.utilizador%TYPE, album_in IN possui.album%TYPE, 
    desde_in IN possui.desde%TYPE := SYSDATE) RETURN NUMBER;

    FUNCTION remove_posse(utilizador_in IN possui.utilizador%TYPE, album_in IN possui.album%TYPE) RETURN NUMBER;

    FUNCTION lista_albuns(utilizador_in IN possui.utilizador%TYPE) RETURN SYS_REFCURSOR;

    END pkg_colecao;
/

