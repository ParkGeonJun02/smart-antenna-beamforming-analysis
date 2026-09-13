# Smart Antenna Beamforming Analysis

MATLAB을 활용해 선형 배열 안테나의 빔패턴 형성, 빔 조향, 비등간격 배열 보상을 분석한 스마트안테나 교과 프로젝트입니다.

## Project Scope

- 15소자 ULA(Uniform Linear Array)를 대상으로 Chebyshev 가중치를 적용했습니다.
- 주엽 최대값을 기준으로 정규화한 빔패턴과 부엽 수준을 확인했습니다.
- -60°부터 +60°까지 10° 간격으로 빔 조향 결과를 비교했습니다.
- 소자 간격이 0.2λ에서 0.7λ 범위에서 달라지는 비등간격 배열을 생성했습니다.
- 기준 등간격 배열의 빔패턴을 목표값으로 두고, Least Squares 방식으로 비등간격 배열의 가중치를 계산해 보상 결과를 비교했습니다.
- 인접 조향 빔의 Monopulse Ratio와 각도에 따른 기울기를 확인했습니다.

## Implementation

| File | Description |
| --- | --- |
| `beam_subject0.m` | Chebyshev 빔패턴 생성과 단일 조향각 비교 |
| `beam_subject1.m` | -60°부터 +60°까지 10° 간격 빔 조향 |
| `beam_subject2.m` | 인접 조향 빔 기반 Monopulse Ratio 및 기울기 비교 |
| `UniformBeamforming.m` | 균일 가중치 기반 ULA 빔패턴 생성 |
| `pdf_SM_1.m` | 균일 가중치 빔패턴 기초 구현 |
| `pdf_SM_2.m` | Chebyshev 가중치 계산 |
| `pdf_SM_3.m` | Chebyshev 가중치 기반 빔패턴 생성 |

## Analysis Flow

1. 15소자, 반파장 간격의 기준 ULA에서 Chebyshev 가중치를 계산했습니다.
2. Array Factor를 정규화하고 dB 단위 빔패턴으로 변환해 기준 패턴을 확인했습니다.
3. 위상 보상을 적용해 조향각에 따른 빔의 이동을 비교했습니다.
4. 비등간격 배열의 steering matrix를 구성한 뒤, 기준 패턴과의 오차 제곱합이 작아지도록 Least Squares 가중치를 계산했습니다.
5. 기준 패턴과 보상 후 패턴을 동일한 각도 범위와 축에서 비교했습니다.

## Notes

- 본 저장소는 스마트안테나 교과 과제에서 수행한 배열 신호처리 분석 코드입니다.
- 시뮬레이션 결과는 배열 조건과 난수로 생성되는 소자 간격에 따라 달라질 수 있습니다.
- MATLAB 환경에서 각 스크립트를 개별 실행할 수 있습니다. 일부 스크립트는 소자 수, 부엽 수준 또는 조향각 입력을 요구합니다.

## Skills Used

`MATLAB` `Array Factor` `Chebyshev Beamforming` `Beam Steering` `Least Squares` `Monopulse Analysis`
