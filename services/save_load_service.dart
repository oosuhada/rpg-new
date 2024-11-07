// lib/services/save_load_service.dart

import 'dart:io';
import '../core/game_state.dart';
import '../entities/character.dart';
import '../entities/monster.dart';

class SaveLoadService {
  final String resultFilePath = 'data/result.txt'; // 게임 결과 파일 경로
  final String stateFilePath = 'data/game_state.txt'; // 게임 상태 파일 경로

  // 게임 결과 저장 메서드
  void saveGameResult(GameState gameState) {
    final file = File(resultFilePath);
    final sink = file.openWrite(mode: FileMode.append); // 파일에 추가 모드로 열기

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
    print('게임 결과가 저장되었습니다. / Game result has been saved.');
  }

  // 최근 게임 결과 로드 메서드
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

      return recentResults.reversed.toList(); // 최근 결과를 역순으로 반환
    } else {
      return []; // 파일이 존재하지 않으면 빈 리스트 반환
    }
  }

  // 최근 게임 결과 표시 메서드
  Future<void> displayRecentGameResults() async {
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

  // 게임 결과 초기화 메서드
  void clearGameResults() {
    final file = File(resultFilePath);
    file.writeAsStringSync(''); // 파일 내용을 비움
    print('게임 결과가 초기화되었습니다. / Game results have been cleared.');
  }

  // 게임 상태 저장 메서드 수정됨
  Future<void> saveGameState(GameState gameState, playerName) async {
    final file = File(stateFilePath);
    final sink = file.openWrite(mode: FileMode.write); // 파일에 쓰기 모드로 열기

    sink.writeln('GameState:');
    sink.writeln('Level: ${gameState.level}');
    sink.writeln('Stage: ${gameState.stage}');
    sink.writeln('IsGameOver: ${gameState.isGameOver}');
    sink.writeln('MonstersDefeated: ${gameState.monstersDefeated}');
    sink.writeln('ExperienceGained: ${gameState.experienceGained}');
    sink.writeln('PlayTime: ${gameState.playTime.inSeconds}');
    sink.writeln('CurrentCharacter: ${gameState.currentCharacter.serialize()}');
    sink.writeln('CurrentMonster: ${gameState.currentMonster.serialize()}');
    // 필요에 따라 추가 정보 직렬화

    sink.close();
    print('게임 상태가 저장되었습니다. / Game state has been saved.');
  }

  // 게임 상태 로드 메서드 수정됨
  GameState? loadGameState(
      List<Character> availableCharacters, List<Monster> availableMonsters) {
    final file = File(stateFilePath);
    if (!file.existsSync()) {
      return null; // 파일이 존재하지 않으면 null 반환
    }

    try {
      List<String> lines = file.readAsLinesSync();
      if (lines.isEmpty || !lines[0].startsWith('GameState:')) {
        return null; // 유효한 데이터가 없으면 null 반환
      }

      return GameState.deserialize(
          lines, availableCharacters, availableMonsters);
    } catch (e) {
      print("게임 상태 로딩 중 오류 발생: $e");
      return null; // 오류 발생 시 null 반환
    }
  }
}
