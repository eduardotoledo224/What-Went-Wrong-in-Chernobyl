function analisar_lgr_vazio(planta, tab_group)
    G0 = obter_ft_cinetica_neutonica(planta);
    [Gtheta, Gv] = obter_ft_termohidraulica(planta);
    
    G_interna = feedback(G0 / planta.beta_total, planta.N0 * planta.alphatheta * Gtheta, +1);
    L0 = -(planta.N0 * G_interna * Gv);
    
    if nargin >= 2 && ~isempty(tab_group)
        alvo = uitab(tab_group, 'Title', 'Lugar das Raízes (LGR)');
    else
        alvo = figure('Name', 'LGR - Variação Alpha V', 'NumberTitle', 'off');
    end
    
    ax = axes('Parent', alvo);
    rlocus(ax, L0);
    axis(ax, [-1e4 1e4 -1e4 1e4]);
    grid(ax, 'on');
    title(ax, 'Lugar das Raízes parametrizado pelo Coeficiente de Vazio (\alpha_v)');
    
    salvar_grafico(alvo, 'LGR_Alpha_V');
end