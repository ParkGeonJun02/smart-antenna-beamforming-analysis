clear;
clc;
close all;

N = input('소자수 N 을 입력해 주세요 = ');
SLL = input('원하는 부엽수준을 입력해 주세요 = ');

%% Chebyshev 가중치 계산
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
        A(:, m) = 2 * cos((m - 0.5) * psi);
    end

    coefficient = A \ target;
    pair_weights = coefficient.';
    w = [fliplr(pair_weights), pair_weights];

else
    M = (N - 1) / 2;
    A = zeros(sample_num, M + 1);
    A(:, 1) = 1;

    for m = 1:M
        A(:, m + 1) = 2 * cos(m * psi);
    end

    coefficient = A \ target;
    center_weight = coefficient(1);
    pair_weights = coefficient(2:end).';
    w = [fliplr(pair_weights), center_weight, pair_weights];
end

w = real(w);
w = w / sum(w);

%% 주파수 및 배열 조건 설정
f = 1e9;
c0 = 3e8;
lambda = c0 / f;
d = lambda / 2;
k = 2 * pi / lambda;


%% 사용자가 원하는 조향각 입력
scan_angle_deg = input('조향각을 입력해 주세요 = ');   % 원하는 scan angle을 degree 단위로 입력
scan_angle_rad = scan_angle_deg * pi / 180;            % 입력한 조향각을 radian 단위로 변환

% 관찰 각도 범위
theta_deg = -90:0.01:90;        
theta_rad = theta_deg * pi / 180;   

% 배열 소자 위치
element_position = ((0:N-1) - (N-1)/2) * d; 

% Array Factor 계산
AF = zeros(size(theta_rad));                  
for n = 1:N                                   
    AF = AF + w(n) * exp(1j * k * element_position(n) * sin(theta_rad));
end

%% 입력한 조향각을 적용한 Array Factor 계산
AF_scan = zeros(size(theta_rad));      % 조향된 빔의 Array Factor 값을 저장할 배열을 0으로 초기화

for n = 1:N                                          % N개의 배열 소자에 대해 반복
    AF_scan = AF_scan + w(n) * exp(1j * k * element_position(n) * ...
              (sin(theta_rad) - sin(scan_angle_rad)));     % element_position(n)은 n번째 소자의 위치
                                              % scan_angle_rad는 조향하고자 하는 각도를 의미함.
end

% 정규화 및 dB 변환
AF_mag = abs(AF);                        
AF_mag = AF_mag / max(AF_mag);
AF_dB = 20 * log10(AF_mag + 1e-12);


%% 조향각이 적용된 Beam Pattern 정규화 및 dB 변환
AF_scan_mag = abs(AF_scan);                        
AF_scan_mag = AF_scan_mag / max(AF_scan_mag);      
AF_scan_dB = 20 * log10(AF_scan_mag + 1e-12);    


figure;
plot(theta_deg, AF_dB); 
grid on;           

%% 기존 0도 빔과 입력한 조향각 빔을 하나의 그래프에 함께 출력
hold on;                                    % 기존 그래프 위에 조향된 Beam Pattern 추가
plot(theta_deg, AF_scan_dB);               % 사용자가 입력한 조향각이 적용된 빔패턴 출력
hold off;                                      % 그래프 추가 종료

xlabel('\theta [deg]');                     
ylabel('Normalized Array Factor [dB]');     
title('Chebyshev Beam Pattern');


legend('기존 Chebyshev Beam Pattern, Scan Angle = 0 deg', ...
       ['Chebyshev Beam Pattern, Scan Angle = ', num2str(scan_angle_deg), ' deg'], ...
       'Location', 'northeast');

xlim([-90 90]);
ylim([-80 5]);