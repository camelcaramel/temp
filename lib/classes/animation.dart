import 'component.dart';

enum AnimationType {
  UNDEFINED,
  DUPLICATE,
  MERGE,
  MANY,
  CREATE,
  VANISH,
  ONE
}

// 추후에 복잡한 animation을 사용할 때 적용해볼 것

abstract class Animation {
  StageObject animate(StageObject so1, StageObject so2, double d);
}

class MoveAnimation implements Animation {
  StageObject animate(StageObject so1, StageObject so2, double d) {
    throw UnimplementedError();
  }
}

class CreateAnimation implements Animation {
  StageObject animate(StageObject so1, StageObject so2, double d) {
    throw UnimplementedError();
  }
}



abstract class Interpolatable {
  StageObject interpolate(StageObject so1, StageObject so2, double d);
}

class MoveInterpolate implements Interpolatable {
  StageObject interpolate(StageObject so1, StageObject so2, double d) {
    throw UnimplementedError();
  }
}

class CreateInterpolate implements Interpolatable {
  StageObject interpolate(StageObject so1, StageObject so2, double d) {
    throw UnimplementedError();
  }
}