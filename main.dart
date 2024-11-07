import 'core/game_engine.dart';
import 'services/input_service.dart';
import 'services/output_service.dart';

void main() async {
  final inputService = InputService();
  final outputService = OutputService();
  final gameEngine = GameEngine(inputService, outputService);

  await gameEngine.initialize();

  bool playAgain = true;
  while (playAgain) {
    gameEngine.start();
    playAgain = await inputService.askToRetry();
  }

  print('게임을 종료합니다. 이용해 주셔서 감사합니다!');
  print('Game over. Thank you for playing!');
}
