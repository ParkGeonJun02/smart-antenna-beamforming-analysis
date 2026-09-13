clear;
clc;
close all;
N = input('소자수 N 을 입력해 주세요 = ');
SLL = input('원하는 부엽수준을 입력해 주세요 = ');
% Chebyshev 가중치 계산
R = 10^(SLL / 20); 
beta = cosh(acosh(R) / (N - 1)); 
sample_num = 10000; 
psi = linspace(0, pi, sample_num).'; 
function T = calculate_chebyshev_value(n, x) 
 T = zeros(size(x)); 
 index_inside = abs(x) <= 1; 
 T(index_inside) = cos(n * acos(x(index_inside))); 
 index_greater = x > 1; 
 T(index_greater) = cosh(n * acosh(x(index_greater))); 
 index_less = x < -1; 
 T(index_less) = ((-1)^n) * cosh(n * acosh(-x(index_less))); 
end
target = calculate_chebyshev_value(N - 1, beta * cos(psi / 2)); 
target = target / calculate_chebyshev_value(N - 1, beta); 
if mod(N, 2) == 0 
 M = N / 2; 
 A = zeros(sample_num, M); 
 for m = 1:M 
 A(:, m) = 2 * cos((m - 0.5) * psi); end
 coefficient = A \ target; 
 pair_weights = coefficient.'; 
 w = [fliplr(pair_weights), pair_weights]; 
else 
 M = (N - 1) / 2; A = zeros(sample_num, M + 1); 
 A(:, 1) = 1; 
 for m = 1:M
 A(:, m + 1) = 2 * cos(m * psi); end
 coefficient = A \ target; center_weight = coefficient(1); 
 pair_weights = coefficient(2:end).'; 
 w = [fliplr(pair_weights), center_weight, pair_weights];
end
w = real(w); 
w = w / sum(w); 
d_over_lambda = 0.5; 
% 관찰 각도 범위
theta_deg = -90:0.01:90; 
theta_rad = theta_deg * pi / 180; 
% 배열 소자 위치
element_position = ((0:N-1) - (N-1)/2) * d_over_lambda; 
% Array Factor 계산
AF = zeros(size(theta_rad)); 
for n = 1:N 
 AF = AF + w(n) * exp(1j * 2 * pi * element_position(n) * sin(theta_rad));
end
% 정규화 및 dB 변환
AF_mag = abs(AF); 
AF_mag = AF_mag / max(AF_mag); 
AF_dB = 20 * log10(AF_mag + 1e-12); 
% Beam Pattern 출력
figure;
plot(theta_deg, AF_dB); 
grid on; 
xlabel('\theta [deg]'); 
ylabel('Normalized Array Factor [dB]'); 
title('Chebyshev Beam Pattern');
legend('Chebyshev Beam Pattern', 'Location', 'northeast');
xlim([-90 90]);
ylim([-80 5]);