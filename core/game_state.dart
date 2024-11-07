// lib/core/game_state.dart

import '../entities/character.dart';
import '../entities/monster.dart';

class GameState {
  Character currentCharacter;
  Monster currentMonster;
  List<Character> characters;
  int level;
  int stage;
  bool isGameOver;
  int monstersDefeated;
  int experienceGained;
  Duration playTime;

  GameState(
    this.currentCharacter,
    this.currentMonster,
    this.characters, {
    this.level = 1,
    this.stage = 1,
    this.isGameOver = false,
    this.monstersDefeated = 0,
    this.experienceGained = 0,
    Duration? playTime,
  }) : playTime = playTime ?? Duration.zero;

  /// 게임 종료 상태로 설정
  void setGameOver() {
    isGameOver = true;
  }

  /// 스테이지를 클리어하고 다음 스테이지로 진행
  void clearStage() {
    stage++;
    monstersDefeated++;
  }

  /// 플레이어 레벨을 올리고 경험치를 추가
  void levelUp() {
    currentCharacter.levelUp();
    level++;
    experienceGained += 100; // 예시 값, 필요에 따라 조정 가능
  }

  /// 플레이 시간을 업데이트
  void updatePlayTime(Duration duration) {
    playTime += duration;
  }

  /// 현재 게임 상태를 초기화
  void reset() {
    level = 1;
    stage = 1;
    isGameOver = false;
    monstersDefeated = 0;
    experienceGained = 0;
    playTime = Duration.zero;
    // 필요에 따라 캐릭터와 몬스터 초기화
    if (characters.isNotEmpty) {
      currentCharacter = characters.first;
    }
    // 예시로 첫 번째 몬스터로 초기화, 실제 로직에 맞게 수정 필요
    if (currentMonster != null) {
      currentMonster = Monster(
        currentMonster.name,
        currentMonster.type,
        currentMonster.maxHealth,
        currentMonster.attack,
        currentMonster.level,
        currentMonster.skills,
      );
    }
  }

  /// 게임 상태를 문자열로 직렬화 (저장 시 사용)
  String serialize() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('GameState:');
    buffer.writeln('Level: $level');
    buffer.writeln('Stage: $stage');
    buffer.writeln('IsGameOver: $isGameOver');
    buffer.writeln('MonstersDefeated: $monstersDefeated');
    buffer.writeln('ExperienceGained: $experienceGained');
    buffer.writeln('PlayTime: ${playTime.inSeconds}');
    buffer.writeln('CurrentCharacter: ${currentCharacter.serialize()}');
    buffer.writeln('CurrentMonster: ${currentMonster.serialize()}');
    // 필요에 따라 추가 정보 직렬화
    return buffer.toString();
  }

  /// 문자열로부터 게임 상태를 역직렬화 (로드 시 사용)
  static GameState deserialize(List<String> lines,
      List<Character> availableCharacters, List<Monster> availableMonsters) {
    int level = 1;
    int stage = 1;
    bool isGameOver = false;
    int monstersDefeated = 0;
    int experienceGained = 0;
    Duration playTime = Duration.zero;
    Character? currentCharacter;
    Monster? currentMonster;

    for (String line in lines) {
      if (line.startsWith('Level:')) {
        level = int.parse(line.split(':')[1].trim());
      } else if (line.startsWith('Stage:')) {
        stage = int.parse(line.split(':')[1].trim());
      } else if (line.startsWith('IsGameOver:')) {
        isGameOver = line.split(':')[1].trim().toLowerCase() == 'true';
      } else if (line.startsWith('MonstersDefeated:')) {
        monstersDefeated = int.parse(line.split(':')[1].trim());
      } else if (line.startsWith('ExperienceGained:')) {
        experienceGained = int.parse(line.split(':')[1].trim());
      } else if (line.startsWith('PlayTime:')) {
        playTime = Duration(seconds: int.parse(line.split(':')[1].trim()));
      } else if (line.startsWith('CurrentCharacter:')) {
        String characterData = line.split(':')[1].trim();
        currentCharacter = Character.deserialize(characterData);
      } else if (line.startsWith('CurrentMonster:')) {
        String monsterData = line.split(':')[1].trim();
        currentMonster = Monster.deserialize(monsterData);
      }
      // 필요에 따라 추가 정보 역직렬화
    }

    return GameState(
      currentCharacter ?? availableCharacters.first,
      currentMonster ?? availableMonsters.first,
      availableCharacters,
      level: level,
      stage: stage,
      isGameOver: isGameOver,
      monstersDefeated: monstersDefeated,
      experienceGained: experienceGained,
      playTime: playTime,
    );
  }
}
