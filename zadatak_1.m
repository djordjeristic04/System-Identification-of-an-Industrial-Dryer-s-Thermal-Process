clc
clear
close all

%% 1. Učitavanje
load('pobuda_step.mat')

%% 2. Prikaz odziva
figure
hold on
grid on
plot(t, ug, 'r--', 'LineWidth', 2)
plot(t, y, 'b-', 'LineWidth', 2)
xlabel('Vreme [s]')
ylabel('Amplituda')
title('Odziv sistema na step pobudu')

t_pocetno = 200;
t_krajnje = 237;

xline(t_pocetno, 'k--', 'Početak', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 2, 'FontWeight', 'bold')
xline(t_krajnje, 'k--', 'Kraj', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 2, 'FontWeight', 'bold')

legend('Pobuda (ug)', 'Odziv (y)')

%% 3. Identifikacija (K, tau, T)
y_pocetno = y(t == t_pocetno);
y_krajnje = y(t == t_krajnje);
delta_y = y_krajnje - y_pocetno;

% Mrtvo vreme (tau)
indeks_tau = find(y > (y_pocetno + 0.10 * delta_y), 1, 'first');
vreme_tau = t(indeks_tau);
tau = vreme_tau - t_pocetno; 

% Vremenska konstanta (T)
indeks_T = find(y > (y_pocetno + 0.63 * delta_y), 1, 'first');
vreme_T = t(indeks_T);
T = vreme_T - t_pocetno - tau; 

% Pojačanje (K)
delta_ug = 0.7;
K = delta_y / delta_ug;

%% 4. Odabiranje
Ts = 0.5;
N = Ts / 0.01;
t = t(1:N:end); ug = ug(1:N:end); y = y(1:N:end);

%% 5. Kontinualni model G(s)
s = tf('s');
Gs = K / (T * s + 1);
Gs = minreal(Gs);
Gs.InputDelay = tau;

%% 6. Diskretni model G(z)
z = tf('z', Ts);
a1 = -exp(-Ts/T);
b1 = K * (1 - exp(-Ts/T));
Gz = (b1 * z^(-1)) / (1 + a1 * z^(-1));
Gz = minreal(Gz);
d = ceil(tau / Ts);
Gz.InputDelay = d;

%% 7. Validacija modela
indeksi_prozor = (t_pocetno <= t & t <= t_krajnje);
t_prozor = t(indeksi_prozor);
y_prozor = y(indeksi_prozor);

t_sim = t_prozor - t_pocetno;
u_sim = delta_ug * ones(size(t_sim)); 
y_s = lsim(Gs, u_sim, t_sim) + y_pocetno;

figure
hold on
grid on
plot(t_prozor, y_prozor, 'b-', 'LineWidth', 2)
plot(t_prozor, y_s, 'g--', 'LineWidth', 2)
xlabel('Vreme [s]')
ylabel('Amplituda')
title('Poređenje originalnog odziva i kontinualnog modela G(s)')
legend('Originalni odziv (y)', 'Odziv kontinualnog modela (y_s)')

%% 8. Prikaz rezultata
disp(['Pojačanje: ' num2str(K)])
disp(['Vreme kašnjenja:' num2str(tau)])
disp(['Vremenska konstanta: ' num2str(T)])
disp(['Perioda odabiranja:' num2str(Ts)])

disp('Kontinualna funkcija prenosa G(s)')
disp(Gs)

disp('Diskretna funkcija prenosa G(z)')
disp(Gz)

disp('Oblik diferencne jednačine (ARX model)')
disp(['y(k) = ' num2str(-a1) '·y(k-1) + ' num2str(b1) '·u(k-' num2str(d+1) ')'])

%% 9. Čuvanje
save('pobuda_step_obradjeno.mat', 't', 'ug', 'y', 'K', 'tau', 'T', 'Ts', 'Gs', 'Gz')
