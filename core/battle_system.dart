// lib/core/battle_system.dart

import '../entities/character.dart';
import '../entities/monster.dart';
import '../services/input_output.dart';
import '../core/game_state.dart';

class BattleSystem {
  final InputService inputService;
  final OutputService outputService;
  late GameState gameState;

  BattleSystem(this.inputService, this.outputService);

  void setGameState(GameState state) {
    gameState = state;
  }

  Future<void> startBattle(Character character, Monster monster) async {
    outputService.displayBattleStart(character, monster);

    while (character.health > 0 && monster.health > 0) {
      // 캐릭터의 턴
      outputService.displayCharacterTurn(character);
      String action = inputService.getPlayerAction();

      switch (action) {
        case '1':
          character.attackMonster(monster, outputService); // 기본 공격
          break;
        case '2':
          character.defend();
          outputService.displayDefendAction(character);
          break;
        case '3':
          character.useItem();
          outputService.displayUseItemAction(character);
          break;
        case 'reset':
          gameState.setGameOver();
          print("게임이 종료되었습니다.");
          return;
        default:
          outputService.displayInvalidActionMessage();
      }

      // 몬스터가 죽었는지 확인
      if (monster.health <= 0) {
        outputService.displayBattleWon(character.name, monster.name);
        return; // 전투 종료
      }

      // 몬스터의 턴
      outputService.displayMonsterTurn(monster);
      monster.attackCharacter(character, outputService);

      if (character.health <= 0) {
        outputService.displayBattleLost(character.name);
        gameState.setGameOver();
        return; // 전투 종료
      }

      // 전투 상태 출력 및 지연 추가
      outputService.displayBattleStatus(character, monster);
      print("전투중입니다.");
      await Future.delayed(Duration(seconds: 2));
    }
    if (monster.health <= 0) {
      outputService.displayBattleWon(character.name, monster.name);
    }

    // Monster's turn
    outputService.displayMonsterTurn(monster);
    monster.attackCharacter(character, outputService);

    if (character.health <= 0) {
      outputService.displayBattleLost(character.name);
      gameState.setGameOver();
    }
  }
}
