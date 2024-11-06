import pandas as pd
import chardet
import glob
import os

# CSV 파일들이 있는 폴더 경로와 변환된 파일을 저장할 경로 설정
input_path = "seoul_hc_original/*.csv"
output_path = "result/seoul_hc_licensing_info.csv"  # 변환된 파일을 저장할 경로

# 모든 CSV 파일을 불러오기
all_files = glob.glob(input_path)

# 합쳐진 DataFrame을 저장할 리스트
combined_data = []

for file in all_files:
    # 파일의 인코딩 감지
    with open(file, 'rb') as f:
        result = chardet.detect(f.read())
        encoding = result['encoding']
    
    # 감지된 인코딩으로 파일을 읽고 UTF-8로 저장
    try:
        df = pd.read_csv(file, encoding=encoding)  # 감지된 인코딩으로 파일 읽기
        
        # 파일 이름에서 두 번째와 세 번째 단어 추출
        file_name = os.path.basename(file)
        file_name_parts = file_name.split()
        
        # 두 번째 단어는 district로 설정
        district = file_name_parts[1] if len(file_name_parts) > 1 else ''
        
        # 세 번째 단어를 이용해 facility_level을 결정
        facility_level = 'C' if '의원' in file_name_parts[2] else 'H' if '병원' in file_name_parts[2] else ''
        
        # district와 facility_level 컬럼 추가
        df['district'] = district
        df['facility_level'] = facility_level
        
        # 데이터 프레임을 리스트에 추가
        combined_data.append(df)

    
    except Exception as e:
        print(f"{file} 파일을 처리하는 중 오류 발생: {e}")

# 모든 파일을 하나로 합침
if combined_data:
    final_df = pd.concat(combined_data, ignore_index=True)
    # 최종 파일 저장
    final_output_file = output_path
    final_df.to_csv(final_output_file, index=False, encoding='utf-8')
    print(f"모든 파일이 성공적으로 합쳐져 {final_output_file}로 저장되었습니다.")
