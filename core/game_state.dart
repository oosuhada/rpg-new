// lib/core/game_state.dart

import '../entities/character.dart';
import '../entities/monster.dart';

class GameState {
  late Character currentCharacter;
  late Monster currentMonster;
  int level = 1;
  int stage = 1;
  bool isGameOver = false;

  void initialize(Character character, Monster monster) {
    currentCharacter = character;
    currentMonster = monster;
  }

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
