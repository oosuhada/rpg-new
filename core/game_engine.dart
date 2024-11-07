// lib/core/game_engine.dart

import 'dart:io';
import 'dart:math';
import '../entities/character.dart';
import '../services/input_output.dart';
import '../services/save_load_service.dart';

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

  Future<void> initialize() async {
    try {
      saveLoadService = SaveLoadService();
      await loadCharacters();
      await loadMonsters();
      await loadSkills();
      await inputService.chooseLanguage();
      playerName = await inputService.getPlayerName();
      Character selectedCharacter =
          await inputService.chooseCharacter(characters);
      Monster firstMonster = monsters.first;
      gameState = GameState(selectedCharacter, firstMonster);
      battleSystem = BattleSystem(inputService, outputService);
    } catch (e) {
      print("초기화 중 오류가 발생했습니다: $e");
      exit(1);
    }
  }

  // 캐릭터 로딩 메서드
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

  // 몬스터 로딩 메서드
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

  // 스킬 로딩 메서드
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

  // 랜덤 스킬 선택 메서드
  List<Skill> getRandomSkills(int count) {
    final random = Random();
    return List.generate(
        count, (_) => allSkills[random.nextInt(allSkills.length)]);
  }

  Future<void> start() async {
    bool playAgain = true;
    while (playAgain) {
      outputService.displayWelcomeMessage(playerName!);
      GameState? loadedState = await saveLoadService.loadGameState(playerName!);
      if (loadedState != null) {
        gameState = loadedState;
        outputService.displayGameLoaded();
      } else {
        outputService.displayNoSavedGame();
        Character selectedCharacter =
            await inputService.chooseCharacter(characters);
        Monster firstMonster = monsters.first;
        gameState = GameState(selectedCharacter, firstMonster);
      }

      outputService.displayGameStatus(gameState);
      await mainGameLoop();
      playAgain = await inputService.askToRetry();
      if (playAgain) {
        await initialize();
      }
    }
  }

  Future<void> mainGameLoop() async {
    while (!gameState.isGameOver) {
      outputService.displayGameStatus(gameState);
      final action = await inputService.getPlayerAction();
      if (await executeAction(action)) {
        break;
      }
      updateGameState();
      outputService.displayGameStatusChanges(gameState);
    }
    endGame();
  }

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

  void updateGameState() {
    if (gameState.currentMonster.health <= 0) {
      outputService.displayMonsterDefeated(gameState.currentMonster);
      gameState.clearStage();
      int oldLevel = gameState.currentCharacter.level;
      gameState.levelUp();
      if (gameState.currentCharacter.level > oldLevel) {
        outputService.displayLevelUp(gameState.currentCharacter);
        addNewSkill(gameState.currentCharacter);
        if (inputService.askToSave()) {
          saveLoadService.saveGameState(gameState, playerName!);
          outputService.displayGameSaved();
        }
      }
      if (monsters.isNotEmpty) {
        gameState.currentMonster = monsters[Random().nextInt(monsters.length)];
      } else {
        print("더 이상 몬스터가 없습니다. 게임 종료!");
        gameState.isGameOver = true;
      }
    }
    if (gameState.currentCharacter.health <= 0) {
      gameState.isGameOver = true;
    }
  }

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

  void endGame() {
    outputService.displayGameOverMessage();
    saveLoadService.saveGameResult(gameState);
  }
}

class BattleSystem {
  final InputService inputService;
  final OutputService outputService;

  BattleSystem(this.inputService, this.outputService);

  Future<void> startBattle(Character character, Monster monster) async {
    outputService.displayBattleStart(character, monster);
    while (character.health > 0 && monster.health > 0) {
      // 플레이어 턴
      outputService.displayCharacterTurn(character);
      String action = await inputService.getPlayerAction();
      await executeAction(action, character, monster);
      if (monster.health <= 0) break;

      // 몬스터 턴
      outputService.displayMonsterTurn(monster);
      await monsterTurn(character, monster);
      if (character.health <= 0) break;

      outputService.displayBattleStatus(character, monster);
    }
    handleBattleResult(character, monster);
  }

  Future<void> executeAction(
      String action, Character character, Monster monster) async {
    switch (action) {
      case '1': // 일반 공격
        int damage = character.attack - monster.defense;
        if (damage < 0) damage = 0;
        monster.health -= damage;
        outputService.displayAttackResult(character, monster, damage);
        break;
      case '2': // 스킬 사용
        await useSkill(character, monster);
        break;
      case '3': // 아이템 사용
        character.useItem();
        outputService.displayUseItemAction(character);
        break;
      default:
        outputService.displayInvalidActionMessage();
    }
  }

  Future<void> useSkill(Character character, Monster monster) async {
    if (character.skills.isEmpty) {
      outputService.displayNoSkillsAvailable();
      return;
    }
    outputService.displaySkillList(character.skills);
    int skillIndex = await inputService.getSkillChoice(character.skills.length);
    if (skillIndex >= 0 && skillIndex < character.skills.length) {
      Skill selectedSkill = character.skills[skillIndex];
      if (character.useSkill(selectedSkill, monster)) {
        outputService.displaySkillUseResult(character, monster, selectedSkill);
      } else {
        outputService.displayNotEnoughMP();
      }
    } else {
      outputService.displayInvalidSkillChoice();
    }
  }

  Future<void> monsterTurn(Character character, Monster monster) async {
    if (monster.skills.isNotEmpty && Random().nextBool()) {
      // 50% 확률로 스킬 사용
      Skill selectedSkill =
          monster.skills[Random().nextInt(monster.skills.length)];
      int damage = monster.useSkill(selectedSkill, character);
      outputService.displayMonsterSkillUse(
          monster, character, selectedSkill, damage);
    } else {
      // 일반 공격
      int damage = monster.attack - character.defense;
      if (damage > 0) {
        character.health -= damage;
        outputService.displayAttackResult(monster, character, damage);
      } else {
        outputService.displayAttackResult(monster, character, 0);
      }
    }
  }

  void handleBattleResult(Character character, Monster monster) {
    if (character.health <= 0) {
      outputService.displayBattleLost(character.name);
    } else {
      outputService.displayBattleWon(character.name, monster.name);
    }
  }
}

class GameState {
  Character currentCharacter;
  Monster currentMonster;
  int level;
  int stage;
  bool isGameOver;

  GameState(this.currentCharacter, this.currentMonster,
      {this.level = 1, this.stage = 1, this.isGameOver = false});

  void levelUp() {
    level++;
    stage = 1;
    currentCharacter.levelUp();
  }

  void clearStage() {
    stage++;
  }

  void setGameOver() {
    isGameOver = true;
  }
}
