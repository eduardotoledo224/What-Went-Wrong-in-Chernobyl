function setup()
    % Descobre a pasta onde o arquivo setup.m está salvo
    projectRoot = fileparts(mfilename('fullpath'));
    
    % Configura a pasta de cache do Simulink para ficar dentro de /simulink
    simulinkFolder = fullfile(projectRoot, 'simulink');
    slprjFolder = fullfile(simulinkFolder, 'slprj');
    if ~exist(slprjFolder, 'dir')
        mkdir(slprjFolder);
    end
    Simulink.fileGenControl('set', 'CacheFolder', slprjFolder, 'CodeGenFolder', slprjFolder);

    % Adiciona as demais pastas e todas as suas subpastas ao path do MATLAB
    addpath(genpath(fullfile(projectRoot, 'analises')));
    addpath(genpath(fullfile(projectRoot, 'core')));
    addpath(genpath(fullfile(projectRoot, 'simulink')));
    addpath(genpath(fullfile(projectRoot, 'utils')));
end