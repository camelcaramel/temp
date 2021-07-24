# stage4viscuit

## 설명
A new Flutter project for viscuit's stage

## 데이터 타입(Class)
### 1. StageObject
#### 역할
Stage 내 나타나는 그림에 대응되는 객체로, 다뤄지는 최소 단위 객체이다.
  
#### 구현
특정 자료구조를 가지지 않는다.

#### 속성 및 메소드
+ 속성
    1. (String) type : <이미지|클릭|소리> - 일단 넣음
    2. (String) name : 해당 type에 대한 uri
    3. (Offset) offset : 
    4. (double) rotation : 회전각
+ 메소드


### 2. SOList


### 3. SOMap




## public API



---


### InstructionSection Class
- 설명 : 한 명령어에 대해 Stage 내 대응되는 SO & 관련된 연산 

### StageManager Class
- 설명 : Stage 내 전반적인 일을 다룸; Stage에서 SO를 가져오기 & 그리기
