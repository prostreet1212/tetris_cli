import 'dart:async';
import 'dart:io';

import '../ansi_cli_helper.dart' as ansi;
import 'blocks.dart';

const int heightBoard = 20; // высота игровой доски
const int widthBoard = 10; // ширина игровой доски

// тип заполнения ячеек игровой доски
const int posFree = 0; // свободное место
const int posFilled = 1; // заполненное место
const int posBoarder = 2; // граница

late List<List<int>> mainBoard; // основная доска
late List<List<int>> mainCpy; // копия основной доски
late List<List<int>> mblock; // блок c фигурой
late int x; // координата x
late int y; // координата y
bool _isGameOver = false; // игра окончена
int scoreGame = 0; // набранные очки

// подписка на получение нажатия клавиш
StreamSubscription? _subscription;

bool get isGameOver => _isGameOver;

// Функция отрисовки основной доски
void drawBoard() {
  ansi.gotoxy(0, 0); // устанавливаем курсор в начало
  for (int i = 0; i < heightBoard - 1; i++) {
    for (int j = 0; j < widthBoard - 1; j++) {
      switch (mainBoard[i][j]) {
        case posFree:
          stdout.write(' '); // пустое место
        case posFilled:
          stdout.write('O'); // заполненное место и фигура
        case posBoarder:
// устанавливаем красный цвет текста
          ansi.setTextColor(ansi.redTColor);
          stdout.write('#'); // граница доски
// возвращаем белый цвет
          ansi.setTextColor(ansi.whiteTColor);
      }
    }
    stdout.write('\n');
  }
}

// Функция очистки заполненных строк
void clearLine() {
  for (int j = 0; j <= heightBoard - 3; j++) {
// проверка заполненности строки
    int i = 1;
    while (i <= widthBoard - 3) {
      if (mainBoard[j][i] == posFree) {
        break;
      }
      i++;
    }
    if (i == widthBoard - 2) {
      // если строка заполнена
// очистка строки и сдвиг строк игровой доски вниз
      for (int k = j; k > 0; k--) {
        for (int idx = 1; idx <= widthBoard - 3; idx++) {
          mainBoard[k][idx] = mainBoard[k - 1][idx];
        }
      }
// увеличение очков
      scoreGame += 10;
    }
  }
}

// Функция генерации нового блока и добавления его на основную доску
void newBlock() {
// начальные координаты новой фигуры
  x = 4;
  y = 0;
  mblock = getNewBlock();
// добавляем новый блок на основную доску
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      mainBoard[i][x + j] = mainCpy[i][x + j] + mblock[i][j];
// проверка на пересечение
      if (mainBoard[i][x + j] > 1) {
        _isGameOver = true; // игра окончена
      }
    }
  }
}

// Функция перемещения фигуры по основной доске
void moveBlock(int x2, int y2) {
  // убираем фигуру с текущей позиции
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      if (x + j >= 0) {
        mainBoard[y + i][x + j] -= mblock[i][j];
      }
    }
  }
  // устанавливаем новую позицию
  x = x2;
  y = y2;
  // добавляем фигуру на новую позицию
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      if (x + j >= 0) {
        mainBoard[y + i][x + j] += mblock[i][j];
      }
    }
  }
  drawBoard();
}

// Функция проверки возможности сдвига блока в заданном направлении
bool isFilledBlock(int x2, int y2) {
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      if (mblock[i][j] != 0 && mainCpy[y2 + i][x2 + j] != 0) {
        return true;
      }
    }
  }
  return false;
}

// Функция обработки поворота блока
void rotateBlock() {
  // Временный блок с текущей фигурой
  List<List<int>> tmp = List.generate(4, (_) => List.filled(4, 0));
  // Заполняем временный блок
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      tmp[i][j] = mblock[i][j];
    }
  }
  // Поворачиваем фигуру
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      mblock[i][j] = tmp[3 - j][i];
    }
  }
// Проверка на то, что фигура не пересекается
  // с границей или другими блоками ранее помещенных на доску фигур
  if (isFilledBlock(x, y)) {
    // если есть пересечения, то возвращаем старую фигуру
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        mblock[i][j] = tmp[i][j];
      }
    }
  }
  // Обновляем основную доску
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      // Убираем старую фигуру
      mainBoard[y + i][x + j] -= tmp[i][j];
      // Добавляем новую фигуру
      mainBoard[y + i][x + j] += mblock[i][j];
    }
  }
  drawBoard();
}

void savePresentBoardToCpy() {
  for (int i = 0; i < heightBoard - 1; i++) {
    for (int j = 0; j < widthBoard - 1; j++) {
      mainCpy[i][j] = mainBoard[i][j];
    }
  }
}

// Функция для обработки нажатия клавиш
void controlUserInput() {
  stdin.echoMode = false;
  stdin.lineMode = false;
  _subscription = stdin.listen((data) {
    int key = data.first;
    switch (key) {
      case 119: // W — поворот фигуры
        rotateBlock();
      case 97: // A — влево
        if (!isFilledBlock(x - 1, y)) {
          moveBlock(x - 1, y);
        }
      case 115: // S — вниз
        if (!isFilledBlock(x, y + 1)) {
          moveBlock(x, y + 1);
        }
      case 100: // D — вправо
        if (!isFilledBlock(x + 1, y)) {
          moveBlock(x + 1, y);
        }
    }
  });
}
