// lib/entities/character.dart

import '../services/input_output.dart';
import 'skill.dart';
import 'monster.dart';

class Character {
  String name;
  int health;
  late int maxHealth;
  int attack;
  int defense;
  bool hasUsedItem = false;
  int level = 1;
  List<Skill> skills;
  int mp;
  int maxMp;
  Map<String, int> skillLevels = {}; // 스킬 이름을 키로 사용

  Character(
    this.name,
    this.health,
    this.attack,
    this.defense,
    this.skills, {
    this.mp = 50,
    this.maxMp = 50,
  }) {
    maxHealth = health;
    for (var skill in skills) {
      skillLevels[skill.name] = 1;
    }
  }

  /// 스킬을 강화하는 메서드
  void enhanceSkill(Skill skill) {
    if (skillLevels.containsKey(skill.name)) {
      skillLevels[skill.name] = (skillLevels[skill.name] ?? 0) + 1;
    } else {
      skillLevels[skill.name] = 1;
    }

    skill.power += 5;
  }

  /// 스킬을 사용하여 공격하는 메서드
  bool useSkill(Skill skill, Monster target) {
    if (mp >= skill.mpCost) {
      mp -= skill.mpCost;
      int skillLevel = skillLevels[skill.name] ?? 1;
      int damage = ((attack + skill.power + (skillLevel * 2)) - target.defense)
          .clamp(0, double.infinity)
          .toInt();
      target.health -= damage;
      return true;
    }
    return false;
  }

  /// 레벨업 메서드
  void levelUp() {
    level++;
    maxHealth += 10;
    health = maxHealth;
    attack += 5;
    defense += 3;
    maxMp += 5;
    mp = maxMp;
  }

  /// 방어 메서드
  void defend() {
    int healAmount = (maxHealth * 0.15).round();
    health = (health + healAmount).clamp(0, maxHealth);
  }

  /// 아이템 사용 메서드
  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
    }
  }

  /// 현재 상태를 출력하는 메서드
  void showStatus() {
    print(
        '$name - HP: $health/$maxHealth, ATK: $attack, DEF: $defense, MP: $mp/$maxMp');
  }

  /// 건강 상태 설정 메서드
  void setHealth(int newHealth) {
    health = newHealth.clamp(0, maxHealth);
  }

  /// 캐릭터를 직렬화하여 문자열로 반환
  String serialize() {
    // 스킬들을 직렬화
    String serializedSkills =
        skills.map((skill) => skill.serialize()).join(';');

    // 스킬 레벨들을 직렬화
    String serializedSkillLevels = skillLevels.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(';');

    return '$name,$health,$attack,$defense,$hasUsedItem,$level,$serializedSkills,$mp,$maxMp,$serializedSkillLevels';
  }

  /// 직렬화된 문자열로부터 Character 객체를 생성
  static Character deserialize(String data) {
    final parts = data.split(',');

    if (parts.length < 10) {
      throw FormatException('잘못된 Character 데이터 형식');
    }

    String name = parts[0];
    int health = int.parse(parts[1]);
    int attack = int.parse(parts[2]);
    int defense = int.parse(parts[3]);
    bool hasUsedItem = parts[4].toLowerCase() == 'true';
    int level = int.parse(parts[5]);

    // 스킬 복원
    List<Skill> skills = [];
    if (parts[6].isNotEmpty) {
      skills = parts[6].split(';').map((skillStr) {
        return Skill.deserialize(skillStr);
      }).toList();
    }

    int mp = int.parse(parts[7]);
    int maxMp = int.parse(parts[8]);

    // 스킬 레벨 복원
    Map<String, int> skillLevels = {};
    if (parts[9].isNotEmpty) {
      parts[9].split(';').forEach((skillLevelStr) {
        final skillParts = skillLevelStr.split(':');
        if (skillParts.length == 2) {
          String skillName = skillParts[0];
          int level = int.parse(skillParts[1]);

          skillLevels[skillName] = level;
        }
      });
    }

    Character character = Character(
      name,
      health,
      attack,
      defense,
      skills,
      mp: mp,
      maxMp: maxMp,
    );
    character.hasUsedItem = hasUsedItem;
    character.level = level;
    character.skillLevels = skillLevels;

    return character;
  }

  void attackMonster(Monster monster, OutputService outputService) {
    int damage = (attack - monster.defense).clamp(0, double.infinity).toInt();
    monster.health -= damage;
    outputService.displayAttackResult(name, monster.name, damage);
  }
}
