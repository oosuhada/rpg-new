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
          // 공격
          character.attackMonster(monster, outputService);
          break;
        case '2':
          // 방어
          character.defend();
          outputService.displayDefendAction(character);
          break;
        case '3':
          // 아이템 사용
          character.useItem();
          outputService.displayUseItemAction(character);
          break;
        case 'reset':
          // 게임 종료
          gameState.setGameOver();
          return;
        default:
          outputService.displayInvalidActionMessage();
      }

      if (monster.health <= 0) {
        outputService.displayBattleWon(character.name, monster.name);
        break;
      }

      // 몬스터의 턴
      outputService.displayMonsterTurn(monster);
      monster.attackCharacter(character, outputService);

      if (character.health <= 0) {
        outputService.displayBattleLost(character.name);
        gameState.setGameOver();
        break;
      }
    }
  }
}
