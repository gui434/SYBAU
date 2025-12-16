-- Blocos anónimos para testar violações de integridade
BEGIN
    -- Inserções Válidas 
    
    DBMS_OUTPUT.PUT_LINE('--- 1. Inserções de dados base (Assumidas como Válidas) ---');
    
    pkg_colecao.regista_artista('0000000100000001', 'Quim Barreiros', 1980);
    
    pkg_colecao.regista_utilizador('Pavlidis', 'base@mail.com', 'secure', 1990);
    
    pkg_colecao.regista_album('1111111111111', 'Hybrid Theory', 'LP', 2010, '0000000100000001', 'Vinil');

    pkg_colecao.regista_posse('Pavlidis', 'Hybrid Theory', 2011 );




    --Erros no registo

    --registo do artista com o mesmo isn
    pkg_colecao.regista_artista('0000000100000001', 'Jorge Barreiros', 1980)

    --registo do utilizador com o mesmo username
    pkg_colecao.regista_utilizador('UserBase', 'ai@mail.com', 'secure', 1990)

    --registo do album com o mesmo ean
    pkg_colecao.regista_album('1111111111111', 'Hybrid Theory', 'LP', 2010, '0000000100000001', 'Vinil');

    --registo de posse sem a chave primária
    pkg.pkg_colecao.regista_posse('Pedro', 'Teoria Hibrida', 2006);


    -- Erros nas remoções

    --ausência de um album que exista
    pkg_colecao.remove_album(1111111111112)

    --ausência de Utilizador Valido
    pkg_colecao.remove_posse('Jorge','Hybrid Theory');

    --ausência de um Album Valido
    pkg_colecao.remove_posse('Pavlidis','Mixtape');

    --remoção do registo de Utilizador que não exist 
    pkg_colecao.remove_utilizador("Jorge");

    --remoção de artista que não existe
    pkg_colecao.remove_artista(0000000100000002);

    -- Número de Albuns do Utilizador

    -- Utilizador inexistente
    pkg_colecao.lista_albuns('Jorge')


END;
/