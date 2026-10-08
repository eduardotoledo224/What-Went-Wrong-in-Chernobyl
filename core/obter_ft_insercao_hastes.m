function Gp = obter_ft_insercao_hastes(planta)
    % Modelagem do distúrbio de inserção das hastes com atrasos de transporte
    cin = calcular_cinematica_az5(planta);

    s = tf('s');
    
    H_base = 1/s^2;
    
    H1 = cin.k1 * H_base;
    H2 = cin.k2 * H_base;
    H2.InputDelay = cin.t1;
    H3 = cin.k3 * H_base;
    H3.InputDelay = cin.t2;
    
    Gp = H1 + H2 + H3;
end
