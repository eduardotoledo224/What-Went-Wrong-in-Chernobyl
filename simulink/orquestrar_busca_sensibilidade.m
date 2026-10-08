function val_critico = orquestrar_busca_sensibilidade(planta, param_str, val_curvas, N_pontos, config, tab_group)
    % Função orquestradora: gerencia a busca binária, o cache e os plots.
    
    t_final = 150;
    limite_explosao = 100;
    C = 1; % Constante da fronteira linear/log para o BiLog
    
    memoria = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % 1. Busca Binária
    [val_critico, val_seguro] = rastrearFronteiraEstabilidade(planta, param_str, val_curvas, t_final, limite_explosao, memoria);
    
    % 2. Região de Estabilidade
    if isnan(val_critico) && isnan(val_seguro)
        val_picos = [];
    elseif isnan(val_critico)
        val_picos = linspace(min(val_curvas), max(val_curvas), N_pontos);
    else
        val_picos = linspace(val_seguro, val_critico, N_pontos);
    end
    
    % 3. PLOT TEMPORAL (Lado Esquerdo - Todas as curvas)
    if nargin >= 6 && ~isempty(tab_group)
        alvo = uitab(tab_group, 'Title', config.titulo_base);
    else
        alvo = figure('Name', ['Análise - ' config.titulo_base], 'NumberTitle', 'off', 'Position', [100, 100, 1200, 500]);
    end
    subplot(1, 2, 1, 'Parent', alvo); hold on; grid on;
    cores = lines(length(val_curvas));
    
    for k = 1:length(val_curvas)
        val = val_curvas(k);
        resultado = executarSimulacaoMemorizada(planta, param_str, val, t_final, memoria);
        
        % Plota a curva independentemente de ter explodido ou não
        y_trans = sign(resultado.y) .* log10(1 + abs(resultado.y)/C);
        plot(resultado.t, y_trans, 'Color', cores(k,:), 'LineWidth', 2, ...
            'DisplayName', config.func_legenda(val));
    end
    
    % --- Controle de Limites do Eixo X ---
    if isfield(config, 'xlimites')
        xlim(config.xlimites);
    end
    
    % --- Controle de Limites do Eixo Y (Com transformação BiLog) ---
    if isfield(config, 'ylimites')
        limite_inferior = sign(config.ylimites(1)) * log10(1 + abs(config.ylimites(1))/C);
        limite_superior = sign(config.ylimites(2)) * log10(1 + abs(config.ylimites(2))/C);
        ylim([limite_inferior, limite_superior]);
        
        % Ticks dinâmicos restritos aos limites escolhidos
        ticks_base = [-10000, -1000, -100, -10, -1, 0, 1, 10, 100, 1000, 10000];
        ticks_reais = ticks_base(ticks_base >= config.ylimites(1) & ticks_base <= config.ylimites(2));
    else
        % Limites padrão se config.ylimites não for fornecido
        limite_inferior = sign(-1) * log10(1 + abs(-1)/C);
        limite_superior = sign(1000) * log10(1 + abs(1000)/C);
        ylim([limite_inferior, limite_superior]);
        ticks_reais = [-100, -10, -1, 0, 1, 10, 100, 1000];
    end
    
    ticks_trans = sign(ticks_reais) .* log10(1 + abs(ticks_reais)/C);
    set(gca, 'YTick', ticks_trans, 'YTickLabel', string(ticks_reais));
    xlabel('Tempo (s)', 'FontSize', 12);
    ylabel('Variação Relativa (\delta n / n_0)', 'FontSize', 12);
    title(['Dinâmica Temporal: ' config.titulo_base], 'FontSize', 14);
    legend('Location', 'best');
    
    % 4. PLOT DE PICOS (Lado Direito)
    if ~isempty(val_picos)
        subplot(1, 2, 2, 'Parent', alvo); hold on; grid on;
        picos_validos = zeros(size(val_picos));
        
        for k = 1:length(val_picos)
            val = val_picos(k);
            resultado = executarSimulacaoMemorizada(planta, param_str, val, t_final, memoria);
            picos_validos(k) = resultado.pico;
        end
        
        % 'HandleVisibility', 'off' garante que o MATLAB nunca gere legenda para estes pontos
        plot(val_picos, picos_validos, '-o', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'HandleVisibility', 'off');
        xlabel(config.label_x, 'FontSize', 12);
        ylabel('Pico Máximo Estável (\delta n / n_0)', 'FontSize', 12);
        title('Estabilidade Restrita à Região Operacional', 'FontSize', 14);
    end
    
    salvar_grafico(alvo, ['Analise_Unificada_' config.param_str]);
end

function [val_critico, val_seguro] = rastrearFronteiraEstabilidade(planta, param_str, val_curvas, t_final, lim, memoria)
    % Testa os extremos do vetor de entrada. 
    % Realiza busca binária apenas se houver transição de estabilidade.
    
    v_min = min(val_curvas);
    v_max = max(val_curvas);
    
    res_min = executarSimulacaoMemorizada(planta, param_str, v_min, t_final, memoria);
    res_max = executarSimulacaoMemorizada(planta, param_str, v_max, t_final, memoria);
    
    estavel_min = res_min.pico < lim;
    estavel_max = res_max.pico < lim;
    
    if estavel_min && estavel_max
        val_critico = NaN; % Seguro em todo o intervalo
        val_seguro = v_min;
        return;
    elseif ~estavel_min && ~estavel_max
        val_critico = NaN; % Explode em todo o intervalo
        val_seguro = NaN;
        return;
    end
    
    % Identifica qual lado é o seguro e qual é o de explosão
    if estavel_min
        p_seguro = v_min; p_explosao = v_max;
    else
        p_seguro = v_max; p_explosao = v_min;
    end
    
    val_seguro = p_seguro; % Salva o extremo seguro original para usar no plot
    
    tolerancia = abs(v_max - v_min) * 0.01; % 1% da janela de busca
    
    while abs(p_explosao - p_seguro) > tolerancia
        mid = (p_seguro + p_explosao) / 2;
        res_mid = executarSimulacaoMemorizada(planta, param_str, mid, t_final, memoria);
        
        if res_mid.pico < lim
            p_seguro = mid;
        else
            p_explosao = mid;
        end
    end
    
    val_critico = p_seguro; % O último valor estável antes da explosão
end

function resultado = executarSimulacaoMemorizada(planta, param_str, val, t_final, memoria)
    
    chave = sprintf('%.6e', val);
    
    if isKey(memoria, chave)
        resultado = memoria(chave);
        return;
    end
    
    planta.(param_str) = val;
    try
        saida_sim = executar_simulacao_simulink(planta, t_final);
        resultado.t = saida_sim.Time;
        resultado.y = saida_sim.Data;
        resultado.pico = max(resultado.y);
    catch
        resultado.t = [0 t_final];
        resultado.y = [inf inf];
        resultado.pico = inf;
    end
    
    memoria(chave) = resultado; % Salva no dicionário
end