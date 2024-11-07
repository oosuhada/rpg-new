// lib/core/battle_system.dart

import 'dart:async';
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

    // 2초 대기
    Timer(Duration(seconds: 2), () {
      while (character.health > 0 && monster.health > 0) {
        outputService.displayCharacterTurn(character);
        String action = inputService.getPlayerAction();
        executeAction(action, character, monster);
        if (monster.health <= 0) {
          break;
        }
        monsterTurn(character, monster);
        outputService.displayBattleStatus(character, monster);
      }
      handleBattleResult(character, monster);
    });
  }

  void executeAction(String action, Character character, Monster monster) {
    switch (action) {
      case '1': // 공격
        int damage = character.attack - monster.defense;
        if (damage < 0) damage = 0;
        monster.health -= damage;
        outputService.displayAttackResult(character, monster, damage);
        break;
      case '2': // 방어
        character.defend();
        outputService.displayDefendAction(character);
        break;
      case '3': // 아이템 사용
        character.useItem();
        outputService.displayUseItemAction(character);
        break;
      default:
        outputService.displayInvalidActionMessage();
    }
  }

  void monsterTurn(Character character, Monster monster) {
    final damage = monster.attack - character.defense;
    if (damage > 0) {
      character.health -= damage;
      outputService.displayAttackResult(monster, character, damage);
    } else {
      outputService.displayAttackResult(monster, character, 0);
    }
  }

  void executeCharacterAction(
      String action, Character character, Monster monster) {
    switch (action) {
      case '1': // 공격
        int damage = character.attack - monster.defense;
        if (damage < 0) damage = 0;
        monster.health -= damage;
        outputService.displayAttackResult(character, monster, damage);
        break;
      case '2': // 방어
        character.defend();
        outputService.displayDefendAction(character);
        break;
      case '3': // 아이템 사용
        character.useItem();
        outputService.displayUseItemAction(character);
        break;
      default:
        outputService.displayInvalidActionMessage();
    }
  }

  void executeMonsterAction(Monster monster, Character character) {
    int damage = monster.attack - character.defense;
    if (damage < 0) damage = 0;
    character.health -= damage;
    outputService.displayAttackResult(monster, character, damage);
  }

  void handleBattleResult(Character character, Monster monster) {
    if (character.health <= 0) {
      outputService.displayBattleLost(character.name);
    } else {
      outputService.displayBattleWon(character.name, monster.name);
    }
  }
}
