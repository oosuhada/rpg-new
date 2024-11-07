// lib/core/game_engine.dart

import 'dart:io';
import 'dart:math';
import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
import '../services/input_service.dart';
import '../services/output_service.dart';
import '../services/save_load_service.dart';
import '../core/game_state.dart';
import '../core/battle_system.dart';

class GameEngine {
  final InputService inputService;
  final OutputService outputService;
  late SaveLoadService saveLoadService;
  late GameState gameState;
  late BattleSystem battleSystem;
  List<Character> characters = [];
  List<Monster> monsters = [];
  List<Skill> allSkills = [];

  GameEngine(this.inputService, this.outputService);

  Future<void> initialize() async {
    try {
      saveLoadService = SaveLoadService();
      await loadCharacters();
      await loadMonsters();
      await inputService.chooseLanguage();

      Character selectedCharacter = await inputService.chooseCharacter();
      Monster firstMonster = monsters.first;

      gameState = GameState(selectedCharacter, firstMonster);
      battleSystem = BattleSystem(inputService, outputService);
    } catch (e) {
      print("초기화 중 오류가 발생했습니다: $e");
      exit(1);
    }
  }

  Future<void> loadCharacters() async {
    try {
      final file = File('data/characters.txt');
      final lines = await file.readAsLines();
      characters = lines.map((line) {
        final parts = line.split(',');
        return Character(
          parts[0],
          parts[1],
          int.parse(parts[2]),
          int.parse(parts[3]),
          int.parse(parts[4]),
          [], // 스킬은 나중에 추가
        );
      }).toList();
    } catch (e) {
      print("캐릭터 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  Future<void> loadMonsters() async {
    try {
      final file = File('data/monsters.txt');
      final lines = await file.readAsLines();
      monsters = lines
          .map((line) {
            final parts = line.split(',');
            if (parts.length < 5) {
              print("Warning: Invalid monster data: $line");
              return null;
            }
            List<Skill> monsterSkills = parts
                .sublist(5)
                .map((skillInfo) {
                  final skillParts = skillInfo.split(':');
                  if (skillParts.length < 3) {
                    print("Warning: Invalid skill data: $skillInfo");
                    return null;
                  }
                  return Skill(skillParts[0], int.parse(skillParts[1]));
                })
                .whereType<Skill>()
                .toList();

            return Monster(
              parts[0],
              parts[1],
              int.parse(parts[2]),
              int.parse(parts[3]),
              int.parse(parts[4]),
              monsterSkills,
            );
          })
          .whereType<Monster>()
          .toList();
    } catch (e) {
      print("몬스터 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  void start() {
    outputService.displayWelcomeMessage();

    if (inputService.askToLoadGame()) {
      GameState? loadedState = saveLoadService.loadGameState();
      if (loadedState != null) {
        gameState = loadedState;
        outputService.displayGameLoaded();
      }
    }

    outputService.displayGameStatus(gameState);
    mainGameLoop();
  }

  List<Skill> getRandomSkills(int count) {
    List<Skill> selectedSkills = [];
    for (int i = 0; i < count; i++) {
      selectedSkills.add(allSkills[Random().nextInt(allSkills.length)]);
    }
    return selectedSkills;
  }

  void mainGameLoop() {
    while (!gameState.isGameOver) {
      outputService.displayGameStatus(gameState);
      final action = inputService.getPlayerAction();
      if (executeAction(action)) {
        break; // 게임 종료 시 루프 탈출
      }
      updateGameState();
    }
    endGame();
  }

  bool executeAction(String action) {
    switch (action) {
      case '1':
        battleSystem.startBattle(
            gameState.currentCharacter, gameState.currentMonster);
        break;
      case '2':
        gameState.currentCharacter.defend();
        break;
      case '3':
        gameState.currentCharacter.useItem();
        break;
      case 'reset':
        gameState.setGameOver();
        return true; // 게임 종료 신호 반환
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
          saveLoadService.saveGameState(gameState);
          outputService.displayGameSaved();
        }
      }

      if (monsters.isNotEmpty) {
        gameState.currentMonster = monsters[Random().nextInt(monsters.length)];
      } else {
        print("No more monsters available. Game Over!");
        gameState.isGameOver = true;
      }
    }

    if (gameState.currentCharacter.health <= 0) {
      gameState.isGameOver = true;
    }
  }

  void addNewSkill(Character character) {
    if (allSkills.isEmpty) {
      print("No skills available to add.");
      return;
    }
    Skill newSkill = allSkills[Random().nextInt(allSkills.length)];
    character.skills.add(newSkill);
    outputService.displayNewSkillLearned(character, newSkill);
  }

  void endGame() {
    outputService.displayGameOverMessage();
    saveLoadService.saveGameResult(gameState);
    if (inputService.askToRetry()) {
      // 게임 재시작 로직
      initialize();
      start();
    } else {
      outputService.displayGameEndMessage();
      exit(0); // 프로그램 종료
    }
  }
}
