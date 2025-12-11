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
    if (i == widthBoard - 2) { // если строка заполнена
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

