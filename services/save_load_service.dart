import 'dart:io';
import '../core/game_state.dart';

class SaveLoadService {
  final String filePath = '${Directory.current.path}/result.txt';

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
