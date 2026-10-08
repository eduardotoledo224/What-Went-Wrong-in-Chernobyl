function saida = executar_simulacao_simulink(planta, t_final)
    % Simula a planta termodinâmica no Simulink
    
    t = 0:0.01:t_final;
    
    % Delega a criação da rampa para a função especialista
    dpex = gerar_perfil_reatividade_az5(planta, t);

    % Setup do Simulink
    [Gtheta, Gv] = obter_ft_termohidraulica(planta);
    G0 = obter_ft_cinetica_neutonica(planta);

    %coloca no simulink esses dados

    [numG0, denG0] = tfdata(G0, 'v');
    [numGv, denGv] = tfdata(Gv, 'v');
    [numGtheta, denGtheta] = tfdata(Gtheta, 'v');

    reator_chernobyl = 'ReatorChernobyl';
    load_system(reator_chernobyl);
    in = Simulink.SimulationInput(reator_chernobyl);
    
    in = in.setModelParameter('StopTime', num2str(t_final));
    in = in.setModelParameter('Solver', 'ode15s');
    
    in = in.setVariable('dpex', dpex);
    in = in.setVariable('numG0', numG0);
    in = in.setVariable('denG0', denG0);
    in = in.setVariable('numGv', numGv);
    in = in.setVariable('denGv', denGv);
    in = in.setVariable('numGtheta', numGtheta);
    in = in.setVariable('denGtheta', denGtheta);
    in = in.setVariable('planta', planta);
    in = in.setVariable('beta', planta.beta_total); 

    %simula

    simulacao = sim(in);
    saida = simulacao.NeutronVar;
end