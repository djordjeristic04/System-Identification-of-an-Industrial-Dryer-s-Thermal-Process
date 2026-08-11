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

%% 4. Priprema i iddata
ug = ug - mean(ug); y = y - mean(y);
podaci = iddata(y, ug, Ts);

%% 5. ARX identifikacija
model_prvi_red = arx(podaci, [1 1 1]);
model_drugi_red = arx(podaci, [2 2 1]); 

model_prvi_red.InputDelay = d;
model_drugi_red.InputDelay = d;

%% 6. Prikaz poređenja
figure
compare(podaci, model_prvi_red, model_drugi_red)

figure
compare(podaci, model_prvi_red, model_drugi_red)
xlim([25 100])

%% 7. Model 1. reda (G1s, G1z)
G1z = tf(model_prvi_red);
G1s = d2c(G1z);

[z1z, p1z] = zpkdata(G1z, 'v');
[z1s, p1s] = zpkdata(G1s, 'v');
T1 = -1 ./ real(p1s);
K1 = dcgain(G1s);

disp('MODEL PRVOG REDA (bipolarna cetvrtka)')
disp(['Nule:    |  Diskretne: [', num2str(z1z'), ']  |  Kontinualne: [', num2str(z1s'), ']'])
disp(['Polovi:  |  Diskretni: [', num2str(p1z'), ']  |  Kontinualni: [', num2str(p1s'), ']'])
disp(['Vremenska konstanta: ', num2str(T1')])
disp(['Staticko pojacanje:  ', num2str(K1), newline])

%% 8. Model 2. reda (G2s, G2z)
G2z = tf(model_drugi_red);
G2s = d2c(G2z);

[z2z, p2z] = zpkdata(G2z, 'v');
[z2s, p2s] = zpkdata(G2s, 'v');
T2 = -1 ./ real(p2s);
K2 = dcgain(G2s);

disp('MODEL DRUGOG REDA (bipolarna cetvrtka)')
disp(['Nule:    |  Diskretne: [', num2str(z2z'), ']  |  Kontinualne: [', num2str(z2s'), ']'])
disp(['Polovi:  |  Diskretni: [', num2str(p2z'), ']  |  Kontinualni: [', num2str(p2s'), ']'])
disp(['Vremenske konstante: ', num2str(T2')])
disp(['Staticko pojacanje:  ', num2str(K2), newline])
