// lib/core/battle_system.dart

import '../entities/character.dart';
import '../entities/monster.dart';
import '../services/input_service.dart';
import '../services/output_service.dart';

class BattleSystem {
  final InputService inputService;
  final OutputService outputService;

  BattleSystem(this.inputService, this.outputService);

  void startBattle(Character character, Monster monster) {
    outputService.displayBattleStart(character, monster);

    while (character.health > 0 && monster.health > 0) {
      characterTurn(character, monster);
      if (monster.health <= 0) break;
      monsterTurn(character, monster);
    }

    handleBattleResult(character, monster);
  }

  void characterTurn(Character character, Monster monster) {
    outputService.displayCharacterTurn(character);
    final action = inputService.getPlayerAction();
    executeCharacterAction(action, character, monster);
  }

  void executeCharacterAction(
      String action, Character character, Monster monster) {
    switch (action) {
      case '1':
        final damage = character.attack - monster.defense;
        monster.health -= damage;
        outputService.displayAttackResult(character.name, monster.name, damage);
        break;
      case '2':
        character.defend();
        break;
      case '3':
        character.useItem();
        break;
    }
  }

  void monsterTurn(Character character, Monster monster) {
    final damage = monster.attack - character.defense;
    character.health -= damage;
    outputService.displayAttackResult(monster.name, character.name, damage);
  }

  void handleBattleResult(Character character, Monster monster) {
    if (character.health <= 0) {
      outputService.displayBattleLost(character.name);
    } else {
      outputService.displayBattleWon(character.name, monster.name);
    }
  }
}
