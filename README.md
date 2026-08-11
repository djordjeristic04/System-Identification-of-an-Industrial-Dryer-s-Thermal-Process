# System Identification of an Industrial Dryer's Thermal Process

## Project Description
This repository contains a project on system identification, focusing on modeling the thermal dynamics of an industrial dryer[cite: 3]. The project was developed for the Modeling and Process Identification course at the School of Electrical Engineering, University of Belgrade (academic year 2025/26)[cite: 3]. 

The identification is based on measurements from temperature sensor number 3, with nominal control values set to $U_{g,nom} = 7V$ for the heater and $U_{v,nom} = 0V$ for the fan[cite: 3].

## Dataset & Signals
The identification process utilizes input-output experimental data recorded from the industrial dryer[cite: 3]. The chosen sampling time for the experiments is $T_s = 0.5s$[cite: 3]. The system was excited using three distinct input signals:
*   **Step Signal:** Applied to evaluate the step response by changing the heater voltage by $\Delta u_g = 0.7V$[cite: 3].
*   **Pseudo-Random Binary Sequence (PRBS):** Designed with a period of $N = 63$ and a switching time of $T_{sw} \approx 4.31s$[cite: 3].
*   **Bipolar Square Wave:** Configured with a period of $T_{cet} = 23.1s$[cite: 3].

## Methodology & Model Estimation
Various approaches were used to estimate the mathematical models of the thermal process:
*   **Continuous First-Order Model:** Estimated from the step response, yielding a gain of $K = 0.5028$, a time constant of $T = 4.62s$, and a transport delay of $\tau = 1.47s$[cite: 3].
*   **ARX Identification (Least Squares):** First and second-order discrete ARX models were estimated using both PRBS and bipolar square wave datasets[cite: 3].
*   **Recursive Least Squares (RLS):** Recursive identification was performed with forgetting factors of $\rho = 0.995$, $\rho = 0.98$, and $\rho = 0.9$ to track parameter convergence over time[cite: 3].

## Validation and Results
The estimated models were rigorously evaluated, yielding the following conclusions:
*   **Fit Percentages:** For the PRBS dataset, the first-order ARX model achieved a fit of 44.83%, while the second-order model achieved 44.84%[cite: 3]. For the bipolar square wave dataset, the first-order model achieved 37.41%, and the second-order model achieved 40.08%[cite: 3].
*   **Model Selection:** The first-order model proved to be the most reliable and physically justified representation of the system[cite: 3]. The second-order models consistently exhibited non-minimum phase characteristics (positive continuous zeros) and complex poles, indicating overfitting to measurement noise rather than capturing the actual process dynamics[cite: 3].
*   **RLS Forgetting Factors:** Larger forgetting factors ($\rho = 0.995$ and $\rho = 0.98$) provided more stable and less noisy parameter estimates compared to faster forgetting factors ($\rho = 0.9$)[cite: 3].

## Repository Contents
*   `*.m` files - 7 MATLAB scripts and functions used for data preprocessing, model estimation (Least Squares and RLS), and validation.
*   `MIP Izvestaj.pdf` - The complete project report in Serbian, detailing the theoretical background, methodology, and comprehensive graphical result analysis[cite: 3].

## Authors
Undergraduate students, University of Belgrade:
*   Luka Bajić (2023/0144)[cite: 3]
*   Đorđe Ristić (2023/0064)[cite: 3]

**Mentor:** as. ms. Marko Vučković[cite: 3]
