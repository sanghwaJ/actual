/**
 * pagination에서 fetchMore를 할 땐, 마지막 id 값이 필요한데,
 * 정확한 model과 class의 값을 넣어 dynamic을 최소화하기 위해,
 * id 값이 존재하다는 것을 증명하기 위해 model도 일반화함
 * 따라서, IModelWithId를 implements하는 모든 Model은 id를 가지고 있음을 강제함
 */

abstract class IModelWithId {
  final String id;

  IModelWithId({
    required this.id,
  });
}
