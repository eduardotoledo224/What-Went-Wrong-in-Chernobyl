function GF = obter_ft_realimentacao_termica(planta)
    % FT da reatividade total de realimentação combinada (Doppler + Vazios)
    [Gtheta, Gv] = obter_ft_termohidraulica(planta);
    
    GF = planta.alphatheta * Gtheta + planta.alphav * Gv;
end