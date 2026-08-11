function phi = napravi_phi(u, y, red_modela)

    broj_odbiraka = length(y);
    
    if red_modela == 1
        phi = zeros(broj_odbiraka, 2);
        for k = 2:broj_odbiraka
            phi(k, :) = [-y(k-1), u(k-1)];
        end   
    elseif red_modela == 2
        phi = zeros(broj_odbiraka, 4);
        for k = 3:broj_odbiraka
            phi(k, :) = [-y(k-1), -y(k-2), u(k-1), u(k-2)];
        end
    end

end