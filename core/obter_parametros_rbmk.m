function planta = obter_parametros_rbmk()
    % Parâmetros do reator RBMK-1000 (Chernobyl) baseados em relatórios soviéticos
    
    planta.keff = 1;
    planta.N0 = 3.2e9; % Potência nominal [W]
    
    % Coeficientes de reatividade
    planta.alphav = 2e-4; % Coeficiente de vazio nominal
    planta.alphacritico = 0.025; % Coeficiente de vazio crítico (acidente)
    planta.alphatheta = -1.2e-5; % Coeficiente Doppler (temperatura)
    
    % Cinética pontual (6 grupos de precursores)
    planta.beta = [0.00021, 0.00142, 0.00127, 0.00256, 0.00074, 0.00027];
    planta.beta_total = sum(planta.beta); % Cache da soma para evitar recalculo
    planta.lambda = [0.0124, 0.0305, 0.111, 0.301, 1.14, 3.01];
    planta.Lambda = 1e-3; % Tempo de geração de nêutrons prontos [s]
    
    % Parâmetros termo-hidráulicos
    planta.kv = 1; 
    planta.ktheta = 900; % [K]
    planta.Tv = 2; % Constante de tempo de vazios [s]
    planta.Ttheta = 5; % Constante de tempo do combustível [s]
    
    % Dinâmica das hastes de controle (Botão AZ-5)
    planta.v = 0.4; % Velocidade de inserção [m/s]
    planta.d = 1.25; % Distância até o pico positivo de grafite [m]
    planta.d1 = 5.75; % Distância do pico positivo até a inserção total [m]
    planta.PR = 0.5 * planta.beta_total; % Pico positivo inicial
    planta.PRN = -2 * planta.beta_total; % Pico negativo final (absorção do boro)

    % Parâmetros para análise de controlador em malha aberta
    planta.fator_grafite = 1.0; % Porcentagem do pico de reatividade positiva
    planta.fator_hastes = 1.0;  % Porcentagem das hastes inseridas

end