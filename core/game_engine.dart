// lib/core/game_engine.dart

import 'dart:io';
import 'dart:math';
import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
import '../services/input_output.dart';
import '../services/save_load_service.dart';
import 'game_state.dart';
import 'battle_system.dart';

class GameEngine {
  final InputService inputService;
  final OutputService outputService;
  late SaveLoadService saveLoadService;
  late GameState gameState;
  late BattleSystem battleSystem;
  List<Character> characters = [];
  List<Monster> monsters = [];
  List<Skill> allSkills = [];
  String? playerName;

  GameEngine(this.inputService, this.outputService);

  // Initialize game
  Future<void> initialize() async {
    try {
      saveLoadService = SaveLoadService();
      await loadCharacters();
      await loadMonsters();
      await loadSkills();
      await inputService.chooseLanguage();
      playerName = await inputService.getPlayerName();

      // 저장된 게임 상태 로드
      GameState? loadedState =
          saveLoadService.loadGameState(characters, monsters);
      if (loadedState != null) {
        gameState = loadedState;
        outputService.displayGameLoaded();
      } else {
        Character selectedCharacter =
            await inputService.chooseCharacter(characters);
        Monster firstMonster = monsters.first;
        gameState = GameState(selectedCharacter, firstMonster, characters);

        // 게임 상태를 한 번만 출력
        outputService.displayGameStatus(gameState);
      }

      battleSystem = BattleSystem(inputService, outputService);
      battleSystem.setGameState(gameState);
    } catch (e) {
      print("초기화 중 오류가 발생했습니다: $e");
      exit(1);
    }
  }

  // Start game
  Future<void> start() async {
    bool playAgain = true;
    while (playAgain) {
      outputService.displayWelcomeMessage(playerName!);

      GameState? loadedState = saveLoadService.loadGameState(
          characters, monsters); // Corrected signature
      if (loadedState != null) {
        gameState = loadedState;
        outputService.displayGameLoaded();
      } else {
        outputService.displayNoSavedGame();
        Character selectedCharacter =
            await inputService.chooseCharacter(characters);
        Monster firstMonster = monsters.first;
        gameState = GameState(selectedCharacter, firstMonster, characters);
        outputService.displayGameStatus(gameState);
        await mainGameLoop();
      }
      playAgain = inputService.askToRetry();
      if (playAgain) {
        await initialize();
      }
    }
  }

  // 캐릭터 로딩
  Future<void> loadCharacters() async {
    try {
      final file = File('data/characters.txt');
      final lines = await file.readAsLines();
      characters = lines.map((line) {
        final parts = line.split(',');
        return Character(
          parts[0],
          int.parse(parts[1]), // 체력
          int.parse(parts[2]), // 공격력
          int.parse(parts[3]), // 방어력
          [], // 스킬은 나중에 추가
        );
      }).toList();
    } catch (e) {
      print("캐릭터 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  // 몬스터 로딩
  Future<void> loadMonsters() async {
    try {
      final file = File('data/monsters.txt');
      final lines = await file.readAsLines();
      monsters = lines.map((line) {
        final parts = line.split(',');
        return Monster(
          parts[0],
          parts[1],
          int.parse(parts[2]), // 체력
          int.parse(parts[3]), // 최대 공격력
          int.parse(parts[4]), // 레벨
          [], // 스킬은 나중에 추가
        );
      }).toList();
    } catch (e) {
      print("몬스터 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  // 스킬 로딩
  Future<void> loadSkills() async {
    try {
      final file = File('data/skills.txt');
      final lines = await file.readAsLines();
      allSkills = lines.map((line) {
        final parts = line.split(',');
        return Skill(
          parts[0],
          int.parse(parts[1]), // 파워
          int.parse(parts[2]), // MP 소모량
        );
      }).toList();

      // 캐릭터와 몬스터에 랜덤 스킬 할당
      for (var character in characters) {
        character.skills = getRandomSkills(3);
      }

      for (var monster in monsters) {
        monster.skills = getRandomSkills(2);
      }
    } catch (e) {
      print("스킬 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  // 랜덤 스킬 선택
  List<Skill> getRandomSkills(int count) {
    final random = Random();
    return List.generate(
        count, (_) => allSkills[random.nextInt(allSkills.length)]);
  }

  // 게임 시작 카운트다운
  void startGame() {
    outputService.displayGameStart();
    for (int i = 5; i > 0; i--) {
      outputService.displayCountdown(i);
      sleep(Duration(seconds: 1));
    }

    outputService.displayMonsterAppearance(gameState.currentMonster.name);
    outputService.displayFirstAttacker(gameState.currentCharacter.name);
  }

  // 메인 게임 루프
  Future<void> mainGameLoop() async {
    while (!gameState.isGameOver) {
      outputService.displayGameStatus(gameState);

      final action = await inputService.getPlayerAction();

      if (await executeAction(action)) break;

      updateGameState();

      outputService.displayGameStatusChanges(gameState);

      endGame();
    }
  }

  // 플레이어 액션 실행
  Future<bool> executeAction(String action) async {
    switch (action) {
      case '1':
        await battleSystem.startBattle(
            gameState.currentCharacter, gameState.currentMonster);
        break;

      case '2':
        gameState.currentCharacter.defend();
        outputService.displayDefendAction(gameState.currentCharacter);
        break;

      case '3':
        gameState.currentCharacter.useItem();
        outputService.displayUseItemAction(gameState.currentCharacter);
        break;

      case 'reset':
        gameState.setGameOver();
        return true;

      default:
        outputService.displayInvalidActionMessage();
    }

    return false;
  }

  // 게임 상태 업데이트
  void updateGameState() {
    if (gameState.currentMonster.health <= 0) {
      outputService.displayMonsterDefeated(gameState.currentMonster);

      gameState.clearStage();

      int oldLevel = gameState.currentCharacter.level;

      gameState.levelUp();

      if (gameState.currentCharacter.level > oldLevel) {
        outputService.displayLevelUp(gameState.currentCharacter);

        enhanceRandomSkill(gameState.currentCharacter);

        if (inputService.askToSave()) {
          saveLoadService.saveGameState(gameState, playerName!);
          outputService.displayGameSaved();
        }

        if (monsters.isNotEmpty) {
          gameState.currentMonster =
              monsters[Random().nextInt(monsters.length)];

          // 몬스터의 레벨과 HP를 플레이어 레벨에 맞게 조정
          gameState.currentMonster.level = gameState.level;
          gameState.currentMonster.maxHealth = gameState.currentMonster
              .calculateScaledHealth(
                  gameState.currentMonster.maxHealth, gameState.level);

          gameState.currentMonster.health = gameState.currentMonster.maxHealth;
        } else {
          print("더 이상 몬스터가 없습니다. 게임 종료!");
          gameState.isGameOver = true;
        }
      }
    }

    if (gameState.currentCharacter.health <= 0) {
      gameState.isGameOver = true;
    }
  }

  // 랜덤 스킬 강화
  void enhanceRandomSkill(Character character) {
    if (character.skills.isEmpty) {
      outputService.displayNoSkillsAvailable();
      return;
    }

    Skill skillToEnhance =
        character.skills[Random().nextInt(character.skills.length)];

    character.enhanceSkill(skillToEnhance);
    outputService.displaySkillEnhanced(character, skillToEnhance);
  }

  // 새 스킬 추가
  void addNewSkill(Character character) {
    if (allSkills.isEmpty) {
      outputService.displayNoSkillsAvailable();
      return;
    }

    List<Skill> availableSkills =
        allSkills.where((skill) => !character.skills.contains(skill)).toList();

    if (availableSkills.isEmpty) {
      outputService.displayAllSkillsLearned();
      return;
    }

    Skill newSkill = availableSkills[Random().nextInt(availableSkills.length)];

    character.skills.add(newSkill);
    outputService.displayNewSkillLearned(character, newSkill);
  }

  Future<void> executeAttackChoice(Character character, Monster monster,
      InputService inputService, OutputService outputService) async {
    // Await the asynchronous call to getAttackChoice
    String? attackChoice = await inputService.getAttackChoice();

    if (attackChoice == '1') {
      // Basic attack
      character.attackMonster(monster, outputService);
    } else if (attackChoice == '2') {
      // Ensure character has skills
      if (character.skills.isNotEmpty) {
        int skillIndex = inputService.getSkillChoice(character.skills.length);
        Skill chosenSkill = character.skills[skillIndex];

        // Use skill
        bool success = character.useSkill(chosenSkill, monster);
        if (success) {
          outputService.displaySkillEnhanced(character, chosenSkill);
        } else {
          print("MP가 부족합니다."); // Not enough MP
        }
      } else {
        outputService.displayNoSkillsAvailable();
      }
    } else {
      print('올바른 선택지를 입력해주세요.'); // Invalid choice
    }
  }

  // 게임 종료 처리
  void endGame() {
    outputService.displayGameOverMessage();
    saveLoadService.saveGameResult(gameState);
  }
}
