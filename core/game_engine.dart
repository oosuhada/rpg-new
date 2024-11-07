// lib/core/game_engine.dart

import 'dart:io';
import 'dart:math';
import '../entities/character.dart';
import '../entities/monster.dart';
import '../entities/skill.dart';
import '../services/input_service.dart';
import '../services/output_service.dart';
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

  GameEngine(this.inputService, this.outputService) {
    saveLoadService = SaveLoadService();
    gameState = GameState();
    battleSystem = BattleSystem(inputService, outputService);
  }

  Future<void> initialize() async {
    try {
      await loadCharacters();
      await loadMonsters();
      await inputService.chooseLanguage();
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
      monsters = lines.map((line) {
        final parts = line.split(',');
        final monsterSkills = parts.sublist(5).map((skillInfo) {
          final skillParts = skillInfo.split(':');
          return Skill(skillParts[0], int.parse(skillParts[1]));
        }).toList();
        allSkills.addAll(monsterSkills);
        return Monster(
          parts[0],
          parts[1],
          int.parse(parts[2]),
          int.parse(parts[3]),
          int.parse(parts[4]),
          monsterSkills,
        );
      }).toList();
    } catch (e) {
      print("몬스터 로딩 중 오류가 발생했습니다: $e");
      throw e;
    }
  }

  List<Skill> getRandomSkills(int count) {
    List<Skill> selectedSkills = [];
    for (int i = 0; i < count; i++) {
      selectedSkills.add(allSkills[Random().nextInt(allSkills.length)]);
    }
    return selectedSkills;
  }

  void start() {
    outputService.displayWelcomeMessage();
    mainGameLoop();
  }

  void mainGameLoop() {
    while (!gameState.isGameOver) {
      outputService.displayGameStatus(gameState);
      final action = inputService.getPlayerAction();
      executeAction(action);
      updateGameState();
    }
    endGame();
  }

  void executeAction(String action) {
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
        break;
    }
  }

  void updateGameState() {
    if (gameState.currentMonster.health <= 0) {
      outputService.displayMonsterDefeated(gameState.currentMonster);
      gameState.clearStage();
      if (gameState.stage > 3) {
        gameState.levelUp();
        outputService.displayLevelUp(gameState.currentCharacter);
        addNewSkill(gameState.currentCharacter);
      }
      gameState.currentMonster = monsters[gameState.level - 1];
    }

    if (gameState.currentCharacter.health <= 0) {
      gameState.setGameOver();
    }
  }

  void addNewSkill(Character character) {
    Skill newSkill = allSkills[Random().nextInt(allSkills.length)];
    character.skills.add(newSkill);
    outputService.displayNewSkillLearned(character, newSkill);
  }

  void endGame() {
    outputService.displayGameOverMessage();
    saveLoadService.saveGameResult(gameState);
  }
}
