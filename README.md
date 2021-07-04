# stage4viscuit

A new Flutter project for viscuit's stage


# API
### StageObject Class
- 설명 : Stage를 위한 최소 단위 객체
- instance field
    1. (String) type : <이미지|클릭|소리> - 일단 넣음
    2. (String) name : 해당 type에 대한 uri
    3. (Offset) offset : 
    4. (double) rotation : 회전각

### Instruction Class
- 설명 : 명령어

### InstructionSection Class
- 설명 : 한 명령어에 대해 Stage 내 대응되는 SO & 관련된 연산 

### StageManager Class
- 설명 : Stage 내 전반적인 일을 다룸; Stage에서 SO를 가져오기 & 그리기