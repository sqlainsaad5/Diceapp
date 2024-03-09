import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(DiceApp());
}

class DiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DiceWithStateful(),
    );
  }
}

class DiceWithStateful extends StatefulWidget {
  @override
  State<DiceWithStateful> createState() => _DiceWithStatefulState();
}

class _DiceWithStatefulState extends State<DiceWithStateful> {
  int playerTurn = 0; // Current player's turn
  List<int> playersScores = [0, 0, 0, 0]; // Scores for each player
  List<int> dices = [1, 1, 1, 1]; // Values of dices
  List<String> playerNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4']; // Names of players
  int targetScore = 0; // Target score to win
  bool gameStarted = false; // Flag to track whether the game has started or not

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 2; i++)
                  Column(
                    children: [
                      for (int j = 0; j < 2; j++)
                        Row(
                          children: [
                            Text('${playerNames[i * 2 + j]}: '),
                            Column(
                              children: [
                                Text('${dices[i * 2 + j]}', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 10),
                                buildDice(i * 2 + j),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text('Player ${playerTurn + 1}\'s turn'),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Target Score'),
              onChanged: (value) {
                setState(() {
                  targetScore = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: targetScore > 0
                  ? () {
                // Toss to decide player turn and start the game
                setState(() {
                  playerTurn = Random().nextInt(4);
                  gameStarted = true;
                  if (playersScores[playerTurn] >= targetScore) {
                    _showWinnerDialog(playerTurn);
                  }
                });
              }
                  : null,
              child: Text('Toss and Start Game'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: gameStarted
                  ? () {
                setState(() {
                  // Reset the game
                  playerTurn = 0;
                  playersScores = List<int>.filled(4, 0);
                  dices = List<int>.filled(4, 1);
                  targetScore = 0;
                  gameStarted = false;
                });
              }
                  : null,
              child: Text('Reset Game'),
            ),
            SizedBox(height: 20),
            Text(
              'Scoreboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: playerNames.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${playerNames[index]}'),
                  trailing: Text('${playersScores[index]}'),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Winner: ${playerNames[playersScores.indexOf(playersScores.reduce(max))]}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildDice(int index) {
    return GestureDetector(
      onTap: gameStarted && playerTurn == index
          ? () {
        setState(() {
          // Roll the dice
          dices[index] = Random().nextInt(6) + 1;
          // If the dice is 0 or 6, roll again
          if (dices[index] == 0 || dices[index] == 6) {
            return;
          }
          // Add the number on the dice to the player's score
          playersScores[index] += dices[index];
          // Move to the next player
          playerTurn = (playerTurn + 1) % 4;
          if (playersScores[playerTurn] >= targetScore) {
            _showWinnerDialog(playerTurn);
          }
        });
      }
          : null,
      child: Image.asset(
        'images/d${dices[index]}.png',
        height: 80, // Adjust the height here to make the dice smaller
        width: 80, // Adjust the width here to make the dice smaller
      ),
    );
  }

  void _showWinnerDialog(int winnerIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Winner'),
          content: Text('Player ${winnerIndex + 1} wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
