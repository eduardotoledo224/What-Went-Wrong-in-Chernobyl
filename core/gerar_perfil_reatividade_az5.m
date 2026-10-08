function dpex = gerar_perfil_reatividade_az5(planta, t)
    % Gera o objeto timeseries da reatividade externa baseando-se na cinemática
    
    cin = calcular_cinematica_az5(planta);
    y_tf = zeros(size(t));
    
    for i = 1:length(t)
        tempo = t(i);
        if tempo <= cin.t1
            y_tf(i) = cin.m1 * planta.v * tempo;
        elseif tempo <= cin.t2
            y_tf(i) = cin.PR + cin.m2 * planta.v * (tempo - cin.t1);
        else
            y_tf(i) = cin.PRN;
        end
    end
    
    dpex = timeseries(y_tf, t);
end