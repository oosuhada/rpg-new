// lib/entities/skill.dart

import 'character.dart';

typedef SkillEffect = void Function(dynamic user, dynamic target);

class Skill {
  String name;
  int power;
  SkillEffect? effect;

  Skill(this.name, this.power, {this.effect});

  void showInfo() {
    print('$name (위력: $power)');
  }
}

Skill createSkill(String name, int power, {SkillEffect? effect}) {
  return Skill(name, power, effect: effect);
}

List<Skill> getInitialSkills() {
  return [
    createSkill('기본 공격', 30),
    createSkill('강한 공격', 50),
    createSkill('회복', 0, effect: (user, target) {
      if (user is Character) {
        int healAmount = (user.maxHealth * 0.2).round();
        user.setHealth(user.health + healAmount);
        print('${user.name}이(가) $healAmount만큼 체력을 회복했습니다.');
      }
    }),
  ];
}
