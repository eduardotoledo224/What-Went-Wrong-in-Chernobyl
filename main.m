%% SIMULAÇÃO E ANÁLISE DE ESTABILIDADE DO REATOR RBMK-1000 (CHERNOBYL)
% Autores: Danilo Carlos e Eduardo Toledo
% Descrição: Estudo da dinâmica de controle e análise de sensibilidade 
%            dos parâmetros críticos que levaram ao acidente de Chernobyl.

clear; clc; close all;
warning('off', 'all'); % Desativa warnings secundários de figuras e exportação

setup();
fig_mestre = figure('Name', 'Painel Geral de Análise - Reator RBMK-1000', ...
                    'NumberTitle', 'off', ...
                    'Position', [100, 100, 1300, 650]);
tab_group = uitabgroup(fig_mestre);

fprintf('=================================================================\n');
fprintf('Simulação de estabilidade termo-hidráulica do reator de Chernobyl\n');
fprintf('=================================================================\n\n');

%% Inicialização do Modelo
fprintf('[ETAPA 1/4] Carregando parâmetros nominais da planta RBMK...\n');
planta = obter_parametros_rbmk();
fprintf('   -> Potência Nominal: %.1f MWt\n', planta.N0 / 1e6);
fprintf('   -> Coeficiente de Vazio Nominal: %.1e\n\n', planta.alphav);

%% Análise de Frequência e Estabilidade em Malha Aberta
fprintf('[ETAPA 2/4] Executando análise de estabilidade linearizada (LGR e Nyquist)...\n');
analisar_lgr_vazio(planta, tab_group);
analisar_nyquist_vazio(planta, tab_group);
fprintf('   -> Diagramas de LGR e Nyquist gerados.\n\n');

%% Simulação da Resposta Temporal do Acidente
fprintf('[ETAPA 3/4] Simulando dinâmica temporal do acionamento do Botão AZ-5...\n');
planta_falha = aplicar_condicoes_acidente(planta);
simular_resposta_desastre(planta, planta_falha, tab_group);
fprintf('   -> Resultados obtidos para os comportamentos estável e instável da usina.\n\n');

%% Análise Paramétrica de Sensibilidade
fprintf('[ETAPA 4/4] Aplicando condições de falha e executando busca de limites críticos...\n');
limites = analisar_sensibilidade(planta_falha, tab_group);

%% RELATÓRIO FINAL DE SEGURANÇA
fprintf('\n=================================================================\n');
fprintf('                  RELATÓRIO DE LIMITES CRÍTICOS                  \n');
fprintf('=================================================================\n');

if ~isnan(limites.alphav)
    fprintf('  • Coeficiente de Vazio Crítico   : %.6f\n', limites.alphav);
else
    fprintf('  • Coeficiente de Vazio Crítico   : [Inconclusivo / Instável no Intervalo]\n');
end

if ~isnan(limites.v)
    fprintf('  • Velocidade Mínima das Hastes   : %.2f m/s\n', limites.v);
else
    fprintf('  • Velocidade Mínima das Hastes   : [Inconclusivo no Intervalo]\n');
end

if ~isnan(limites.fator_grafite)
    fprintf('  • Pico Máximo Tolerável (Grafite): %.2f%%\n', limites.fator_grafite * 100);
else
    fprintf('  • Pico Máximo Tolerável (Grafite): [Inconclusivo no Intervalo]\n');
end

if ~isnan(limites.fator_hastes)
    fprintf('  • Inserção Mínima Segura (AZ-5)  : %.2f%%\n', limites.fator_hastes * 100);
else
    fprintf('  • Inserção Mínima Segura (AZ-5)  : [Inconclusivo no Intervalo]\n');
end

fprintf('-----------------------------------------------------------------\n');
fprintf('Fim da Simulação.\n');
fprintf('=================================================================\n');