// lib/entities/character.dart

import 'dart:math';

// 캐릭터 클래스 정의
class Character {
  String name;
  int health;
  late int maxHealth;
  int attack;
  int defense;
  bool hasUsedItem = false;
  int level = 1;
  List<Skill> skills = [];
  int mp;
  int maxMp;
  Map<Skill, int> skillLevels = {};

  Character(this.name, this.health, this.attack, this.defense, this.skills,
      {this.mp = 50, this.maxMp = 50}) {
    maxHealth = health;
    for (var skill in skills) {
      skillLevels[skill] = 1;
    }
  }

  void enhanceSkill(Skill skill) {
    if (skillLevels.containsKey(skill)) {
      skillLevels[skill] = (skillLevels[skill] ?? 0) + 1;
    } else {
      skillLevels[skill] = 1;
    }
    skill.power += 5; // 스킬 파워 증가
  }

  bool useSkill(Skill skill, Monster target) {
    if (mp >= skill.mpCost) {
      mp -= skill.mpCost;
      int skillLevel = skillLevels[skill] ?? 1;
      int damage = ((attack + skill.power + (skillLevel * 2)) - target.defense)
          .clamp(0, double.infinity)
          .toInt();
      target.health -= damage;
      return true;
    }
    return false;
  }

  // 레벨 업
  void levelUp() {
    level++;
    maxHealth += 10;
    health = maxHealth;
    attack += 5;
    defense += 3;
    maxMp += 5;
    mp = maxMp;
  }

  // 방어 행동
  void defend() {
    int healAmount = (maxHealth * 0.15).round();
    health = (health + healAmount).clamp(0, maxHealth);
  }

  // 아이템 사용
  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
    }
  }

  // 상태 표시
  void showStatus() {
    print(
        '$name - HP: $health/$maxHealth, ATK: $attack, DEF: $defense, MP: $mp/$maxMp');
  }

  // 체력 설정
  void setHealth(int newHealth) {
    health = newHealth.clamp(0, maxHealth);
  }
}

// 몬스터 클래스 정의
class Monster {
  String name;
  String type;
  late int health;
  late int maxHealth;
  int maxAttack;
  late int attack;
  int defense;
  int level;
  List<Skill> skills;

  // 생성자
  Monster(this.name, this.type, int baseHealth, this.maxAttack, this.level,
      this.skills,
      {this.defense = 1}) {
    this.maxHealth = calculateScaledHealth(baseHealth, level);
    this.health = this.maxHealth;
    this.attack = Random().nextInt(maxAttack) + level * 5;
  }

  int calculateScaledHealth(int baseHealth, int level) {
    return (baseHealth * (1 + 0.1 * level)).round();
  }

  // 스킬 사용
  int useSkill(Skill skill, Character target) {
    int damage = calculateDamage(skill, target);
    target.setHealth(target.health - damage);
    return damage;
  }

  // 랜덤 스킬 선택
  Skill chooseRandomSkill() {
    return skills[Random().nextInt(skills.length)];
  }

  // 데미지 계산
  int calculateDamage(Skill skill, Character target) {
    double effectiveness = 1.0;
    int baseDamage = ((attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - target.defense)
        .clamp(0, double.infinity)
        .toInt();
  }

  // 상태 표시
  void showStatus() {
    print(
        '$name ($type) - 체력: $health/$maxHealth, 공격력: $attack, 방어력: $defense');
  }
}

// 스킬 효과 타입 정의
typedef SkillEffect = void Function(Character user, Monster target);

// 스킬 클래스 정의
class Skill {
  String name;
  int power;
  int mpCost;
  SkillEffect? effect;

  // 생성자
  Skill(this.name, this.power, this.mpCost, {this.effect});
}
