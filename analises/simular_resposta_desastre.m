function simular_resposta_desastre(planta, planta_falha, tab_group)
    % Plota a resposta temporal comparativa do reator (Nominal vs. Falha AZ-5)
    
    t_final = 30;
    
    % Resposta Nominal (Estável)
    saida_nominal = executar_simulacao_simulink(planta, t_final);
    
    % Resposta em Falha (Instável)
    saida_falha = executar_simulacao_simulink(planta_falha, t_final);
    
    % Gerenciamento da janela/aba
    if nargin >= 2 && ~isempty(tab_group)
        alvo = uitab(tab_group, 'Title', 'Resposta Temporal (AZ-5)');
    else
        alvo = figure('Name', 'Resposta Temporal do Reator', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 500]);
    end
    
    % Subplot de Condição Nominal
    ax1 = subplot(1, 2, 1, 'Parent', alvo); grid(ax1, 'on');
    plot(ax1, saida_nominal.Time, saida_nominal.Data, 'b-', 'LineWidth', 2);
    xlabel(ax1, 'Tempo (s)', 'FontSize', 11);
    ylabel(ax1, 'Variação Relativa (\delta n / n_0)', 'FontSize', 11);
    title(ax1, 'Operação Nominal (Estável)', 'FontSize', 13);
    
    % Subplot de Condição Crítica
    ax2 = subplot(1, 2, 2, 'Parent', alvo); grid(ax2, 'on');
    plot(ax2, saida_falha.Time, saida_falha.Data, 'r-', 'LineWidth', 2);
    xlabel(ax2, 'Tempo (s)', 'FontSize', 11);
    ylabel(ax2, 'Variação Relativa (\delta n / n_0)', 'FontSize', 11);
    title(ax2, 'Condição do Acidente (\alpha_v elevado)', 'FontSize', 13);
    
    salvar_grafico(alvo, 'Resposta_Temporal_Comparativa');
end
