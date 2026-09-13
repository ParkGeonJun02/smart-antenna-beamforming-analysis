clear;
clc;
close all;
N = input('소자수 N 을 입력해 주세요 = ');
SLL = input('원하는 부엽수준을 입력해 주세요 = ');
% Chebyshev 가중치 계산
R = 10^(SLL / 20); 
beta = cosh(acosh(R) / (N - 1)); % Chebyshev 다항식에 사용할 스케일링 계수 beta를 계산
sample_num = 10000; % 계산에 사용할 샘플 개수
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
 % Chebyshev 목표 패턴의 분자 부분을 계산
target = target / calculate_chebyshev_value(N - 1, beta); % 목표 패턴을 정규화
if mod(N, 2) == 0 % N이 짝수이면
 M = N / 2; 
 A = zeros(sample_num, M); 
 for m = 1:M %A(:,1) = 2 cos(0.5 ψ)과 같이 M을 순차적 반복
 A(:, m) = 2 * cos((m - 0.5) * psi); end
 coefficient = A \ target; 
 pair_weights = coefficient.'; 
 w = [fliplr(pair_weights), pair_weights]; 
else % N이 홀수이면
 M = (N - 1) / 2; A = zeros(sample_num, M + 1);  A(:, 1) = 1; 
 for m = 1:M
 A(:, m + 1) = 2 * cos(m * psi); end
 coefficient = A \ target; center_weight = coefficient(1); 
 pair_weights = coefficient(2:end).'; 
 w = [fliplr(pair_weights), center_weight, pair_weights];
end
w = real(w); 
w = w / sum(w); 
% 가중치 출력
fprintf('Chebyshev 정규화 가중치:\n'); 
for n = 1:N
 fprintf('w(%2d) = %.10f\n', n, w(n));
end