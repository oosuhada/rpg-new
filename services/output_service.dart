// lib/services/output_service.dart

import '../core/game_state.dart';
import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';

class OutputService {
  void displayWelcomeMessage() {
    print("RPG 게임에 오신 것을 환영합니다!");
  }

  void displayVictoryMessage() {
    print("축하합니다! 몬스터를 물리쳤습니다!");
  }

  void displayDefeatMessage() {
    print("게임 오버! 몬스터에게 패배했습니다.");
  }

  void displayGameStatus(GameState gameState) {
    print('\n===== 게임 상태 / Game Status =====');
    print('레벨 / Level: ${gameState.level}');
    print('스테이지 / Stage: ${gameState.stage}');
    gameState.currentCharacter.showStatus();
  }

  void displayBattleStart(Character character, Monster monster) {
    print('\n${character.name}와(과) ${monster.name}의 전투가 시작되었습니다!');
    print('${character.name} and ${monster.name} start battling!');
  }

  void displayCharacterTurn(Character character) {
    print('\n${character.name}의 턴입니다.');
    print("It's ${character.name}'s turn.");
  }

  void displayAttackResult(String attacker, String defender, int damage) {
    print('$attacker가 $defender에게 $damage의 데미지를 입혔습니다!');
    print('$attacker dealt $damage damage to $defender!');
  }

  void displayBattleWon(String characterName, String monsterName) {
    print('$characterName이(가) $monsterName을(를) 물리쳤습니다!');
    print('$characterName has defeated $monsterName!');
  }

  void displayBattleLost(String characterName) {
    print('$characterName이(가) 전투에서 패배했습니다.');
    print('$characterName has been defeated in battle.');
  }

  void displayGameOverMessage() {
    print('게임 오버! 다음에 다시 도전해주세요.');
    print('Game Over! Please try again next time.');
  }

  void displayMonsterDefeated(Monster monster) {
    print('${monster.name}을(를) 물리쳤습니다!');
    print('You have defeated ${monster.name}!');
  }

  void displayLevelUp(Character character) {
    print('${character.name}의 레벨이 올랐습니다! 현재 레벨: ${character.level}');
    print(
        '${character.name} has leveled up! Current level: ${character.level}');
  }

  void displayNewSkillLearned(Character character, Skill skill) {
    print('${character.name}이(가) 새로운 스킬 ${skill.name}을(를) 배웠습니다!');
    print('스킬 정보: 위력 ${skill.power}');
  }
}
