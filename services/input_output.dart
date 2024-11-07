import 'dart:io';
import '../core/game_engine.dart';
import '../entities/character.dart';

class InputService {
  String currentLanguage = 'ko';

  Future<void> chooseLanguage() async {
    print('언어를 선택하세요 / Choose language:');
    print('1. 한국어');
    print('2. English');

    while (true) {
      String? choice = stdin.readLineSync()?.trim();
      switch (choice) {
        case '1':
          currentLanguage = 'ko';
          return;
        case '2':
          currentLanguage = 'en';
          return;
        default:
          print('올바른 번호를 입력해주세요. / Please enter a valid number.');
      }
    }
  }

  String getLocalizedText(String koText, String enText) {
    return currentLanguage == 'ko' ? koText : enText;
  }

  Future<String> getPlayerName() async {
    while (true) {
      stdout.write(
          getLocalizedText("사용자 이름을 입력해주세요: ", "Please enter your name: "));
      String? name = stdin.readLineSync()?.trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
      print(getLocalizedText('올바른 이름을 입력해주세요.', 'Please enter a valid name.'));
    }
  }

  Future<bool> askToStartNewGame() async {
    print(getLocalizedText('새로운 게임을 시작하시겠습니까? (y/n): ',
        'Do you want to start a new game? (y/n): '));
    return await getYesNoAnswer();
  }

  String getPlayerAction() {
    while (true) {
      try {
        stdout.write(getLocalizedText(
            "액션을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용, reset: 게임 종료): ",
            "Choose an action (1: Attack, 2: Defend, 3: Use Item, reset: End Game): "));
        String? input = stdin.readLineSync()?.toLowerCase().trim();
        if (input == 'reset' || ['1', '2', '3'].contains(input)) return input!;
        print(getLocalizedText(
            '올바른 행동을 선택해주세요.', 'Please choose a valid action.'));
      } catch (e) {
        print(getLocalizedText("입력 처리 중 오류가 발생했습니다: $e",
            "An error occurred while processing input: $e"));
      }
    }
  }

  Future<bool> getYesNoAnswer() async {
    while (true) {
      String? answer = stdin.readLineSync()?.toLowerCase().trim();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print(getLocalizedText('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.',
          'Invalid input. Please enter y or n.'));
    }
  }

  Future<Character> chooseCharacter(List<Character> characters) async {
    print('\n${getLocalizedText('사용 가능한 캐릭터:', 'Available characters:')}');
    for (int i = 0; i < characters.length; i++) {
      print('${i + 1}. ${characters[i].name}');
    }

    while (true) {
      try {
        stdout.write(getLocalizedText('캐릭터를 선택하세요 (1-${characters.length}): ',
            'Choose your character (1-${characters.length}): '));
        String? choice = stdin.readLineSync()?.trim();
        int? index = int.tryParse(choice ?? '');
        if (index != null && index > 0 && index <= characters.length) {
          return characters[index - 1];
        }
        print(getLocalizedText(
            '올바른 번호를 입력해주세요.', 'Please enter a valid number.'));
      } catch (e) {
        print(getLocalizedText("캐릭터 선택 중 오류가 발생했습니다: $e",
            "An error occurred while choosing a character: $e"));
      }
    }
  }

  bool askToSave() {
    print("레벨업을 했습니다. 게임을 저장하시겠습니까? (y/n)");
    String response = stdin.readLineSync()?.toLowerCase() ?? 'n';
    return response == 'y';
  }

  Future<bool> askToLoadGame() {
    print(getLocalizedText('저장된 게임을 불러오시겠습니까? (y/n): ',
        'Do you want to load a saved game? (y/n): '));
    return getYesNoAnswer();
  }

  bool askToRetry() {
    while (true) {
      try {
        stdout.write('게임을 다시 시작하시겠습니까? (y/n): ');
        String? input = stdin.readLineSync()?.toLowerCase().trim();
        if (input == 'y') return true;
        if (input == 'n') return false;
        print('올바른 입력을 해주세요 (y 또는 n).');
      } catch (e) {
        print("입력 처리 중 오류가 발생했습니다: $e");
      }
    }
  }
}

class OutputService {
  String currentLanguage = 'ko'; // 기본 언어를 한국어로 설정

  String getLocalizedText(String koText, String enText) {
    return currentLanguage == 'ko' ? koText : enText;
  }

  void setLanguage(String language) {
    currentLanguage = language;
  }

  void displayWelcomeMessage(String playerName) {
    print(getLocalizedText("$playerName님, RPG 게임에 오신 것을 환영합니다!",
        "Welcome to the RPG game, $playerName!"));
  }

  void displayGameStatus(GameState gameState) {
    print('\n===== ${getLocalizedText("게임 상태", "Game Status")} =====');
    print(getLocalizedText("레벨", "Level") + ': ${gameState.level}');
    print(getLocalizedText("스테이지", "Stage") + ': ${gameState.stage}');
    gameState.currentCharacter.showStatus();
    if (gameState.currentMonster != null) {
      gameState.currentMonster.showStatus();
    }
    print('===============================\n');
  }

  void displayVictoryMessage() {
    print("축하합니다! 몬스터를 물리쳤습니다!");
  }

  void displayDefeatMessage() {
    print("게임 오버! 몬스터에게 패배했습니다.");
  }

  void displayBattleStart(Character character, Monster monster) {
    print('\n${character.name}와(과) ${monster.name}의 전투가 시작되었습니다!');
    print('${character.name} and ${monster.name} start battling!');
  }

  void displayCharacterTurn(Character character) {
    print('\n${character.name}의 턴입니다.');
    print("It's ${character.name}'s turn.");
  }

  void displayAttackResult(dynamic attacker, dynamic defender, int damage) {
    String attackerName = attacker is String ? attacker : attacker.name;
    String defenderName = defender is String ? defender : defender.name;
    print('$attackerName이(가) $defenderName에게 $damage의 데미지를 입혔습니다!');
  }

  void displayGameStatusChanges(GameState gameState) {
    print('\n===== 게임 상태 변경 =====');
    print('레벨: ${gameState.level}');
    print('스테이지: ${gameState.stage}');
    print(
        '${gameState.currentCharacter.name} - HP: ${gameState.currentCharacter.health}/${gameState.currentCharacter.maxHealth}, MP: ${gameState.currentCharacter.mp}/${gameState.currentCharacter.maxMp}');
    print('===============================\n');
  }

  void displayAllSkillsLearned() {
    print('모든 스킬을 이미 습득했습니다.');
  }

  void displayNoSkillsAvailable() {
    print('습득 가능한 새로운 스킬이 없습니다.');
  }

  void displayMonsterTurn(Monster monster) {
    print('${monster.name}의 턴입니다.');
  }

  void displayNewSkillLearned(Character character, Skill skill) {
    print('${character.name}이(가) 새로운 스킬 "${skill.name}"을(를) 습득했습니다!');
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

  void displayBattleStatus(Character character, Monster monster) {
    print('\n===== 전투 상태 / Battle Status =====');
    character.showStatus();
    monster.showStatus();
    print('===============================\n');
  }

  void displayDefendAction(Character character) {
    print('${character.name}이(가) 방어 태세를 취했습니다.');
  }

  void displayUseItemAction(Character character) {
    print('${character.name}이(가) 아이템을 사용했습니다.');
  }

  void displayGameLoaded() {
    print(getLocalizedText('게임을 성공적으로 불러왔습니다.', 'Game loaded successfully.'));
  }

  void displayInvalidActionMessage() {
    print(getLocalizedText(
        '잘못된 행동입니다. 다시 선택해주세요.', 'Invalid action. Please choose again.'));
  }

  void displayGameSaved() {
    print(getLocalizedText('게임이 저장되었습니다.', 'Game has been saved.'));
  }

  void displayGameEndMessage() {
    print('게임을 종료합니다. 이용해 주셔서 감사합니다!');
    print('Game over. Thank you for playing!');
  }

  void displayNoSavedGame() {
    print(getLocalizedText('저장된 게임이 없습니다. 새로운 게임을 시작합니다.',
        'No saved game found. Starting a new game.'));
  }
}
