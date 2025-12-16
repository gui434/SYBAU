-- Blocos anónimos para testar violações de integridade
BEGIN
    -- Inserções Válidas 
    
    DBMS_OUTPUT.PUT_LINE('--- 1. Inserções de dados base (Assumidas como Válidas) ---');
    
    pkg_colecao.regista_artista('0000000100000001', 'Quim Barreiros', 1980);
    
    pkg_colecao.regista_utilizador('UserBase', 'base@mail.com', 'secure', 1990);
    
    pkg_colecao.regista_album('1111111111111', 'Album Apto', 'LP', 2010, '0000000100000001', 'Vinil');


    --Erros 

    -- erro no registo do artista com o mesmo isn
    pkg_colecao.regista_artista('0000000100000001', 'Jorge Barreiros', 1980)

    -- erro no registo do utilizador com o mesmo username
    pkg_colecao.regista_utilizador('UserBase', 'ai@mail.com', 'secure', 1990)
END;
/