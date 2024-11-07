import 'dart:io';
import '../core/game_state.dart';

class SaveLoadService {
  final String saveFilePath = 'game_save.json';

  void saveGameState(GameState gameState) {
    try {
      final Map<String, dynamic> saveData = {
        'level': gameState.level,
        'stage': gameState.stage,
        'character': {
          'name': gameState.currentCharacter.name,
          'health': gameState.currentCharacter.health,
          'maxHealth': gameState.currentCharacter.maxHealth,
          'attack': gameState.currentCharacter.attack,
          'defense': gameState.currentCharacter.defense,
          'level': gameState.currentCharacter.level,
          'skills': gameState.currentCharacter.skills
              .map((skill) => {
                    'name': skill.name,
                    'power': skill.power,
                  })
              .toList(),
        },
        'monster': gameState.currentMonster != null
            ? {
                'name': gameState.currentMonster.name,
                'type': gameState.currentMonster.type,
                'health': gameState.currentMonster.health,
                'maxHealth': gameState.currentMonster.maxHealth,
                'attack': gameState.currentMonster.attack,
                'defense': gameState.currentMonster.defense,
              }
            : null,
      };

      final String jsonString = json.encode(saveData);
      File(saveFilePath).writeAsStringSync(jsonString);
      print('게임 상태가 성공적으로 저장되었습니다.');
    } catch (e) {
      print('게임 상태 저장 중 오류가 발생했습니다: $e');
    }
  }

  GameState? loadGameState() {
    try {
      if (!File(saveFilePath).existsSync()) {
        print('저장된 게임 상태가 없습니다.');
        return null;
      }

      final String jsonString = File(saveFilePath).readAsStringSync();
      final Map<String, dynamic> saveData = json.decode(jsonString);

      // 여기에 GameState 객체를 생성하고 반환하는 로직을 구현해야 합니다.
      // 이 부분은 GameState 클래스의 생성자나 팩토리 메서드를 사용하여 구현할 수 있습니다.

      print('게임 상태를 성공적으로 불러왔습니다.');
      return null; // 실제 구현에서는 GameState 객체를 반환해야 합니다.
    } catch (e) {
      print('게임 상태 불러오기 중 오류가 발생했습니다: $e');
      return null;
    }
  }

  void saveGameResult(GameState gameState) {
    final file = File(filePath);
    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln('게임 결과 / Game Result:');
    sink.writeln('캐릭터 / Character: ${gameState.currentCharacter.name}');
    sink.writeln('레벨 / Level: ${gameState.level}');
    sink.writeln('스테이지 / Stage: ${gameState.stage}');
    sink.writeln('---');
    sink.close();
  }

  Future<List<String>> loadGameResults() async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsLines();
    } else {
      return [];
    }
  }

  void displayGameResults() async {
    final results = await loadGameResults();
    if (results.isEmpty) {
      print('게임 결과가 없습니다. / No game results available.');
    } else {
      print('이전 게임 결과 / Previous Game Results:');
      for (var result in results) {
        print(result);
      }
    }
  }

  void clearGameResults() {
    final file = File(filePath);
    file.writeAsStringSync('');
    print('게임 결과가 초기화되었습니다. / Game results have been cleared.');
  }
}
