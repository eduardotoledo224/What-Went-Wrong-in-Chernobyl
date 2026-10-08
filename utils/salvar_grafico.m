function salvar_grafico(alvo, nome_arquivo)
    projectRoot = fileparts(mfilename('fullpath')); % Pasta do utilitario
    pasta_destino = fullfile(projectRoot, '..', 'imagens'); % Aponta para /imagens na raiz
    
    if ~exist(pasta_destino, 'dir')
        mkdir(pasta_destino, 's');
    end
    
    caminho_completo = fullfile(pasta_destino, [nome_arquivo '.png']);
    
    % Se 'alvo' for uma Figure e contiver uitabgroup, extrai a aba ativa/primeira aba ou usa exportgraphics
    try
        exportgraphics(alvo, caminho_completo, 'Resolution', 300);
    catch ME
        % Caso receba uma Figure com uitabgroup que cause rejeicao no exportgraphics
        if isa(alvo, 'matlab.ui.Figure')
            % Tenta salvar os eixos visiveis/ativos atuais
            ax = findobj(alvo, 'type', 'axes');
            if ~isempty(ax)
                exportgraphics(ax(1), caminho_completo, 'Resolution', 300);
            else
                rethrow(ME);
            end
        else
            rethrow(ME);
        end
    end
end