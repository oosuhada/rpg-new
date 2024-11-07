// lib/entities/monster.dart

import '../services/input_output.dart';
import 'character.dart';
import 'skill.dart';

class Monster {
  String name;
  String type;
  int health;
  late int maxHealth;
  int attack;
  late int defense;
  int level;
  List<Skill> skills;

  Monster(
    this.name,
    this.type,
    this.health,
    this.attack,
    this.level,
    this.skills,
  ) {
    maxHealth = health;
    defense = level * 2;
  }

  /// 현재 상태를 출력하는 메서드
  void showStatus() {
    print(
        '$name - HP: $health/$maxHealth, ATK: $attack, DEF: $defense, LVL: $level');
  }

  /// 건강 상태 계산 메서드
  int calculateScaledHealth(int baseHealth, int playerLevel) {
    return (baseHealth * (1 + 0.1 * playerLevel)).round();
  }

  /// 몬스터를 직렬화하여 문자열로 반환
  String serialize() {
    // 스킬들을 직렬화
    String serializedSkills =
        skills.map((skill) => skill.serialize()).join(';');

    return '$name,$type,$health,$attack,$level,$serializedSkills';
  }

  /// 직렬화된 문자열로부터 Monster 객체를 생성
  static Monster deserialize(String data) {
    final parts = data.split(',');

    if (parts.length < 6) {
      throw FormatException('잘못된 Monster 데이터 형식');
    }

    String name = parts[0];
    String type = parts[1];
    int health = int.parse(parts[2]);
    int attack = int.parse(parts[3]);
    int level = int.parse(parts[4]);

    // 스킬 복원
    List<Skill> skills = [];
    if (parts[5].isNotEmpty) {
      skills = parts[5].split(';').map((skillStr) {
        return Skill.deserialize(skillStr);
      }).toList();
    }

    Monster monster = Monster(name, type, health, attack, level, skills);

    return monster;
  }

  void attackCharacter(Character character, OutputService outputService) {
    int damage = (attack - character.defense).clamp(0, double.infinity).toInt();
    character.health -= damage;
    outputService.displayAttackResult(name, character.name, damage);
  }
}
