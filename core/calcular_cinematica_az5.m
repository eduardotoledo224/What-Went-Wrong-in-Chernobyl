function cin = calcular_cinematica_az5(planta)
    % Calcula todos os parâmetros físicos de inserção das hastes
    
    cin.PR = planta.PR * planta.fator_grafite * planta.fator_hastes;
    cin.PRN = planta.PRN * planta.fator_hastes;
    
    % Instantes de transição
    cin.t1 = planta.d / planta.v;
    cin.t2 = (planta.d + planta.d1) / planta.v;
    
    % Inclinações no domínio do tempo (m = delta_rho / delta_d)
    cin.m1 = cin.PR / planta.d;
    cin.m2 = (cin.PRN - cin.PR) / planta.d1;
    
    % Constantes de ganho para o domínio de Laplace (k = delta_m * v)
    cin.k1 = cin.m1 * planta.v;
    cin.k2 = (cin.m2 - cin.m1) * planta.v;
    cin.k3 = -cin.m2 * planta.v;
end