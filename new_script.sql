BEGIN
    PKG_COLECAO.REMOVE_ARTISTA('0000000121034567');
    pkg_colecao.regista_artista('0000000121034567', 'The Beatles', 1960);
    pkg_colecao.regista_album('0000000123456', 'Abbey Road', 'aaa', 1969, '0000000121034567', 'cd');
    pkg_colecao.regista_album('000001023456', 'Hybrid Theory', 'dvd', 2002, '0000000121034567', 'dvd');

END;