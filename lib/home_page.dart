import 'dart:async';

import 'package:boomseeker/my_helper.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // bomb seeker variable
  int numberInRow = 8;
  int numberOfSquare = 8 * 8;

  var squareStat = []; // [number of bomb around it, is reveal? = true / false]
  var squareMarked = [];

  List<int> bombPos = [0, 1, 2, 4, 9, 11, 20, 69, 70];
  int bombCount = 12 ;
  bool isAllBombsRevealed = false;

  int time = 0;
  late Timer timer = Timer.periodic(Duration(seconds: 1), (timer) {});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bool isAllBombsRevealed = false;

    // init square in grid with 0 bomb around and not revealed
    for(int i = 0; i < numberOfSquare; i++) {
      squareStat.add([0, false]);
      squareMarked.add(false);
    }

    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        time++;
      });
    });

    randomizeBomb();
    scanBombs();
  }

  void randomizeBomb(){
    var rng = Random();
    bombPos = [];
    int bombs = 0;
    while(true) {
      int randNumb = rng.nextInt(numberOfSquare);
      if(!bombPos.contains(randNumb)) {
        bombPos.add(randNumb);
        bombs++;
      }
      if(bombs == bombCount) {
        break;
      }
    }
  }

  void revealBoxNumber(int index) {
    // reveal the box if it has a number (has bomb around)
    if(squareStat[index][0] != 0)
    {
      setState(() {
        squareStat[index][1] = true;
      });
    }
    // reveal the box and the surrounding if it has no number (no bomb around)
    else {
      // only need to recursively call topleft, left, bottomleft and right
      // because the left will call the right
      setState(() {
        // reveal current box
        squareStat[index][1] = true;

        // reveal box on the left if index is not on the left wall
        if( index % numberInRow != 0){
          if(squareStat[index-1][0] == 0 && squareStat[index-1][1] == false) {
            revealBoxNumber(index - 1);
          }

          // reveal the left box (in case the left box has number)
          // if next box has no number, this will be call anyway
          squareStat[index - 1][1] = true;
        }

        // reveal box on the top left if index is not on the top left
        if( index % numberInRow != 0 && index >= numberInRow){
          if(squareStat[index-1-numberInRow][0] == 0 &&
              squareStat[index-1-numberInRow][1] == false) {
            revealBoxNumber(index - 1 - numberInRow);
          }
          squareStat[index - 1 - numberInRow][1] = true;
        }

        // reveal box on the top if index is not on the bottom
        if(index >= numberInRow){
          if(squareStat[index - numberInRow][0] == 0 &&
              squareStat[index - numberInRow][1] == false) {
            revealBoxNumber(index - numberInRow);
          }
          squareStat[index - numberInRow][1] = true;
        }

        // reveal box on the bottom left if index is not on the top left
        if( index % numberInRow != 0 && index <= numberOfSquare -  numberInRow){
          if(squareStat[index-1+numberInRow][0] == 0 &&
              squareStat[index-1+numberInRow][1] == false) {
            revealBoxNumber(index - 1 + numberInRow);
          }
          squareStat[index - 1 + numberInRow][1] = true;
        }

        // reveal box on the bottom if index is not on the bottom
        if(index < numberOfSquare -  numberInRow){
          if(squareStat[index+numberInRow][0] == 0 &&
              squareStat[index+numberInRow][1] == false) {
            revealBoxNumber(index + numberInRow);
          }
          squareStat[index + numberInRow][1] = true;
        }

        // reveal box on the right if index is not on the right wall
        if( index % numberInRow != (numberInRow - 1)){
          if(squareStat[index+1][0] == 0 && squareStat[index+1][1] == false) {
            revealBoxNumber(index + 1);
          }
          squareStat[index + 1][1] = true;
        }
      });
    }
  }

  void markBoxNumber(index) {
    squareMarked[index] = true;
  }

  void scanBombs() {
    for (int i = 0; i < numberOfSquare; i ++) {
      int numberOfBombAround = 0;

      /*
      * for each square, there are 8 square around need to check
      */

      // check square on the left unless its on the 1st column (% numberInRow == 0)
      if(bombPos.contains(i-1) && i % numberInRow != 0){
        numberOfBombAround++;
      }

      // top left to the square at i
      if(bombPos.contains(i - 1 - numberInRow)
          && i > numberInRow
          && i % numberInRow != 0
      ) {
        numberOfBombAround++;
      }

      // check square above
      if(bombPos.contains(i - numberInRow) && i >= numberInRow) {
        numberOfBombAround++;
      }

      // check top right square
      if(bombPos.contains(i - numberInRow + 1)
          && i >= numberInRow
          && i % numberInRow != (numberInRow - 1)
      ){
        numberOfBombAround++;
      }

      // check right square
      if(bombPos.contains(i+1) && i % numberInRow != (numberInRow - 1)) {
        numberOfBombAround++;
      }

      //check bottom right
      if(bombPos.contains(i + 1 + numberInRow)
          && i % numberInRow != (numberInRow - 1)
          && i < numberOfSquare - numberInRow
      ) {
        numberOfBombAround++;
      }

      //check bottom
      if(bombPos.contains(i + numberInRow) && i < numberOfSquare - numberInRow
      ) {
        numberOfBombAround++;
      }

      //check bottom left
      if(bombPos.contains(i - 1 + numberInRow)
          && i < numberOfSquare - numberInRow
          && i % numberInRow != 0
      ) {
        numberOfBombAround++;
      }

      setState(() {
        squareStat[i][0] = numberOfBombAround;
      });
    }
  }

  void playerLost() {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Center(child: Text("👎 Y O U   L O S T ! 👎", style: TextStyle(color: Colors.white),),),
        actions: [
          MaterialButton(
            onPressed: (){
              restartGame();
              Navigator.pop(context);
            },
            color: Colors.white,
            child: const Icon(Icons.refresh),
          )
        ],
      );
    });
  }

  void playerWon() {
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Center(child: Text("👏 Y O U   W O N ! 👏", style: TextStyle(color: Colors.white),),),
        actions: [
          MaterialButton(
            onPressed: (){
              restartGame();
              Navigator.pop(context);
            },
            color: Colors.white,
            child: const Icon(Icons.refresh),
          )
        ],
      );
    });
  }

  void countUnrevealedBox() {
    int countUnrevealed = 0;
    for (int i = 0; i < numberOfSquare; i++) {
      if(squareStat[i][1] == false){
        countUnrevealed++;
      }
    }

    if(countUnrevealed == bombPos.length) {
      playerWon();
    }
  }

  void restartGame(){
    setState((){
      isAllBombsRevealed = false;
      for(int i = 0 ; i < numberOfSquare; i ++) {
        squareStat[i][1] = false;
        squareMarked[i] = false;
      }

      time = 0;

      randomizeBomb();
      scanBombs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyHelper.titleBG,
      body: SafeArea(
        child: Column(
          children: [
            // game stat
            Container(
              height: 150,
              color: MyHelper.titleBG,
              child: Column(
                children: [
                  Text("b o o m s e e k e r", style: MyHelper.titleTextStyle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Text("${bombPos.length}", style: TextStyle(fontSize: 40),),
                            Text("B O M B S", style: MyHelper.titleTextStyle,)
                          ],
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: restartGame,
                          child: Card(
                            child: const Icon(Icons.refresh_outlined, color: Colors.white, size: 40,),
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10,),
                            Text(time.toString(), style: TextStyle(fontSize: 40),),
                            Text("T I M E", style: MyHelper.titleTextStyle,)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // grid
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: MyHelper.gridBG,
                ),
                child: Center(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: numberOfSquare,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: numberInRow,
                    ),
                    itemBuilder: (context, index) {
                      if (bombPos.contains(index)) {
                        return BombBox(
                          isRevealed: isAllBombsRevealed,
                          revealFunction: () {
                            // player taps on a bomb
                            setState( () {
                              isAllBombsRevealed = true;
                              squareMarked[index] = false;
                            } );
                            playerLost();
                          },
                          isMarked: squareMarked[index],
                          markFunction: () {
                            setState((){
                              markBoxNumber(index);
                            });
                          },
                        );
                      }
                      return NumberedBox(
                        child: squareStat[index][0],
                        isRevealed: squareStat[index][1],
                        revealFunction: () {
                          // player taps on a normal square
                          revealBoxNumber(index);
                          countUnrevealedBox();
                          squareMarked[index] = false;
                        },
                        isMarked: squareMarked[index],
                        markFunction: () {
                          setState((){
                            markBoxNumber(index);
                          });
                        },
                      );
                    }
                  ),
                ),
              )
            ),

            // some text
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("created by tung and he likes milktea", style: TextStyle(fontSize: 18),),
            )
          ],
        ),
      )
    );
  }
}

class NumberedBox extends StatelessWidget {

  final int child;
  final bool isRevealed;
  bool isMarked;
  final VoidCallback revealFunction;
  final VoidCallback markFunction;

  NumberedBox({
    Key? key,
    required this.child,
    required this.isRevealed,
    required this.revealFunction,
    required this.isMarked,
    required this.markFunction,
  }) : super(key: key);

  Color getColorForNumberedBox(int number) {
    switch(number){
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.deepPurple;
      case 6:
        return Colors.lightGreen;
      case 7:
        return Colors.brown;
      case 8:
        return Colors.black45;
      default:
        return Colors.black;
    }
  }

  drawChild() {
    if(isMarked) {
      return Text("!",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
      );
    } else if (isRevealed) {
      return Text(
        ( child != 0 ? child.toString() : ""),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: getColorForNumberedBox(child)),
      );
    } else {
      return const Text("");
    }
  }

  drawColor() {
    if(isMarked) {
      return MyHelper.markedColor;
    } else if(isRevealed) {
      return MyHelper.revealedColor;
    }
    return MyHelper.unrevealedColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: revealFunction,
      onLongPress: markFunction,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: drawColor()
          ),
          child: Center(
              child: drawChild(),
          ),
        )
      ),
    );
  }
}

class BombBox extends StatelessWidget
{

  final bool isRevealed;
  bool isMarked;
  final VoidCallback revealFunction;
  final VoidCallback markFunction;

  BombBox({
    Key? key,
    required this.isRevealed,
    required this.revealFunction,
    required this.isMarked,
    required this.markFunction
  }) : super(key: key);

  drawChild() {
    if(isMarked){
      return const Text(
          "!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,)
      );
    } else if (isRevealed) {
      return Text(isRevealed ? "Ố" : "", style: MyHelper.myTextStyle);
    }
    return Text("");
  }

  drawColor() {
    if(isMarked) {
      return MyHelper.markedColor;
    } else if(isRevealed) {
      return MyHelper.bombRed;
    }
    return MyHelper.unrevealedColor;
  }

  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: revealFunction,
      onLongPress: markFunction,
      child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: drawColor(),
            ),
            child: Center(child: drawChild()),
          )
      ),
    );
  }

}