// lib/services/input_output.dart

import 'dart:io';
import '../core/game_engine.dart';
import '../entities/character.dart';

// 입력 서비스 클래스
class InputService {
  String currentLanguage = 'ko';

  // 언어 선택
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

  // 현재 언어에 맞는 텍스트 반환
  String getLocalizedText(String koText, String enText) {
    return currentLanguage == 'ko' ? koText : enText;
  }

  // 플레이어 이름 입력 받기
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

  // 새 게임 시작 여부 확인
  Future<bool> askToStartNewGame() async {
    print(getLocalizedText('새로운 게임을 시작하시겠습니까? (y/n): ',
        'Do you want to start a new game? (y/n): '));
    return await getYesNoAnswer();
  }

  // 플레이어 행동 입력 받기
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

  // Yes/No 답변 받기
  Future<bool> getYesNoAnswer() async {
    while (true) {
      String? answer = stdin.readLineSync()?.toLowerCase().trim();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print(getLocalizedText('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.',
          'Invalid input. Please enter y or n.'));
    }
  }

  // 캐릭터 선택
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

  // 게임 저장 여부 확인
  bool askToSave() {
    print("레벨업을 했습니다. 게임을 저장하시겠습니까? (y/n)");
    String response = stdin.readLineSync()?.toLowerCase() ?? 'n';
    return response == 'y';
  }

  // 저장된 게임 불러오기 여부 확인
  Future<bool> askToLoadGame() async {
    print(getLocalizedText('저장된 게임을 불러오시겠습니까? (y/n): ',
        'Do you want to load a saved game? (y/n): '));
    return await getYesNoAnswer();
  }

  // 게임 재시작 여부 확인
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

  // 스킬 선택
  int getSkillChoice(int skillCount) {
    while (true) {
      try {
        stdout.write(getLocalizedText('사용할 스킬을 선택하세요 (1-$skillCount): ',
            'Choose a skill to use (1-$skillCount): '));
        String? choice = stdin.readLineSync()?.trim();
        int? index = int.tryParse(choice ?? '');
        if (index != null && index > 0 && index <= skillCount) {
          return index - 1;
        }
        print(getLocalizedText(
            '올바른 번호를 입력해주세요.', 'Please enter a valid number.'));
      } catch (e) {
        print(getLocalizedText("스킬 선택 중 오류가 발생했습니다: $e",
            "An error occurred while choosing a skill: $e"));
      }
    }
  }
}

// 출력 서비스 클래스
class OutputService {
  String currentLanguage = 'ko'; // 기본 언어를 한국어로 설정

  // 현재 언어에 맞는 텍스트 반환
  String getLocalizedText(String koText, String enText) {
    return currentLanguage == 'ko' ? koText : enText;
  }

  // 언어 설정
  void setLanguage(String language) {
    currentLanguage = language;
  }

  // 환영 메시지 출력
  void displayWelcomeMessage(String playerName) {
    print(getLocalizedText("$playerName님, RPG 게임에 오신 것을 환영합니다!",
        "Welcome to the RPG game, $playerName!"));
  }

  // 게임 상태 출력
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

  // 승리 메시지 출력
  void displayVictoryMessage() {
    print("축하합니다! 몬스터를 물리쳤습니다!");
  }

  // 패배 메시지 출력
  void displayDefeatMessage() {
    print("게임 오버! 몬스터에게 패배했습니다.");
  }

  // 전투 시작 메시지 출력
  void displayBattleStart(Character character, Monster monster) {
    print('\n${character.name}와(과) ${monster.name}의 전투가 시작되었습니다!');
    print('${character.name} and ${monster.name} start battling!');
  }

  // 캐릭터 턴 메시지 출력
  void displayCharacterTurn(Character character) {
    print('\n${character.name}의 턴입니다.');
    print("It's ${character.name}'s turn.");
  }

  // 공격 결과 출력
  void displayAttackResult(dynamic attacker, dynamic defender, int damage) {
    String attackerName = attacker is String ? attacker : attacker.name;
    String defenderName = defender is String ? defender : defender.name;
    print('$attackerName이(가) $defenderName에게 $damage의 데미지를 입혔습니다!');
  }

  // 게임 상태 변경 출력
  void displayGameStatusChanges(GameState gameState) {
    print('\n===== 게임 상태 변경 =====');
    print('레벨: ${gameState.level}');
    print('스테이지: ${gameState.stage}');
    print(
        '${gameState.currentCharacter.name} - HP: ${gameState.currentCharacter.health}/${gameState.currentCharacter.maxHealth}, MP: ${gameState.currentCharacter.mp}/${gameState.currentCharacter.maxMp}');
    print('===============================\n');
  }

  // 모든 스킬 습득 메시지 출력
  void displayAllSkillsLearned() {
    print('모든 스킬을 이미 습득했습니다.');
  }

  // 사용 가능한 스킬 없음 메시지 출력
  void displayNoSkillsAvailable() {
    print('습득 가능한 새로운 스킬이 없습니다.');
  }

  // 몬스터 턴 메시지 출력
  void displayMonsterTurn(Monster monster) {
    print('\n${monster.name}의 턴입니다.');
  }

  // 새 스킬 습득 메시지 출력
  void displayNewSkillLearned(Character character, Skill skill) {
    print('${character.name}이(가) 새로운 스킬 "${skill.name}"을(를) 습득했습니다!');
  }

  // 전투 승리 메시지 출력
  void displayBattleWon(String characterName, String monsterName) {
    print('$characterName이(가) $monsterName을(를) 물리쳤습니다!');
    print('$characterName has defeated $monsterName!');
  }

  // 전투 패배 메시지 출력
  void displayBattleLost(String characterName) {
    print('$characterName이(가) 전투에서 패배했습니다.');
    print('$characterName has been defeated in battle.');
  }

  // 게임 오버 메시지 출력
  void displayGameOverMessage() {
    print('게임 오버! 다음에 다시 도전해주세요.');
    print('Game Over! Please try again next time.');
  }

  // 몬스터 처치 메시지 출력
  void displayMonsterDefeated(Monster monster) {
    print('${monster.name}을(를) 물리쳤습니다!');
    print('You have defeated ${monster.name}!');
  }

  // 레벨 업 메시지 출력
  void displayLevelUp(Character character) {
    print('${character.name}의 레벨이 올랐습니다! 현재 레벨: ${character.level}');
    print(
        '${character.name} has leveled up! Current level: ${character.level}');
  }

  // 전투 상태 출력
  void displayBattleStatus(Character character, Monster monster) {
    print('\n===== 전투 상태 / Battle Status =====');
    character.showStatus();
    monster.showStatus();
    print('===============================\n');
  }

  // 방어 행동 메시지 출력
  void displayDefendAction(Character character) {
    print('${character.name}이(가) 방어 태세를 취했습니다.');
  }

  // 아이템 사용 메시지 출력
  void displayUseItemAction(Character character) {
    print('${character.name}이(가) 아이템을 사용했습니다.');
  }

  // 게임 로드 메시지 출력
  void displayGameLoaded() {
    print(getLocalizedText('게임을 성공적으로 불러왔습니다.', 'Game loaded successfully.'));
  }

  // 잘못된 행동 메시지 출력
  void displayInvalidActionMessage() {
    print(getLocalizedText(
        '잘못된 행동입니다. 다시 선택해주세요.', 'Invalid action. Please choose again.'));
  }

  // 게임 저장 메시지 출력
  void displayGameSaved() {
    print(getLocalizedText('게임이 저장되었습니다.', 'Game has been saved.'));
  }

  // 게임 종료 메시지 출력
  void displayGameEndMessage() {
    print('게임을 종료합니다. 이용해 주셔서 감사합니다!');
    print('Game over. Thank you for playing!');
  }

  // 저장된 게임 없음 메시지 출력
  void displayNoSavedGame() {
    print(getLocalizedText('저장된 게임이 없습니다. 새로운 게임을 시작합니다.',
        'No saved game found. Starting a new game.'));
  }

  // 스킬 목록 표시
  void displaySkillList(List<Skill> skills) {
    print(getLocalizedText('\n사용 가능한 스킬:', '\nAvailable skills:'));
    for (int i = 0; i < skills.length; i++) {
      print('${i + 1}. ${skills[i].name} (MP 소모: ${skills[i].mpCost})');
    }
  }

  // 스킬 사용 결과 표시
  void displaySkillUseResult(
      Character character, Monster monster, Skill skill) {
    print('${character.name}이(가) ${skill.name} 스킬을 사용했습니다!');
    print('${monster.name}에게 ${skill.power}의 데미지를 입혔습니다!');
  }

  // MP 부족 메시지 표시
  void displayNotEnoughMP() {
    print(getLocalizedText(
        'MP가 부족하여 스킬을 사용할 수 없습니다.', 'Not enough MP to use the skill.'));
  }

  // 잘못된 스킬 선택 메시지 표시
  void displayInvalidSkillChoice() {
    print(getLocalizedText('잘못된 스킬 선택입니다. 다시 선택해주세요.',
        'Invalid skill choice. Please choose again.'));
  }

  // 몬스터의 스킬 사용 결과 표시
  void displayMonsterSkillUse(
      Monster monster, Character character, Skill skill, int damage) {
    print('${monster.name}이(가) ${skill.name} 스킬을 사용했습니다!');
    print('${character.name}에게 $damage의 데미지를 입혔습니다!');
  }

  // 레벨업 시 새로운 스킬 획득 메시지 표시
  void displayNewSkillAcquired(Character character, Skill newSkill) {
    print('${character.name}이(가) 레벨업으로 새로운 스킬 "${newSkill.name}"을(를) 획득했습니다!');
    print(
        '${character.name} has acquired a new skill "${newSkill.name}" upon leveling up!');
  }

  // 게임 진행 상황 요약 표시
  void displayGameSummary(GameState gameState) {
    print('\n===== ${getLocalizedText("게임 진행 상황", "Game Progress")} =====');
    print(getLocalizedText("총 플레이 시간", "Total Play Time") +
        ': ${gameState.playTime}');
    print(getLocalizedText("처치한 몬스터 수", "Monsters Defeated") +
        ': ${gameState.monstersDefeated}');
    print(getLocalizedText("획득한 경험치", "Experience Gained") +
        ': ${gameState.experienceGained}');
    print('===============================\n');
  }

  void displaySkillEnhanced(Character character, Skill skill) {
    print('${character.name}의 "${skill.name}" 스킬이 강화되었습니다!');
    print('${character.name}\'s "${skill.name}" skill has been enhanced!');
  }

  // 아이템 획득 메시지 표시
  void displayItemAcquired(String itemName) {
    print(getLocalizedText('새로운 아이템을 획득했습니다: $itemName',
        'You have acquired a new item: $itemName'));
  }

  // 인벤토리 표시
  void displayInventory(List<String> items) {
    print('\n===== ${getLocalizedText("인벤토리", "Inventory")} =====');
    if (items.isEmpty) {
      print(getLocalizedText('인벤토리가 비어있습니다.', 'Your inventory is empty.'));
    } else {
      for (int i = 0; i < items.length; i++) {
        print('${i + 1}. ${items[i]}');
      }
    }
    print('===============================\n');
  }

  // 게임 저장 확인 메시지 표시
  void displaySaveConfirmation() {
    print(getLocalizedText(
        '게임을 저장하시겠습니까? (y/n)', 'Do you want to save the game? (y/n)'));
  }

  // 게임 불러오기 확인 메시지 표시
  void displayLoadConfirmation() {
    print(getLocalizedText(
        '저장된 게임을 불러오시겠습니까? (y/n)', 'Do you want to load a saved game? (y/n)'));
  }

  // 게임 설정 메뉴 표시
  void displaySettingsMenu() {
    print('\n===== ${getLocalizedText("게임 설정", "Game Settings")} =====');
    print('1. ${getLocalizedText("언어 변경", "Change Language")}');
    print('2. ${getLocalizedText("음악 켜기/끄기", "Toggle Music")}');
    print('3. ${getLocalizedText("효과음 켜기/끄기", "Toggle Sound Effects")}');
    print('4. ${getLocalizedText("난이도 조절", "Adjust Difficulty")}');
    print('5. ${getLocalizedText("돌아가기", "Back")}');
    print('===============================\n');
  }
}
