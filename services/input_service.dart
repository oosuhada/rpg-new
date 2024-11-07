import 'dart:io';
import '../entities/character.dart';

class InputService {
  String currentLanguage = 'ko';

  Future<void> chooseLanguage() async {
    print('언어를 선택하세요 / Choose language:');
    print('1. 한국어');
    print('2. English');

    while (true) {
      String? choice = stdin.readLineSync()?.trim();
      switch (choice) {
        case '1':
          currentLanguage = 'ko';
          return;
        case '2':
          currentLanguage = 'en';
          return;
        default:
          print('올바른 번호를 입력해주세요. / Please enter a valid number.');
      }
    }
  }

  String getLocalizedText(String koText, String enText) {
    return currentLanguage == 'ko' ? koText : enText;
  }

  String getPlayerAction() {
    while (true) {
      try {
        stdout.write(getLocalizedText(
            "액션을 선택하세요 (1: 공격, 2: 방어, 3: 아이템 사용, reset: 게임 종료): ",
            "Choose an action (1: Attack, 2: Defend, 3: Use Item, reset: End Game): "));
        String? input = stdin.readLineSync()?.toLowerCase().trim();
        if (input == 'reset' || ['1', '2', '3'].contains(input)) return input!;
        print(getLocalizedText(
            '올바른 행동을 선택해주세요.', 'Please choose a valid action.'));
      } catch (e) {
        print(getLocalizedText("입력 처리 중 오류가 발생했습니다: $e",
            "An error occurred while processing input: $e"));
      }
    }
  }

  Future<bool> getYesNoAnswer() async {
    while (true) {
      String? answer = stdin.readLineSync()?.toLowerCase().trim();
      if (answer == 'y') return true;
      if (answer == 'n') return false;
      print(getLocalizedText('올바른 입력이 아닙니다. y 또는 n을 입력해주세요.',
          'Invalid input. Please enter y or n.'));
    }
  }

  Future<Character> chooseCharacter() async {
    List<String> characterLines =
        await File('data/characters.txt').readAsLines();
    List<Character> characters = [];
    print('\n${getLocalizedText('사용 가능한 캐릭터:', 'Available characters:')}');
    for (int i = 0; i < characterLines.length; i++) {
      List<String> stats = characterLines[i].split(',');
      if (stats.length == 5) {
        characters.add(Character(stats[0], stats[1], int.parse(stats[2]),
            int.parse(stats[3]), int.parse(stats[4]), []));
        print('${i + 1}. ${stats[0]} (${stats[1]})');
      }
    }

    while (true) {
      try {
        stdout.write(getLocalizedText('캐릭터를 선택하세요 (1-${characters.length}): ',
            'Choose your character (1-${characters.length}): '));
        String? choice = stdin.readLineSync()?.trim();
        int? index = int.tryParse(choice ?? '');
        if (index != null && index > 0 && index <= characters.length) {
          return characters[index - 1];
        }
        print(getLocalizedText(
            '올바른 번호를 입력해주세요.', 'Please enter a valid number.'));
      } catch (e) {
        print(getLocalizedText("캐릭터 선택 중 오류가 발생했습니다: $e",
            "An error occurred while choosing a character: $e"));
      }
    }
  }

  bool askToSave() {
    print("레벨업을 했습니다. 게임을 저장하시겠습니까? (y/n)");
    String response = stdin.readLineSync()?.toLowerCase() ?? 'n';
    return response == 'y';
  }

  bool askToRetry() {
    while (true) {
      try {
        stdout.write('게임을 다시 시작하시겠습니까? (y/n): ');
        String? input = stdin.readLineSync()?.toLowerCase().trim();
        if (input == 'y') return true;
        if (input == 'n') return false;
        print('올바른 입력을 해주세요 (y 또는 n).');
      } catch (e) {
        print("입력 처리 중 오류가 발생했습니다: $e");
      }
    }
  }
}
