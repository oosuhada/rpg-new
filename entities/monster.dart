// lib/entities/monster.dart

import 'dart:math';
import 'character.dart';
import 'skill.dart';

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
    character.health -= damage;
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
    return (baseDamage * effectiveness - character.defense).round();
  }

  void showStatus() {
    print(
        '$name ($type) - 체력: $health/$maxHealth, 공격력: $attack, 방어력: $defense');
  }
}
