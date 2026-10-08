function analisar_nyquist_vazio(planta, tab_group)
    % Traça diagrama de Nyquist para diferentes valores de alpha_v
    % Compara lado a lado a visão completa e o zoom no ponto crítico -1+0j
    
    G0 = obter_ft_cinetica_neutonica(planta);
    [Gtheta, Gv] = obter_ft_termohidraulica(planta);
    
    G_interna = feedback(G0 / planta.beta_total, planta.N0 * planta.alphatheta * Gtheta, +1);
    L0 = -(planta.N0 * G_interna * Gv);
    
    vetor_alpha = 0.002:0.0005:0.005;
    
    % Gerenciamento da janela/aba
    if nargin >= 2 && ~isempty(tab_group)
        alvo = uitab(tab_group, 'Title', 'Análise de Nyquist');
    else
        alvo = figure('Name', 'Diagrama de Nyquist Comparativo', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 500]);
    end
    
    % Subplot Panorâmico
    ax1 = subplot(1, 2, 1, 'Parent', alvo); hold(ax1, 'on'); grid(ax1, 'on');
    for k = 1:length(vetor_alpha)
        nyquist(ax1, vetor_alpha(k) * L0);
    end
    title(ax1, 'Visão Completa');
    
    % Zoom no Ponto Crítico
    ax2 = subplot(1, 2, 2, 'Parent', alvo); hold(ax2, 'on'); grid(ax2, 'on');
    for k = 1:length(vetor_alpha)
        nyquist(ax2, vetor_alpha(k) * L0);
    end
    xlim(ax2, [-2 0.5]); ylim(ax2, [-1 1]);
    title(ax2, 'Zoom no Ponto Crítico (-1+0j)');
    
    salvar_grafico(alvo, 'Nyquist_Comparativo');
end