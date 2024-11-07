// lib/entities/skill.dart

class Skill {
  String name;
  int power;
  int mpCost;

  Skill(this.name, this.power, this.mpCost);

  /// 스킬을 직렬화하여 문자열로 반환
  String serialize() {
    return '$name,$power,$mpCost';
  }

  /// 직렬화된 문자열로부터 Skill 객체를 생성
  static Skill deserialize(String data) {
    final parts = data.split(',');
    if (parts.length < 3) {
      throw FormatException('잘못된 Skill 데이터 형식');
    }
    return Skill(parts[0], int.parse(parts[1]), int.parse(parts[2]));
  }
}
