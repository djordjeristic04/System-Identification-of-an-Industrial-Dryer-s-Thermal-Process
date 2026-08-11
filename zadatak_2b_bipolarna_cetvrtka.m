clc
clear
close all

%% 1. Kašnjenje
load('pobuda_step_obradjeno.mat', 'tau', 'Ts')
d = ceil(tau / Ts);

%% 2. Učitavanje i odabiranje
load('pobuda_bipolarna_cetvrtka.mat')

N = Ts / 0.01;
t = t(1:N:end); ug = ug(1:N:end); y = y(1:N:end);

%% 3. Odsecanje signala
t_pocetno = 200 + d * Ts;    
t_krajnje = t(end);    

indeksi = (t_pocetno <= t & t <= t_krajnje);
t = t(indeksi); ug = ug(indeksi); y = y(indeksi);

%% 4. Priprema podataka
ug = ug - mean(ug); y = y - mean(y);

phi1 = napravi_phi(ug, y, 1);
phi2 = napravi_phi(ug, y, 2);

rhos = [0.995, 0.98, 0.9];

theta1 = cell(1, length(rhos));
theta2 = cell(1, length(rhos));
greske1 = cell(1, length(rhos));
greske2 = cell(1, length(rhos));

%% 5. RLLS estimacija
for i = 1:length(rhos)
    [theta1{i}, greske1{i}] = rlls(phi1, y, rhos(i));
    [theta2{i}, greske2{i}] = rlls(phi2, y, rhos(i));
end

%% 6. Prikaz grešaka
disp('MODEL PRVOG REDA (bipolarna cetvrtka)')
for i = 1:length(rhos)
    J1 = mean(greske1{i}.^2);
    disp(['Za rho = ' num2str(rhos(i)) ' -> J = ' num2str(J1)])
end
disp(' ')

disp('MODEL DRUGOG REDA (bipolarna cetvrtka)')
for i = 1:length(rhos)
    J2 = mean(greske2{i}.^2);
    disp(['Za rho = ' num2str(rhos(i)) ' -> J = ' num2str(J2)])
end
disp(' ')

%% 7. Prikaz konvergencije
nazivi1 = {'a_1', 'b_1'};
nazivi2 = {'a_1', 'a_2', 'b_1', 'b_2'};

% Model 1. reda
figure
for j = 1:2
    subplot(1,2,j)
    hold on
    grid on
    for i = 1:length(rhos)
        plot(theta1{i}(:, j))
    end
    title(['Parametar ', nazivi1{j}])
    xlabel('Odbirak (Vreme)')
    ylabel(['Vrednost za ', nazivi1{j}])
    if j == 1
        legend('\rho = 0.995', '\rho = 0.98', '\rho = 0.9')
    end
end
sgtitle('Model 1. reda: Estimacija parametara kroz vreme (Bipolarna četvrtka)') 

% Model 2. reda
figure
for j = 1:4
    subplot(2,2,j)
    hold on
    grid on
    for i = 1:length(rhos)
        plot(theta2{i}(:, j))
    end
    title(['Parametar ', nazivi2{j}])
    xlabel('Odbirak (Vreme)')
    ylabel(['Vrednost za ', nazivi2{j}])
    if j == 1
        legend('\rho = 0.995', '\rho = 0.98', '\rho = 0.9')
    end
end
sgtitle('Model 2. reda: Estimacija parametara kroz vreme (Bipolarna četvrtka)') 

%% 8. Analiza za svako rho
z = tf('z', Ts);

for i = 1:length(rhos)
    % Model 1. reda
    theta_1 = theta1{i}(end, :);
    a1 = theta_1(1); b1 = theta_1(2);
    
    G1z = (b1 * z^(-1)) / (1 + a1 * z^(-1));
    G1z = minreal(G1z);
    G1z.InputDelay = d;
    G1s = d2c(G1z);

    % Model 2. reda
    theta_2 = theta2{i}(end, :);
    a1 = theta_2(1); a2 = theta_2(2); b1 = theta_2(3); b2 = theta_2(4);
    
    G2z = (b1 * z^(-1) + b2 * z^(-2)) / (1 + a1 * z^(-1) + a2 * z^(-2));
    G2z = minreal(G2z);
    G2z.InputDelay = d;
    G2s = d2c(G2z);

    % Poređenje odziva
    podaci = iddata(y, ug, Ts);
    [y1sim, fit1] = compare(podaci, G1z);
    [y2sim, fit2] = compare(podaci, G2z);

    figure

    subplot(2,1,1)
    hold on
    grid on
    plot(t, y)
    plot(t, y1sim.OutputData)
    plot(t, y2sim.OutputData)
    legend('Stvarni sistem', ['Model n=1 (' num2str(fit1) '%)'], ['Model n=2 (' num2str(fit2) '%)'])
    xlabel('t [s]')
    ylabel('y')
    title('Kompletna sekvenca')

    subplot(2,1,2)
    hold on
    grid on
    plot(t, y)
    plot(t, y1sim.OutputData)
    plot(t, y2sim.OutputData)
    xlim([225 300]);
    xlabel('t [s]')
    ylabel('y')
    title('Zumirano (25-100s)')

    sgtitle(['Poređenje modela za \rho = ', num2str(rhos(i))])

    % Karakteristike 1. reda
    [z1z, p1z] = zpkdata(G1z, 'v');
    [z1s, p1s] = zpkdata(G1s, 'v');
    T1 = -1 ./ real(p1s);
    K1 = dcgain(G1s);

    disp(['MODEL PRVOG REDA (bipolarna cetvrtka, rho = ' num2str(rhos(i)) ')'])
    disp(['Nule:    |  Diskretne: [', num2str(z1z'), ']  |  Kontinualne: [', num2str(z1s'), ']'])
    disp(['Polovi:  |  Diskretni: [', num2str(p1z'), ']  |  Kontinualni: [', num2str(p1s'), ']'])
    disp(['Vremenska konstanta: ', num2str(T1')])
    disp(['Staticko pojacanje:  ', num2str(K1), newline])

    % Karakteristike 2. reda
    [z2z, p2z] = zpkdata(G2z, 'v');
    [z2s, p2s] = zpkdata(G2s, 'v');
    T2 = -1 ./ real(p2s);
    K2 = dcgain(G2s);

    disp(['MODEL DRUGOG REDA (bipolarna cetvrtka, rho = ' num2str(rhos(i)) ')'])
    disp(['Nule:    |  Diskretne: [', num2str(z2z'), ']  |  Kontinualne: [', num2str(z2s'), ']'])
    disp(['Polovi:  |  Diskretni: [', num2str(p2z'), ']  |  Kontinualni: [', num2str(p2s'), ']'])
    disp(['Vremenske konstante: ', num2str(T2')])
    disp(['Staticko pojacanje:  ', num2str(K2), newline])
end
