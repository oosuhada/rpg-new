// lib/core/battle_system.dart

import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
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

  Future startBattle(Character character, Monster monster) async {
    print("[DEBUG] startBattle() 메서드 호출");
    outputService.displayBattleStart(character, monster);
    print("[DEBUG] displayBattleStart() 호출 완료");

    while (character.health > 0 && monster.health > 0) {
      // 캐릭터의 턴
      outputService.displayCharacterTurn(character);
      print("[DEBUG] displayCharacterTurn() 호출 완료");

      String action = inputService.getPlayerAction();
      print("[DEBUG] getPlayerAction() 반환: $action");

      switch (action) {
        case '1':
          print("[DEBUG] 공격 선택: executeAttackChoice()");
          await executeAttackChoice(character, monster);
          print("[DEBUG] executeAttackChoice() 호출 완료");
          break;
        case '2':
          character.defend();
          outputService.displayDefendAction(character);
          print("[DEBUG] defend() 및 displayDefendAction() 호출 완료");
          break;
        case '3':
          character.useItem();
          outputService.displayUseItemAction(character);
          print("[DEBUG] useItem() 및 displayUseItemAction() 호출 완료");
          break;
        case 'reset':
          gameState.setGameOver();
          print("[DEBUG] gameState.setGameOver() 호출 완료");
          print("게임이 종료되었습니다.");
          return;
        default:
          outputService.displayInvalidActionMessage();
          print("[DEBUG] displayInvalidActionMessage() 호출 완료");
      }

      // 몬스터가 죽었는지 확인
      if (monster.health <= 0) {
        outputService.displayBattleWon(character.name, monster.name);
        print("[DEBUG] displayBattleWon() 호출 완료");
        return; // 전투 종료
      }

      // 몬스터의 턴
      outputService.displayMonsterTurn(monster);
      print("[DEBUG] displayMonsterTurn() 호출 완료");
      monster.attackCharacter(character, outputService);
      print("[DEBUG] monster.attackCharacter() 호출 완료");

      if (character.health <= 0) {
        outputService.displayBattleLost(character.name);
        gameState.setGameOver();
        print("[DEBUG] displayBattleLost() 및 gameState.setGameOver() 호출 완료");
        return; // 전투 종료
      }

      // 전투 상태 출력 및 지연 추가
      outputService.displayBattleStatus(character, monster);
      print("[DEBUG] displayBattleStatus() 호출 완료");

      print("전투중입니다.");
      await Future.delayed(Duration(seconds: 2));
      print("[DEBUG] Future.delayed() 호출 완료");
    }
  }

  // 플레이어가 공격 방식을 선택하고 실행하는 함수
  Future executeAttackChoice(Character character, Monster monster) async {
    String? attackChoice = await inputService.getAttackChoice();
    if (attackChoice == '1') {
      character.attackMonster(monster, outputService);
    } else if (attackChoice == '2') {
      if (character.skills.isNotEmpty) {
        outputService.displaySkillList(character.skills);
        int skillIndex = inputService.getSkillChoice(character.skills.length);
        Skill chosenSkill = character.skills[skillIndex];
        bool success = character.useSkill(chosenSkill, monster);
        if (success) {
          outputService.displaySkillUsed(character, chosenSkill);
        } else {
          outputService.displayNotEnoughMP();
        }
      } else {
        outputService.displayNoSkillsAvailable();
      }
    } else {
      outputService.displayInvalidActionMessage();
    }
  }
}
