// lib/entities/character.dart

import 'dart:math';

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

  Character(this.name, this.health, this.attack, this.defense, this.skills,
      {this.mp = 50, this.maxMp = 50}) {
    maxHealth = health;
  }

  void learnSkill(Skill skill) {
    if (!skills.contains(skill)) {
      skills.add(skill);
    }
  }

  bool useSkill(Skill skill, Monster target) {
    if (mp >= skill.mpCost) {
      mp -= skill.mpCost;
      int damage = (attack + skill.power - target.defense)
          .clamp(0, double.infinity)
          .toInt();
      target.health -= damage;
      return true;
    }
    return false;
  }

  void levelUp() {
    level++;
    maxHealth += 10;
    health = maxHealth;
    attack += 5;
    defense += 3;
  }

  void defend() {
    int healAmount = (maxHealth * 0.15).round();
    health = (health + healAmount).clamp(0, maxHealth);
  }

  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
    }
  }

  void showStatus() {
    print(
        '$name - HP: $health/$maxHealth, ATK: $attack, DEF: $defense, MP: $mp/$maxMp');
  }

  void setHealth(int newHealth) {
    health = newHealth.clamp(0, maxHealth);
  }
}

class Monster {
  String name;
  String type;
  int health;
  late int maxHealth;
  int maxAttack;
  late int attack;
  int defense;
  int level;
  List<Skill> skills;

  Monster(this.name, this.type, this.health, this.maxAttack, this.level,
      this.skills,
      {this.defense = 1}) {
    maxHealth = health;
    attack = Random().nextInt(maxAttack) + level * 5;
  }

  void attackCharacter(Character character) {
    Skill selectedSkill = skills[Random().nextInt(skills.length)];
    int damage = calculateDamage(selectedSkill, character);
    character.setHealth(character.health - damage);
    print(
        '${this.name}이(가) ${selectedSkill.name}을(를) 사용하여 ${character.name}에게 $damage의 데미지를 입혔습니다!');
    if (selectedSkill.effect != null) {
      selectedSkill.effect!(character, this);
    }
  }

  Skill chooseRandomSkill() {
    return skills[Random().nextInt(skills.length)];
  }

  int calculateDamage(Skill skill, Character character) {
    double effectiveness = 1.0;
    int baseDamage = ((attack * skill.power) / 100).round();
    return (baseDamage * effectiveness - character.defense)
        .clamp(0, double.infinity)
        .toInt();
  }

  void showStatus() {
    print(
        '$name ($type) - 체력: $health/$maxHealth, 공격력: $attack, 방어력: $defense');
  }
}

typedef SkillEffect = void Function(Character user, Monster target);

class Skill {
  String name;
  int power;
  int mpCost;
  SkillEffect? effect;

  Skill(this.name, this.power, this.mpCost, {this.effect});
}
