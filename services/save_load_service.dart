// lib/services/save_load_service.dart

import 'dart:io';
import '../core/game_engine.dart';
import '../entities/character.dart';
import '../services/input_output.dart';

class SaveLoadService {
  final String resultFilePath = 'data/result.txt';

  void saveGameResult(GameState gameState) {
    final file = File(resultFilePath);
    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln('게임 결과 / Game Result:');
    sink.writeln('캐릭터 / Character: ${gameState.currentCharacter.name}');
    sink.writeln('레벨 / Level: ${gameState.level}');
    sink.writeln('스테이지 / Stage: ${gameState.stage}');
    sink.writeln('플레이 시간 / Play Time: ${gameState.playTime}');
    sink.writeln(
        '처치한 몬스터 수 / Monsters Defeated: ${gameState.monstersDefeated}');
    sink.writeln('획득한 경험치 / Experience Gained: ${gameState.experienceGained}');
    sink.writeln('---');
    sink.close();
  }

  // 최근 게임 결과 로드
  Future<List<String>> loadRecentGameResults() async {
    final file = File(resultFilePath);
    if (await file.exists()) {
      List<String> allLines = await file.readAsLines();
      List<String> recentResults = [];
      int count = 0;
      for (int i = allLines.length - 1; i >= 0 && count < 5; i--) {
        if (allLines[i].startsWith('게임 결과 / Game Result:')) {
          recentResults.add(allLines[i]);
          recentResults.add(allLines[i + 1]);
          recentResults.add(allLines[i + 2]);
          recentResults.add(allLines[i + 3]);
          recentResults.add('---');
          count++;
        }
      }
      return recentResults.reversed.toList();
    } else {
      return [];
    }
  }

  // 최근 게임 결과 표시
  void displayRecentGameResults() async {
    final results = await loadRecentGameResults();
    if (results.isEmpty) {
      print('게임 결과가 없습니다. / No game results available.');
    } else {
      print('최근 5개 게임 결과 / Recent 5 Game Results:');
      for (var result in results) {
        print(result);
      }
    }
  }

  // 게임 결과 초기화
  void clearGameResults() {
    final file = File(resultFilePath);
    file.writeAsStringSync('');
    print('게임 결과가 초기화되었습니다. / Game results have been cleared.');
  }

  // 게임 상태 저장
  void saveGameState(GameState gameState, String playerName) {
    final file = File('data/result.txt');
    final sink = file.openWrite(mode: FileMode.write);
    sink.writeln('게임 상태 / Game State:');
    sink.writeln('플레이어 / Player: $playerName');
    sink.writeln('캐릭터 / Character: ${gameState.currentCharacter.name}');
    sink.writeln('레벨 / Level: ${gameState.level}');
    sink.writeln('스테이지 / Stage: ${gameState.stage}');
    sink.writeln('체력 / Health: ${gameState.currentCharacter.health}');
    sink.writeln('---');
    sink.close();
    print('게임 상태가 저장되었습니다. / Game state has been saved.');
  }

  // 게임 상태 로드
  GameState? loadGameState(String playerName) {
    final file = File(resultFilePath);
    if (!file.existsSync()) {
      return null;
    }

    try {
      List<String> lines = file.readAsLinesSync();
      if (lines.isEmpty || !lines[0].startsWith('게임 상태 / Game State:')) {
        return null;
      }

      String? savedPlayerName;
      String? characterName;
      int level = 1;
      int stage = 1;
      int health = 100;
      for (String line in lines) {
        if (line.startsWith('플레이어 / Player:')) {
          savedPlayerName = line.split(':')[1].trim();
        } else if (line.startsWith('캐릭터 / Character:')) {
          characterName = line.split(':')[1].trim();
        } else if (line.startsWith('레벨 / Level:')) {
          level = int.parse(line.split(':')[1].trim());
        } else if (line.startsWith('스테이지 / Stage:')) {
          stage = int.parse(line.split(':')[1].trim());
        } else if (line.startsWith('체력 / Health:')) {
          health = int.parse(line.split(':')[1].trim());
        }
      }

      if (savedPlayerName != playerName) {
        return null;
      }

      if (characterName != null) {
        Character character = Character(characterName, health, 10, 5, []);
        Monster dummyMonster = Monster('Dummy', 'Normal', 50, 10, 1, []);
        GameState loadedState = GameState(character, dummyMonster);
        loadedState.level = level;
        loadedState.stage = stage;
        return loadedState;
      } else {
        return null;
      }
    } catch (e) {
      print("게임 상태 로딩 중 오류 발생: $e");
      return null;
    }
  }
}
