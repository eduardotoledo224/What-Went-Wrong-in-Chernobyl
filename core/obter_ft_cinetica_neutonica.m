function G0 = obter_ft_cinetica_neutonica(planta)
    % FT da cinética pontual: relaciona reatividade fracionária com potência
    s = tf('s');
    
    % Avalia os 6 grupos
    soma_precursores = 0;
    for i = 1:length(planta.beta)
	    soma_precursores = soma_precursores + (planta.beta(i))/planta.beta_total/(s + planta.lambda(i));
    end
    
    G0 = 1 / (s * (planta.Lambda / planta.beta_total + soma_precursores));
end