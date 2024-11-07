// lib/entities/character.dart

import 'dart:math';
import 'skill.dart';

class Character {
  String name;
  String characterType;
  int health;
  late int maxHealth;
  int attack;
  int defense;
  bool hasUsedItem = false;
  int level = 1;
  List<Skill> skills;

  Character(this.name, this.characterType, this.health, this.attack,
      this.defense, this.skills) {
    maxHealth = health;
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
    health = health + healAmount > maxHealth ? maxHealth : health + healAmount;
  }

  void useItem() {
    if (!hasUsedItem) {
      attack *= 2;
      hasUsedItem = true;
    }
  }

  void showStatus() {
    print(
        '$name ($characterType) - HP: $health/$maxHealth, ATK: $attack, DEF: $defense');
  }

  void setHealth(int newHealth) {
    health = min(newHealth, maxHealth);
  }
}
