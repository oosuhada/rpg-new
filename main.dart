import 'core/game_engine.dart';
import 'services/input_output.dart';

void main() async {
  final inputService = InputService();
  final outputService = OutputService();
  final gameEngine = GameEngine(inputService, outputService);

  await gameEngine.initialize();
  await gameEngine.start();

  print('게임을 종료합니다. 이용해 주셔서 감사합니다!');
  print('Game over. Thank you for playing!');
}
