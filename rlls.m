function [istorija_theta, greske_predikcije] = rlls(phi, y, rho)

    broj_odabiraka = length(y);
    velicina_theta = size(phi, 2);

    P = 1e4 * eye(velicina_theta);
    theta_hat = zeros(velicina_theta, 1);

    istorija_theta = zeros(broj_odabiraka, velicina_theta);
    greske_predikcije = zeros(broj_odabiraka, 1);

    for N = 0:(broj_odabiraka - 1)
        phi_sl = phi(N+1, :)';
        y_sl = y(N+1);

        greska = y_sl - phi_sl' * theta_hat;
        
        P_sl = (1 / rho) * (P - P * phi_sl * (phi_sl' * P * phi_sl + rho)^(-1) * phi_sl' * P);
        K_sl = P_sl * phi_sl;
        theta_hat = theta_hat + K_sl * greska;
        
        istorija_theta(N+1, :) = theta_hat';
        greske_predikcije(N+1) = greska;

        P = P_sl;
    end

end