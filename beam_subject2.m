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


f = 1e9;
c0 = 3e8;
lambda = c0 / f;
d = lambda / 2;
k = 2 * pi / lambda;

% scan angle 범위 설정
scan_angle = -60:10:60;                 %-60도부터 +60도까지 10도 간격으로 

% 관찰 각도 범위
theta_deg = -90:0.01:90;        
theta_rad = theta_deg * pi / 180;   

% 배열 소자 위치
element_position = ((0:N-1) - (N-1)/2) * d; 

%% Monopulse 계산을 위한 Beam Pattern 저장 배열
AF_all = zeros(length(scan_angle), length(theta_deg));
				% 각 scan angle의 선형 Beam Pattern 값을 저장


for s = 1:length(scan_angle)                        
    scan_angle_deg = scan_angle(s);                 
    scan_angle_rad = scan_angle_deg * pi / 180;     
    % Array Factor 계산
    AF = zeros(size(theta_rad));                  

    for n = 1:N                                  
        AF = AF + w(n) * exp(1j * k * element_position(n) * ...
             (sin(theta_rad) - sin(scan_angle_rad)));
    end

    AF_mag = abs(AF);                       
    AF_mag = AF_mag / max(AF_mag);          
    AF_all(s, :) = AF_mag;                  % Monopulse 계산을 위해 dB가 아닌 선형 크기값 저장
end


%% 10도 간격 Monopulse 특성 계산
figure;                                             % Monopulse 특성 그래프 출력
hold on;                                 % 여러 구간의 Monopulse 특성을 한 그래프에 겹쳐 그림

legend_text_mono = strings(1, length(scan_angle)-1);    % Monopulse 범례 문자열 저장

for s = 1:length(scan_angle)-1                       % 인접한 두 scan angle 빔을 하나씩 선택

    y_i = AF_all(s, :);                              % 현재 scan angle의 빔 출력
    y_next = AF_all(s+1, :);                         % 다음 scan angle의 빔 출력
    monopulse_ratio = (y_next - y_i) ./ (y_next + y_i + 1e-12);
                                       %  y_i+1 - y_i 순서로 차채널 계산
                                        % 분모가 0에 가까워지는 것을 방지하기 위해 1e-12 추가
    angle_index = theta_deg >= scan_angle(s) & theta_deg <= scan_angle(s+1);
                                                  % 현재 인접 빔 사이의 10도 각도 구간만 선택
    plot(theta_deg(angle_index), monopulse_ratio(angle_index));
                                                   % 선택된 10도 구간의 Monopulse Ratio 출력
    legend_text_mono(s) = num2str(scan_angle(s)) + " deg ~ " + ...
                          num2str(scan_angle(s+1)) + " deg";
end

hold off;
grid on;

xlabel('\theta [deg]');
ylabel('Monopulse Ratio');
title('Monopulse Characteristic');
legend(legend_text_mono, 'Location', 'northeast');

xlim([-60 60]);
ylim([-1.2 1.2]); 

%% Scan angle 위치에 따른 Monopulse 기울기 비교
figure;
hold on;

compare_index = [1, 7, 12];
% 1  : -60 deg ~ -50 deg
% 7  : 0 deg ~ 10 deg
% 12 : 50 deg ~ 60 deg

legend_text_slope = strings(1, length(compare_index));

for idx = 1:length(compare_index)

    s = compare_index(idx);

    y_i = AF_all(s, :);
    y_next = AF_all(s+1, :);

    monopulse_ratio = (y_next - y_i) ./ (y_next + y_i + 1e-12);

    angle_index = theta_deg >= scan_angle(s) & theta_deg <= scan_angle(s+1);

    relative_theta = theta_deg(angle_index) - scan_angle(s);
    % 각 구간의 시작점을 0도로 맞추기 위한 상대각도

    plot(relative_theta, monopulse_ratio(angle_index), 'LineWidth', 1.5);

    legend_text_slope(idx) = num2str(scan_angle(s)) + " deg ~ " + ...
                             num2str(scan_angle(s+1)) + " deg";
end

hold off;
grid on;

xlabel('Relative Angle [deg]');
ylabel('Monopulse Ratio');
title('Scan Angle Position에 따른 Monopulse 기울기 비교');

legend(legend_text_slope, 'Location', 'northeast');

xlim([0 10]);
ylim([-1.2 1.2]);