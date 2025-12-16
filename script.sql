-- Blocos anónimos para testar violações de integridade
BEGIN
    -- INSERÇÕES VÁLIDAS 
    
    DBMS_OUTPUT.PUT_LINE('--- 1. Inserções de dados base (Assumidas como Válidas) ---');
    
    pkg_colecao.regista_artista('0000000100000001', 'Artista Apto', 2000);
    
    pkg_colecao.regista_utilizador('UserBase', 'base@mail.com', 'secure', 1990);
    
    pkg_colecao.regista_album('1111111111111', 'Album Apto', 'LP', 2010, '0000000100000001', 'Vinil');

    -- VIOLAÇÕES DE CHAVE PRIMÁRIA 

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 2. Erro Propositado: Duplicação de Chave Primária (PK) ---');
    
    -- 2.1. ERRO PK: Tenta inserir o mesmo 'username' ('UserBase') novamente
    -- Resultado Esperado: ORA-00001: unique constraint violated
    DBMS_OUTPUT.PUT_LINE('2.1. Duplicação de Utilizador: UserBase');
    pkg_colecao.regista_utilizador(
        username_in     => 'UserBase', -- VALOR DUPLICADO
        email_in        => 'novo@email.com', 
        senha_in        => 'pws', 
        nascimento_in   => 1995
        -- artista_in opcional
    );
    
    -- 2.2. ERRO PK: Tenta inserir o mesmo 'ean' ('1111111111111') novamente
    -- Resultado Esperado: ORA-00001: unique constraint violated
    DBMS_OUTPUT.PUT_LINE('2.2. Duplicação de Album: 1111111111111');
    pkg_colecao.regista_album(
        ean_in      => '1111111111111', -- VALOR DUPLICADO
        titulo_in   => 'Album Duplicado', 
        tipo_in     => 'CD', 
        ano_in      => 2020, 
        artista_in  => '0000000100000001', 
        suporte_in  => 'CD'
    );


    -- =========================================================
    -- PASSO 3: VIOLAÇÕES DE CHAVE ESTRANGEIRA (Referência Inexistente)
    -- =========================================================
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 3. Erro Propositado: Chave Estrangeira (FK) Inexistente ---');
    
    -- 3.1. ERRO FK: Tenta inserir um 'album' com um 'artista' que não existe
    -- Resultado Esperado: ORA-02291: integrity constraint violated - parent key not found
    DBMS_OUTPUT.PUT_LINE('3.1. Album com Artista Inexistente: 9999...');
    pkg_colecao.regista_album(
        ean_in      => '2222222222222', 
        titulo_in   => 'Album Fantasma', 
        tipo_in     => 'CD', 
        ano_in      => 2024, 
        artista_in  => '9999999999999999', -- ISNI INEXISTENTE
        suporte_in  => 'Digital'
    );
    
    -- 3.2. ERRO FK: Tenta criar uma posse com um utilizador ou album que não existe
    -- Resultado Esperado: ORA-02291: integrity constraint violated - parent key not found
    DBMS_OUTPUT.PUT_LINE('3.2. Posse com Utilizador Inexistente: UserInvalido');
    DECLARE
        v_dummy NUMBER;
    BEGIN
        v_dummy := pkg_colecao.regista_posse(
            utilizador_in => 'UserInvalido', -- UTILIZADOR INEXISTENTE
            album_in      => '1111111111111' 
        );
    END;


    -- =========================================================
    -- PASSO 4: ERRO DE COMPILAÇÃO (Chamada incorreta para função/procedimento)
    -- =========================================================

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 4. Erro Propositado: Chamada Incorreta ---');

    -- Este erro irá parar a compilação do bloco DECLARE/BEGIN/END,
    -- a menos que seja encapsulado numa unidade separada ou tratado no exception handler.
    -- (Assumindo que artista.inicio é NUMBER, e o input é string)
    DBMS_OUTPUT.PUT_LINE('4.1. Tipo de dado inválido (Conversão CHAR -> NUM)');
    pkg_colecao.regista_artista(
        isni_in     => '0000000100000002', 
        nome_in     => 'Artista String', 
        inicio_in   => 'Ano Errado' -- Tipo de dado incompatível
    );
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '---------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('FALHA DE EXECUÇÃO DETETADA!');
        DBMS_OUTPUT.PUT_LINE('Código do Erro: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Mensagem: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
        ROLLBACK; -- Desfaz todas as operações no bloco
END;
/