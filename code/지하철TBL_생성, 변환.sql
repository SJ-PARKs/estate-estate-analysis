
-- METRO ODS TABLE
CREATE TABLE metro_raw (
	station_id varchar(10),
	station_name varchar(20) NULL,
	line_id varchar(10) NULL,
	line_name varchar(20) NULL,
	station_name_eng varchar(100) NULL,
	transfer_type varchar(20) NULL,
	transfer_line_id varchar(100) NULL,
	transfer_line_name varchar(100) NULL,
	x_latitude numeric(12,8) NULL,
	y_longitude numeric(12,8) NULL,
	operating_agency varchar(50) NULL,
	road_address varchar(100) NULL,
	tel varchar(50) NULL,
	ref_date date NULL
);

-- METRO 전처리 TABLE
CREATE TABLE METRO
AS
SELECT STATION_ID
     , CASE WHEN station_name NOT IN('서울역','동대문역사문화공원(DDP)','삼성(무역센터)','역삼', '역촌', '암사역사공원', '서울역(경의선)')
            THEN REPLACE(station_name, '역', '')
            ELSE STATION_NAME END STATION_NAME
     , LINE_ID
     , CASE WHEN LINE_NAME ='수도권  도시철도 9호선' THEN '9호선'
            WHEN LINE_NAME ='수도권 경량도시철도 신림선' THEN '신림선'
            ELSE LINE_NAME END LINE_NAME
     , STATION_NAME_ENG
     , TRANSFER_TYPE
     , TRANSFER_LINE_ID
     , TRANSFER_LINE_NAME
     , X_LATITUDE
     , Y_LONGITUDE
     , operating_agency
     , ROAD_ADDRESS
     , SPLIT_PART(ROAD_ADDRESS, ' ', 2) AS DISTRICT
     , TEL
     , REF_DATE
  FROM metro_raw;

-- METRO PK 설정, station_id, line_id
ALTER TABLE METRO
ADD CONSTRAINT pk_metro PRIMARY KEY (station_id, line_id);



-- 아래는 전처리 과정

-- 위경도 테이블 추가: 서울시_역사마스터_정보


SELECT *
  FROM METRO
  LEFT OUTER JOIN 서울시_역사마스터_정보 서역정
    ON METRO.station_name = 서역정.역사명; 
   
SELECT * FROM METRO WHERE station_name = '홍대입구';
SELECT * FROM 서울시_역사마스터_정보 WHERE 역사명 = '홍대입구';   



SELECT DISTINCT line_name FROM metro
EXCEPT
SELECT DISTINCT 호선 FROM 서울시_역사마스터_정보;  -- metro에만 있는 호선명: 인천국제공항선


SELECT DISTINCT 호선 FROM 서울시_역사마스터_정보
EXCEPT
SELECT DISTINCT line_name FROM metro
order BY 1;
/*
-- 역사마스터에만 있는 호선명
7호선(인천)	--7호선
9호선(연장)	--9호선
경강선		--
공항철도1호선	--인천국제공항선
과천선
별내선
수도권 광역급행철도
수인선
신분당선(연장)
신분당선(연장2)
안산선
에버라인선
의정부선
인천1호선
인천2호선
일산선
장항선
중앙선
진접선
*/

SELECT * FROM 서울시_역사마스터_정보
WHERE 호선 IN ('7호선(인천)','9호선(연장)','경강선','공항철도1호선','과천선','별내선','수도권 광역급행철도','수인선','신분당선(연장)'
,'신분당선(연장2)','안산선','에버라인선','의정부선','인천1호선','인천2호선','일산선','장항선','중앙선','진접선');


-- 데이터 보정
-- 역사마스터에만 존재하는 역사 삭제 (서울 이외 데이터임)
DELETE FROM 서울시_역사마스터_정보;
WHERE 역사명 IN( SELECT DISTINCT 역사명 FROM 서울시_역사마스터_정보
EXCEPT
SELECT DISTINCT station_name FROM metro);


-- 삭제 후에도 역사마스터에만 있는 호선 조회
SELECT DISTINCT 호선 FROM 서울시_역사마스터_정보
EXCEPT
SELECT DISTINCT line_name FROM metro
order BY 1;

-- 삭제 후에도 역사마스터에만 있는 호선 조회
SELECT * FROM 서울시_역사마스터_정보
WHERE 호선 IN ('9호선(연장)','공항철도1호선','수도권 광역급행철도','신분당선(연장2)','중앙선');

-- 역사마스터에만 있는 호선의 역명을 metro에서 조회
-- 역사명은 같으나 metro에서는 다른 호선으로 조회됨
SELECT station_name, line_name
  FROM metro
 WHERE station_name IN (SELECT 역사명
						  FROM 서울시_역사마스터_정보
						 WHERE 호선 IN ('9호선(연장)','공항철도1호선','수도권 광역급행철도','신분당선(연장2)','중앙선'));

-- 역사명은 같으나 호선명이 다른 경우 출력
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE station_name IN (SELECT 역사명
						  FROM 서울시_역사마스터_정보
						 WHERE 호선 IN ('9호선(연장)','공항철도1호선','수도권 광역급행철도','신분당선(연장2)','중앙선'))
  AND 호선 IN ('9호선(연장)','공항철도1호선','수도권 광역급행철도','신분당선(연장2)','중앙선')
 ORDER BY LINE_NAME;
 
 
 
-- 9호선 노선 중 역사마스터에는 호선이 9호선(연장)으로 기입된 경우
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE station_name IN (SELECT 역사명
						  FROM 서울시_역사마스터_정보
						 WHERE 호선 IN ('9호선(연장)','공항철도1호선','수도권 광역급행철도','신분당선(연장2)','중앙선'))
  AND line_name = '9호선'
  AND 호선 ='9호선(연장)';

 -- 위와 동일
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE line_name = '9호선'
  AND 호선 ='9호선(연장)' ;
 
-- 데이터 보정
-- 9호선 노선 중 역사마스터에는 호선이 9호선(연장)으로 기입된 경우
-- 역사마스터의 호선명을 9호선(연장) -> 9호선 으로 변경
UPDATE 서울시_역사마스터_정보;
   SET 호선 = '9호선'
  FROM metro
 WHERE 서울시_역사마스터_정보.역사명 = metro.station_name
   AND 서울시_역사마스터_정보.호선 = '9호선(연장)'
   AND metro.line_name = '9호선';

-- 신분당선 노선 중 역사마스터에는 호선이 신분당선(연장2)으로 기입된 경우  
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE line_name = '신분당선'
  AND 호선 ='신분당선(연장2)' ;
 
-- 데이터 보정
-- 신분당선 노선 중 역사마스터에는 호선이 신분당선(연장2)으로 기입된 경우
-- 역사마스터의 호선명을 신분당선(연장2) -> 신분당선 으로 변경
UPDATE 서울시_역사마스터_정보;
   SET 호선 = '신분당선'
  FROM metro
 WHERE 서울시_역사마스터_정보.역사명 = metro.station_name
   AND 서울시_역사마스터_정보.호선 = '신분당선(연장2)'
   AND metro.line_name = '신분당선'; 

-- 인천국제공항선 노선 중 역사마스터에는 호선이 공항철도1호선으로 기입된 경우  
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE line_name = '인천국제공항선'
  AND 호선 ='공항철도1호선' ;
 
-- 데이터 보정
-- 인천국제공항선 노선 중 역사마스터에는 호선이 공항철도1호선으로 기입된 경우
-- 역사마스터의 호선명을 공항철도1호선 -> 인천국제공항선 으로 변경
UPDATE 서울시_역사마스터_정보
   SET 호선 = '인천국제공항선'
  FROM metro
 WHERE 서울시_역사마스터_정보.역사명 = metro.station_name
   AND 서울시_역사마스터_정보.호선 = '공항철도1호선'
   AND metro.line_name = '인천국제공항선';
  
-- 경의 용산 경원 중앙 -> 경의중앙선으로 통합 필요

  
-- 데이터 보정
-- 경의중앙선 노선 중 역사마스터에는 호선이 중앙선으로 기입된 경우
-- 역사마스터의 호선명을 중앙선 -> 경의중앙선으로 변경
UPDATE 서울시_역사마스터_정보;
   SET 호선 = '경의중앙선'
  FROM metro
 WHERE 서울시_역사마스터_정보.역사명 = metro.station_name
   AND 서울시_역사마스터_정보.호선 = '중앙선'
   AND metro.line_name = '경의중앙선';
  
 /*
서울역	1호선			서울역	공항철도1호선
서울역	4호선			서울역	공항철도1호선
양평		5호선			양평		중앙선
연신내	3호선			연신내	수도권 광역급행철도
연신내	6호선			연신내	수도권 광역급행철도
수서		3호선			수서		수도권 광역급행철도
수서		분당선		수서		수도권 광역급행철도
서울		인천국제공항선	서울		수도권 광역급행철도 

  * 양평역의 경우 5호선, 중앙선 각각 존재하며 METRO에 중앙선 양평역 추가 필요. 이름만 같고 다른 역임.
  * METRO에 STATION_NAME이 서울인 레코드를 서울역으로 수정 필요
  * 수도권 광역급행철도 노선은 METRO에 레코드 추가 필요
  *   */
  
  
SELECT STATION_NAME, LINE_NAME
  FROM METRO
 WHERE STATION_NAME = '서울역';
  
SELECT *
  FROM 서울시_역사마스터_정보
 WHERE 역사명 = '서울역';

-- METRO에 STATION_NAME이 서울인 레코드를 서울역으로 수정
UPDATE METRO
   SET STATION_NAME = '서울역'
 WHERE STATION_NAME = '서울';
 
-- 서울역에 경우 METRO TBL에 2개의 노선만 있으며, 역사마스터에는 6개가 존재하므로 기준 테이블인 METRO에 레코드 추가 필요
-- 공항철도1호선(인천국제공항선), 경부선의 경우는 누락으로 보이며, 경의중앙선도 누락이긴 하나 역사마스터에 역사_ID가 다른 레코드가 2개 존재힘??


/*
 *
양평		5호선		양평		중앙선
연신내	3호선		연신내	수도권 광역급행철도
연신내	6호선		연신내	수도권 광역급행철도
수서		3호선		수서		수도권 광역급행철도
수서		분당선	수서		수도권 광역급행철도
 */

-- 중앙선 호선 이름 보정
UPDATE 서울시_역사마스터_정보
   SET 호선 = '경의중앙선'
 WHERE 호선 = '중앙선';

 
SELECT station_name, line_name, 역사명, 호선
  FROM metro
  LEFT OUTER JOIN 서울시_역사마스터_정보
    ON metro.station_name = 서울시_역사마스터_정보.역사명
 WHERE 
;
 
SELECT station_name, line_name
  FROM metro
 WHERE STATION_NAME IN ('연신내', '수서')
 ORDER BY 1;
 

SELECT 역사명, 호선
  FROM 서울시_역사마스터_정보
 WHERE 역사명 IN ('연신내', '수서')
 ORDER BY 1;

/* 최종적으로 아래의 레코드는 누락으로 판단되어 METRO TBL에 직접 추가 필요
 * 연신내		수도권 광역급행철도
 * 수서		수도권 광역급행철도
 * 양평		중앙선
 */

SELECT COUNT(*) FROM metro;		-- 405
SELECT COUNT(*) FROM 서울시_역사마스터_정보;	-- 395

SELECT STATION_NAME, LINE_NAME
FROM metro
GROUP BY STATION_NAME, LINE_NAME;
-- METRO의 신림선 샛강 레코드 중복으로 확인
-- 고유한 레코드 수 404개

SELECT 역사명, 호선
FROM 서울시_역사마스터_정보
GROUP BY 역사명, 호선;
-- 서울시_역사마스터_정보의 경의중앙선 홍대입구, 서울역, 공덕, 디지털미디어시티 및 5호선 강일 중복으로 파악됨.
-- 역사가 2개 이상인 경우가 있는지 생각해볼 것... 되나?
-- 고유한 레코드 수 390개



SELECT DISTINCT STATION_NAME FROM METRO
EXCEPT
SELECT DISTINCT 역사명 FROM 서울시_역사마스터_정보;
/*
-- 아래는 역사마스터에 없으나 METRO에만 존재하는 역사 이름임
이촌
낙성대(강감찬)
용마산(용마폭포공원)
자양(뚝섬한강공원)
신촌(지하)
동대문역사문화공원(DDP)
상봉
교대(법원·검찰청)
성신여대입구
종로3가(탑골공원)
관악산
서울역(경의선)
온수
왕십리
청량리 
*/

-- 이름 비교...
SELECT *
  FROM 서울시_역사마스터_정보
 WHERE 역사명 LIKE '%신촌%';

/*
* METRO TBL							* 서울시_역사마스터_정보 TBL
이촌									이촌(국립중앙박물관)		경원선, 4호선
낙성대(강감찬)							-
용마산(용마폭포공원)						-
자양(뚝섬한강공원)						-
신촌(지하)								신촌 					경의중앙선, 2호선
동대문역사문화공원(DDP)					-
상봉									-
교대(법원·검찰청)						-
성신여대입구							성신여대입구(돈암)		우이신설선, 4호선
종로3가(탑골공원)						종로3가				1호선, 3호선, 5호선
관악산								-
서울역(경의선)							서울역				인천국제공항선, 경의중앙선, 경부선, 1호선, 4호선
온수									온수(성공회대입구)		7호선, 경인선
왕십리								왕십리(성동구청)			2호선, 5호선, 경원선
청량리 								청량리(서울시립대입구)		1호선, 경원선
*/

SELECT *
  FROM METRO
 WHERE STATION_NAME LIKE '%청량리%';
-- METRO TBL 내에서 역 이름이 표준화되지 않은 경우
/*
이촌					이촌(국립중앙박물관)
신촌					신촌(지하)			-- 추가 확인 필요
성신여대입구			성신여대입구(돈암)
종로3가				종로3가(탑골공원)
서울역				서울역(경의선)		-- 추가 확인 필요 -> 서울역(경의선)을 서울역으로 변경
온수					온수(성공회대입구)
왕십리				왕십리(성동구청)
청량리				청량리(서울시립대입구)
*/

-- 표준화를 위해 역사마스터가 아닌 METRO TBL의 역 이름을 변경하기로 함
-- 역사 영문명은 변경하지 않았으므로 추후 클렌징
UPDATE METRO
   SET station_name = '신촌'
 WHERE station_name = '신촌(지하)';


-- 보저ㅇ 이후 재확인
SELECT DISTINCT STATION_NAME FROM METRO
EXCEPT
SELECT DISTINCT 역사명 FROM 서울시_역사마스터_정보;
/*
-- 아래는 역사마스터에 없으나 METRO에만 존재하는 역사 이름임
낙성대(강감찬)
용마산(용마폭포공원)
자양(뚝섬한강공원)
신촌(지하)
동대문역사문화공원(DDP)
상봉
교대(법원·검찰청)
관악산
*/


SELECT STATION_NAME, LINE_NAME
  FROM metro m 
 WHERE station_name LIKE '%신촌%';
 
SELECT 역사명, 호선
  FROM 서울시_역사마스터_정보 서역정 
 WHERE 역사명 LIKE '%신촌%';


SELECT DISTINCT 역사명 FROM 서울시_역사마스터_정보
EXCEPT
SELECT DISTINCT STATION_NAME FROM METRO;


UPDATE 서울시_역사마스터_정보
SET 역사명 = '서울역'
WHERE 역사명 = '서울';


SELECT STATION_NAME, LINE_NAME
  FROM metro m 
 WHERE station_name_eng LIKE 'Seoul';


SELECT STATION_NAME, line_name FROM METRO GROUP BY STATION_NAME, line_name
EXCEPT
SELECT 역사명, 호선 FROM 서울시_역사마스터_정보 GROUP BY 역사명, 호선
ORDER BY 1;


-- 9호선이 신림선으로 잘못 바뀌어있음... metro tbl create할 때 코드를 잘못 작성함...
SELECT * FROM metro WHERE line_name = '신림선';
-- 9호선의 line_id = 'S1109'인 것으로 확인됨.
UPDATE METRO
   SET LINE_NAME = '9호선'
 WHERE LINE_ID = 'S1109';


SELECT * FROM metro WHERE line_name = '신림선';


SELECT DISTINCT LINE_NAME FROM METRO
EXCEPT
SELECT DISTINCT 호선 FROM 서울시_역사마스터_정보 서역정 ;


SELECT DISTINCT 호선 FROM 서울시_역사마스터_정보 서역정
EXCEPT
SELECT DISTINCT LINE_NAME FROM METRO;


/* 305 LINE 참고
 * 최종적으로 아래의 레코드는 누락으로 판단되어 METRO TBL에 직접 추가 필요
 * 연신내		수도권 광역급행철도
 * 수서		수도권 광역급행철도
 * 양평		경의중앙선			-> 수도권이 아니므로 제외
 */

SELECT * FROM METRO WHERE STATION_NAME = '연신내';

INSERT INTO public.metro
(station_id, station_name, line_id, line_name, station_name_eng, transfer_type, transfer_line_id, transfer_line_name, latitude, longitude, operating_agency, road_address, district, tel, ref_date)
VALUES('', '연신내', '', '수도권 광역급행철도', 'Yeonsinnae', '도시철도 환승역', 'S1106+I1103', '수도권  도시철도 6호선, 수도권  광역철도 3호선', 0, 0, '', '서울특별시 은평구 통일로 지하849(갈현동)', '은평구', '', NOW());

SELECT * FROM METRO WHERE STATION_NAME = '수서';

INSERT INTO public.metro
(station_id, station_name, line_id, line_name, station_name_eng, transfer_type, transfer_line_id, transfer_line_name, latitude, longitude, operating_agency, road_address, district, tel, ref_date)
VALUES('tmp', '수서', 'tmp', '수도권 광역급행철도', 'Suseo', '환승역', 'I41K1+S2603', '수도권  광역철도 분당, 3호선', 0, 0, '', '서울시 강남구 광평로 지하 270(수서동)', '강남구', '', NOW());


SELECT * FROM 서울시_역사마스터_정보 서역정 WHERE 역사명 = '양평';
DELETE FROM 서울시_역사마스터_정보 WHERE 역사명 = '양평' AND 호선 = '경의중앙선';



--역사명, 호선 기준 차집합 전부 해결...

SELECT * FROM METRO;	-- 407
SELECT * FROM 서울시_역사마스터_정보;	-- 394

SELECT STATION_NAME, LINE_NAME
  FROM METRO
 GROUP BY STATION_NAME, LINE_NAME;	-- 407
 
SELECT 역사명, 호선
  FROM 서울시_역사마스터_정보
 GROUP BY 역사명, 호선;		--389
 
 SELECT 역사명, 호선
  FROM 서울시_역사마스터_정보
 GROUP BY 역사명, 호선
 HAVING COUNT(*)>1;	
 /* 역사가 2개씩 있는 애들...
홍대입구	경의중앙선
서울역	경의중앙선
강일		5호선
공덕		경의중앙선
디지털미디어시티	경의중앙선
*/


SELECT *
  FROM 서울시_역사마스터_정보
 WHERE (역사명, 호선) IN (SELECT 역사명, 호선
						 FROM 서울시_역사마스터_정보
						GROUP BY 역사명, 호선
					   HAVING COUNT(*)>1)
 ORDER BY 2;
 /* 위경도 값이 동일하므로 임의로 하나씩 삭제. -> 역사_ID에서 식별의 역할을 제외하면 의미상 필요한 컬럼이 아님
9995	강일	5호선	37.55749	127.17593
2562	강일	5호선	37.55749	127.17593
1262	공덕	경의중앙선	37.542595	126.9521
1292	공덕	경의중앙선	37.542595	126.9521
1266	디지털미디어시티	경의중앙선	37.577477	126.90045
1294	디지털미디어시티	경의중앙선	37.577477	126.90045
1251	서울역	경의중앙선	37.55723	126.97103
1291	서울역	경의중앙선	37.55723	126.97103
1264	홍대입구	경의중앙선	37.55764	126.92668
1293	홍대입구	경의중앙선	37.55764	126.92668
*/


DELETE FROM 서울시_역사마스터_정보
 WHERE 역사_id IN (9995, 1292, 1294, 1291, 1293); -- 5개 레코드 삭제
 
 
SELECT * FROM METRO;	-- 407
SELECT * FROM 서울시_역사마스터_정보;	-- 389 
 
SELECT *
  FROM metro m
  LEFT OUTER JOIN 서울시_역사마스터_정보 i
    ON m.station_name = i.역사명
   AND m.line_name = i.호선;
--> LEFT 조인 시 기준 TBL인 METRO의 행(407개)만큼만 조회되므로 조인 조건 만족
 
 
SELECT station_name, line_name
  FROM metro m
  LEFT OUTER JOIN 서울시_역사마스터_정보 i
    ON m.station_name = i.역사명
   AND m.line_name = i.호선
 WHERE m.latitude IS NULL and i.위도 IS Null;  -- 10개 레코드 위경도 수기 입력 필요.
 
 
SELECT DISTINCT station_name FROM metro;  -- 307개 역


SELECT TRANSFER_TYPE
  FROM METRO
 WHERE STATION_NAME = '상봉';
 

SELECT latitude, longitude
  FROM METRO
 WHERE STATION_NAME = '교대(법원·검찰청)';
 
UPDATE metro
  SET latitude = 37.531552, longitude = 127.066708
WHERE STATION_NAME = '자양(뚝섬한강공원)' AND latitude IS NULL AND longitude IS NULL;

/*
교대 - 37.493811, 127.014057
동역사 - 37.565683, 127.008946
총신대입구 - 37.486948, 126.982209
낙성대 - 37.478002, 126.963375
용마산 - 37.573659, 127.086736
자양 - 37.531552, 127.066708
*/



SELECT station_name, line_name
  FROM metro m
  LEFT OUTER JOIN 서울시_역사마스터_정보 i
    ON m.station_name = i.역사명
   AND m.line_name = i.호선
 WHERE (latitude IS NOT NULL AND longitude IS NOT NULL)
    OR (i.위도 IS NOT NULL AND i.경도 IS NOT NULL);
   
   
SELECT * FROM METRO;


-- 지하철 역사 위경도가 포함된 지하철 테이블
CREATE TABLE METRO_XY
    AS
SELECT DISTRICT
	 , STATION_NAME
	 , LINE_NAME
	 , TRANSFER_TYPE
	 , TRANSFER_LINE_ID
	 , TRANSFER_LINE_NAME
	 , CASE WHEN LATITUDE IS NULL OR LATITUDE = 0 THEN ST.위도 ELSE LATITUDE END LATITUDE
	 , CASE WHEN LONGITUDE IS NULL OR LONGITUDE = 0 THEN ST.경도 ELSE LONGITUDE END LONGITUDE
	 , ROAD_ADDRESS
  FROM METRO M
  LEFT OUTER JOIN 서울시_역사마스터_정보 ST
    ON M.STATION_NAME = ST.역사명
   AND M.LINE_NAME = ST.호선;

  
-- METRO_XY의 PK는 STATION_NAME, LINE_NAME
SELECT STATION_NAME, LINE_NAME
  FROM METRO_XY
 GROUP BY STATION_NAME, LINE_NAME;
	 
ALTER TABLE METRO_XY
ADD CONSTRAINT pk_metro_xy PRIMARY KEY (STATION_NAME, LINE_NAME); 
	 
	 
-- 데이터 보정


SELECT * FROM metro_xy WHERE floor(longitude) = 129;
	 
-- 양원역 37.606647, 127.108068

UPDATE ANALYTICS.METRO_XY
   SET LATITUDE=37.606647, LONGITUDE=127.108068
 WHERE STATION_NAME = '양원'
   AND LINE_NAME = '경의중앙선';


-- 자치구별 위경도 테이블 생성
CREATE TABLE raw_data.seoul_districts_xy (
    district_name VARCHAR(20) PRIMARY KEY,
    latitude DECIMAL(7, 4),
    longitude DECIMAL(7, 4)
);


INSERT INTO raw_data.seoul_districts_xy (district_name, latitude, longitude) VALUES
('종로구', 37.5729, 126.9794),
('중구', 37.5641, 126.9970),
('용산구', 37.5311, 126.9814),
('성동구', 37.5509, 127.0407),
('광진구', 37.5388, 127.0827),
('동대문구', 37.5744, 127.0395),
('중랑구', 37.6065, 127.0927),
('성북구', 37.6109, 127.0273),
('강북구', 37.6396, 127.0257),
('도봉구', 37.6688, 127.0471),
('노원구', 37.6550, 127.0778),
('은평구', 37.6027, 126.9288),
('서대문구', 37.5794, 126.9368),
('마포구', 37.5662, 126.9018),
('양천구', 37.5271, 126.8561),
('강서구', 37.5509, 126.8497),
('구로구', 37.4954, 126.8581),
('금천구', 37.4574, 126.8956),
('영등포구', 37.5265, 126.8962),
('동작구', 37.4979, 126.9828),
('관악구', 37.4654, 126.9436),
('서초구', 37.4761, 127.0376),
('강남구', 37.5184, 127.0473),
('송파구', 37.5048, 127.1147),
('강동구', 37.5499, 127.1465);



-- 위경도가 포함된 평단가 테이블
create table analytics.property_unit_price_xy
    as
select year
     , district
     , unit_price
     , latitude
     , longitude
  from (select "접수연도" as year
             , "자치구명" as district
             , floor(avg("물건금액"/"건물면적")) as unit_price
          from raw_data.property_sales
         group by "접수연도", "자치구명") p
  left outer join raw_data.seoul_districts_xy d
    on p.district = d.district_name
 order by year desc, unit_price desc;


-- 환승역 구분 표준화
update analytics.metro_xy
   set transfer_type = '환승역'
 where transfer_type = '환슬역';

update analytics.metro_xy
   set transfer_type = '일반역'
 where transfer_type = '도시철도 일반역';

	 
DROP TABLE ANALYTICS.METRO_ANALYTICS;
-- 지하철 역사 수 + 평단가 + 위도경도
CREATE TABLE ANALYTICS.METRO_ANALYTICS
    AS
SELECT P.YEAR
     , P.DISTRICT
     , P.UNIT_PRICE
     , P.LATITUDE
     , P.LONGITUDE
     , M.STATION_CNT
     , CASE WHEN T.TRANSFER_STATION_CNT IS NULL THEN 0 ELSE T.TRANSFER_STATION_CNT END TRANSFER_STATION_CNT
  FROM ANALYTICS.PROPERTY_UNIT_PRICE_XY P
  LEFT OUTER JOIN (SELECT DISTRICT, COUNT(*) STATION_CNT
                      FROM ANALYTICS.METRO_XY
                     GROUP BY DISTRICT) M
    ON P.DISTRICT = M.DISTRICT
  LEFT OUTER JOIN (SELECT DISTRICT, COUNT(*) TRANSFER_STATION_CNT
                      FROM ANALYTICS.METRO_XY
                     WHERE TRANSFER_TYPE = '환승역'
                     GROUP BY DISTRICT) T
    ON P.DISTRICT = T.DISTRICT
 ORDER BY YEAR DESC, UNIT_PRICE DESC;
    	 
	 
	 
	 
	