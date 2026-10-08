function Gc = obter_ft_malha_fechada(planta)
    % FT do reator utilizada para análise de instabilidade do desastre
    % (resposta dn/n0 para um estímulo dp_ex)
    G0 = obter_ft_cinetica_neutonica(planta);
    GF = obter_ft_realimentacao_termica(planta);

    Gc = feedback((1 / planta.beta_total) * G0, planta.N0 * GF, +1);
end