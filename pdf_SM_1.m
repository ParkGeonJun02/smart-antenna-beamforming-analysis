clear;
clc;
close all;
N = input('소자수 N 을 입력해 주세요 = ');
w = ones(1, N) / N; 
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
title('Uniform Beam Pattern');
legend('Uniform Beam Pattern', 'Location', 'northeast');
xlim([-90 90]);
ylim([-80 5]);