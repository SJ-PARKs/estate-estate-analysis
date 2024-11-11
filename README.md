# 서울시 아파트 평단가와 인프라의 상관관계 분석

## 📝 프로젝트 개요
서울시 자치구별 아파트 매매가에 영향을 미치는 요소를 파악하기 위해 교통, 문화, 의료 등 다양한 생활 인프라 데이터를 분석했습니다. Python의 `pandas`를 활용해 상관계수를 계산했으며, 이를 통해 아파트 평단가와 인프라 요소 간의 관계를 확인했습니다.

상관계수 해석:
- **0.0~0.1**: 거의 없음
- **0.1~0.3**: 약한 상관관계
- **0.3~0.7**: 중간 정도의 상관관계
- **0.7~1.0**: 강한 상관관계

## 📊 상관계수 분석 결과
| 인프라 요소       | 상관계수 |
|------------------|----------|
| 인구             | 0.1419   |
| 물가             | 0.0503   |
| 병원             | 0.635    |
| 문화시설         | 0.4499   |
| 영화관           | 0.5096   |
| 도서관           | 0.3532   |
| 공연장           | 0.4168   |
| 박물관/기념관    | 0.1395   |
| 미술관/갤러리    | 0.2942   |
| 문화예술회관     | -0.0755  |
| 문화원           | 0.2236   |
| 기타 문화시설     | 0.3121   |
| 지하철 역사 수   | 0.4354   |
| 환승역 수        | 0.331    |

## 📈 프로젝트 시각화 결과

### 1. 병원수 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/29187822-aee1-499b-9bbc-5cc30071bd26" width="400px">
  <img src="https://github.com/user-attachments/assets/f30b17c8-f3bd-4b1c-8ded-73adb8ab3a56" width="400px">
</div>

### 2. 지하철 역사 수 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/afbb1a1c-6bbc-4308-9af5-18531d26951f" width="400px">
  <img src="https://github.com/user-attachments/assets/5a8af561-2484-4bbc-a261-11d23e87af3c" width="400px">
</div>

### 3. 인구 수 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/140ef498-b2b7-4661-a599-45a178c65cd6" width="400px">
</div>

### 4. 문화시설 수 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/e1a1158a-2a2c-455b-9ab3-ecbb5744118e" width="400px">
  <img src="https://github.com/user-attachments/assets/c54c3c57-f3f6-477c-816b-a407f3b84996" width="400px">
  <img src="https://github.com/user-attachments/assets/0cc47cf6-6a2d-4e3d-8f33-09b857782e77" width="400px">
</div>

### 5. 버스 노선 개수 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/734a819b-227b-4f51-977c-91b7ea6c09ee" width="400px">
  <img src="https://github.com/user-attachments/assets/6abecb0d-5b50-483c-9182-dbc4849c791b" width="400px">
</div>

### 6. 생필품 물가 - 아파트 평단가
<div align="center">
  <img src="https://github.com/user-attachments/assets/7246413c-be3f-4335-aa38-a39ad2ba6700" width="800px">
</div>

## ⚙️ 데이터 파이프라인
<div align="center">
  <img src="https://github.com/user-attachments/assets/c8916e21-2afa-4f5e-9997-e55e198573e4" width="800px">
</div>

---
