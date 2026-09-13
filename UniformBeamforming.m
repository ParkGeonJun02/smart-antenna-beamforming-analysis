clear;
clc;
close all;

N = input('소자수 N 을 입력해 주세요 = ');

w = ones(1, N) / N;         % Uniform Beamforming 가중치 설정

d_over_lambda = 0.5;        % d : 거리, over : 나누기
                            % d/lambda = 0.5, 즉 소자 간격 d = lambda/2

% 관찰 각도 범위
theta_deg = -90:0.01:90;        % theta를 -90부터 90까지 0.01도 간격으로 
theta_rad = theta_deg * pi / 180;   % Array Factor 계산식에 radian 형태로 들어감.

% 배열 소자 위치
element_position = ((0:N-1) - (N-1)/2) * d_over_lambda;     % 배열 소자의 위치를 배열 중심 기준으로 설정
                                                            % 위치 단위는 lambda 기준

% Array Factor 계산
AF = zeros(size(theta_rad));                  % Array Factor 값을 저장할 배열인 AF를 0으로 초기화

for n = 1:N                                   % N을 1~10 반복
    AF = AF + w(n) * exp(1j * 2 * pi * element_position(n) * sin(theta_rad));
                                                        % n번째 배열 소자가 각 방향
                                                        % theta에 대해 만드는 신호 성분을 더하는 식
                                                        % w(n)은 n번째 소자의 Chebyshev 가중치
                                                        % 양끝 소자: 작은 가중치, 중앙 소자: 큰 가중치
end

% 정규화 및 dB 변환
AF_mag = abs(AF);                       % Array Factor의 크기
AF_mag = AF_mag / max(AF_mag);          % Beam pattern 정규화
                                        % (AF_mag 전체 값 중 가장 큰 값으로 나누기 때문에, 가장 큰 값이 1)
AF_dB = 20 * log10(AF_mag + 1e-12);     % 정규화된 빔패턴 크기를 dB 단위로 바꿈

% Beam Pattern 출력
figure;
plot(theta_deg, AF_dB); % x축 : 각도. y축 : dB scale beampattern value
grid on;            % 격자선 그리기

xlabel('\theta [deg]');                     % x축 : 각도
ylabel('Normalized Array Factor [dB]');     % y축 : dB scale beampattern value
title('Uniform Beam Pattern');
legend('Uniform Beam Pattern', 'Location', 'northeast');

xlim([-90 90]);
ylim([-80 5]);