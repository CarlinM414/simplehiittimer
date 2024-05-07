// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:soundpool/soundpool.dart';

ThemeData appTheme = ThemeData(
   appBarTheme: AppBarTheme(
    backgroundColor: Colors.redAccent[700],
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  dialogTheme: DialogTheme(
    titleTextStyle: TextStyle(fontSize: 20, color: Colors.black,),
    contentTextStyle: TextStyle(fontSize: 18, color: Colors.black,),
    
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 18,
      color: Colors.grey[900],
    ),
    
  ),
  sliderTheme: SliderThemeData (
    activeTrackColor: Colors.redAccent[700],
    valueIndicatorColor:Colors.redAccent[700],
    thumbColor: Colors.redAccent[700],
    inactiveTrackColor: Colors.black,
  ),
  textTheme: TextTheme (
    labelLarge: TextStyle(
      fontSize: 24,
      color: Colors.black,
    ),
    labelMedium: TextStyle(
      color: Colors.white,
      fontSize: 24 ),
    bodyMedium: TextStyle(
      fontSize: 32,
      color: Colors.black,
      ),
      bodySmall: TextStyle(
      fontSize: 20,
      color: Colors.black,
      ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.redAccent[700],
    ),
  ),
);

void main() {
  runApp(MaterialApp(
    title: 'HIIT Timer',
    theme: appTheme,
    home: InputScreen(),
  ));
}

class SoundManager {
  final Soundpool _soundPool = Soundpool.fromOptions(
      options: SoundpoolOptions(streamType: StreamType.notification));
  final Map<String, int> _soundIds = {};

  Future<void> loadSounds(List<String> soundPaths) async {
    for (String path in soundPaths) {
      ByteData soundData = await rootBundle.load(path);
      int soundId = await _soundPool.load(soundData);
      _soundIds[path] = soundId;
    }
  }

  // Play a specific sound by its path
  Future<void> playSound(String soundPath) async {
    int? soundId = _soundIds[soundPath];
    if (soundId != null) {
      await _soundPool.play(soundId);
    }
  }

  // Stop a specific sound
  void stopSound(String soundPath) {
    int? soundId = _soundIds[soundPath];
    if (soundId != null) {
      _soundPool.stop(soundId);
    }
  }

  // Release resources
  void dispose() {
    _soundPool.release();
  }
}

class WorkoutSettings {
  int numberOfRounds;
  int breakBetweenRounds;
  int numberOfSetsPerRound;
  int lengthOfEachSet;
  int restBetweenSets;

  WorkoutSettings({
    required this.numberOfRounds,
    required this.breakBetweenRounds,
    required this.numberOfSetsPerRound,
    required this.lengthOfEachSet,
    required this.restBetweenSets,
  });
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _settings = WorkoutSettings(
    numberOfRounds: 5,
    breakBetweenRounds: 90,
    numberOfSetsPerRound: 5,
    lengthOfEachSet: 30,
    restBetweenSets: 10,
  );
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your HIIT Workout'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Number of Rounds (${_settings.numberOfRounds} rounds)', style: appTheme.textTheme.bodySmall),
              Slider.adaptive(
                value: _settings.numberOfRounds.toDouble(),
                min: 1,
                max: 10,
                divisions: 10,
                label: '${_settings.numberOfRounds} rounds',
                onChanged: (double value) {
                 setState(() {
                    _settings.numberOfRounds = value.toInt();
                 });
                },
              ),
              Text('Length of Break (${_settings.breakBetweenRounds} seconds)', style: appTheme.textTheme.bodySmall),
              Slider.adaptive(
                value: _settings.breakBetweenRounds.toDouble(),
                min: 1,
                max: 120,
                divisions: 12,
                label: '${_settings.breakBetweenRounds} seconds',
                onChanged: (double value) {
                 setState(() {
                    _settings.breakBetweenRounds = value.toInt();
                 });
                },
              ),
              Text('Number of Sets Per Round (${_settings.numberOfSetsPerRound} sets)', style: appTheme.textTheme.bodySmall),
              Slider.adaptive(
                value: _settings.numberOfSetsPerRound.toDouble(),
                min: 1,
                max: 10,
                divisions: 10,
                label: '${_settings.numberOfSetsPerRound} sets',
                onChanged: (double value) {
                 setState(() {
                    _settings.numberOfSetsPerRound = value.toInt();
                 });
                },
              ),
              Text('Length of Each Set (${_settings.lengthOfEachSet} seconds)', style: appTheme.textTheme.bodySmall),
              Slider.adaptive(
                value: _settings.lengthOfEachSet.toDouble(),
                min: 1,
                max: 60,
                divisions: 6,
                label: '${_settings.lengthOfEachSet} seconds',
                onChanged: (double value) {
                 setState(() {
                    _settings.lengthOfEachSet = value.toInt();
                 });
                },
              ),
              Text('Rest Between Sets (${_settings.restBetweenSets} seconds)', style: appTheme.textTheme.bodySmall),
              Slider.adaptive(
                value: _settings.restBetweenSets.toDouble(),
                min: 1,
                max: 60,
                divisions: 6,
                label: '${_settings.restBetweenSets} seconds',
                onChanged: (double value) {
                 setState(() {
                    _settings.restBetweenSets = value.toInt();
                 });
                },
              ),
              SizedBox(height: 20),
                ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Navigate to the timer screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerScreen(settings: _settings),
                      ),
                    );
                  }
                },
                child: const Text('Start Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WorkoutSettings settings;
  const TimerScreen({super.key, required this.settings});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int currentRound;
  late int currentSet;
  late int timeLeft;
  late Timer timer;
  late bool isResting;
  late bool isBreakTime;
  late bool isPaused;
  late bool isComplete;
  int countdownTime = 5;
  late ConfettiController _confettiController;
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _soundManager.loadSounds([
      'assets/sounds/start_iris_1.mp3',
      'assets/sounds/break_iris_1.mp3',
      'assets/sounds/rest_iris_1.mp3',
      'assets/sounds/five_down_iris_1.mp3',
      'assets/sounds/finish_iris_1.mp3',
      'assets/sounds/last_round_iris_1.mp3',
      'assets/sounds/last_set_iris_1.mp3',
    ]);
    currentRound = 1;
    currentSet = 1;
    isResting = false;
    isBreakTime = false;
    isPaused = false;
    isComplete = false;
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 30));
    startCountdown();
  }

  void startSetTimer() {
    _soundManager.playSound('assets/sounds/start_iris_1.mp3');
    setState(() {
      isResting = false;
      timeLeft = widget.settings.lengthOfEachSet;
    });
    if (currentRound == widget.settings.numberOfRounds) {
      if (currentSet == 1) {
        _soundManager.playSound('assets/sounds/last_round_iris_1.mp3');
      } else if (currentSet == widget.settings.numberOfSetsPerRound) {
        _soundManager.playSound('assets/sounds/last_set_iris_1.mp3');
      }
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        if (timeLeft == 6) {
          _soundManager.playSound('assets/sounds/5_down_iris_1.mp3');
        }
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          timer.cancel();
          if (currentSet < widget.settings.numberOfSetsPerRound) {
            _soundManager.playSound('assets/sounds/rest_iris_1.mp3');
            startRestTimer();
          } else if (currentRound < widget.settings.numberOfRounds) {
            _soundManager.playSound('assets/sounds/break_iris_1.mp3');
            startBreakTimer();
          } else {
            _soundManager.playSound('assets/sounds/finish_iris_1.mp3');
            workoutCompletion();
            timer.cancel();
          }
        }
      }
    });
  }

  void workoutCompletion() {
    _confettiController.play();
    setState(() {
      isComplete = true;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You have completed your workout!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void restartWorkout() {
    setState(() {
      currentRound = 1;
      currentSet = 1;
      isResting = false;
      isBreakTime = false;
      isPaused = false;
      isComplete = false;
    });
    startCountdown();
  }

  void startCountdown() {
    _soundManager.playSound('assets/sounds/five_down_iris_1.mp3');
    setState(() {
      timeLeft = countdownTime;
      isComplete = false;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          timer.cancel();
          startSetTimer();
        }
      }
    });
  }

  void startRestTimer() {
    setState(() {
      isResting = true;
      timeLeft = widget.settings.restBetweenSets;
    });
    timer.cancel(); // Stop previous timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          currentSet++;
          timer.cancel();
          startSetTimer();
        }
      }
    });
  }

  void startBreakTimer() {
    setState(() {
      isResting = true;
      isBreakTime = true;
      timeLeft = widget.settings.breakBetweenRounds;
    });
    timer.cancel(); // Stop previous timer
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          timer.cancel();
          currentSet = 1;
          currentRound++;
          isBreakTime = false;
          startSetTimer();
        }
      }
    });
  }

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !isComplete ? togglePause : doNothing,
      child: Scaffold(
        appBar: AppBar(
          title: Text('HIIT Timer - Round $currentRound'),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Round $currentRound of ${widget.settings.numberOfRounds}',
                  ),
                  Text(
                    'Set $currentSet of ${widget.settings.numberOfSetsPerRound}',
                  ),
                  SizedBox(height: 40),
                  Text(
                    '${timeLeft}s',
                    style: TextStyle(
                      fontSize: 72,
                      color: isResting
                          ? (isBreakTime ? Colors.red : Colors.orange)
                          : Colors.green,
                    ),
                  ),
                  if (isPaused)
                    Text(
                      'Paused',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  if (isComplete)
                    ElevatedButton(
                        onPressed: restartWorkout,
                        child: Text('Restart')),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3.14 / 2,
                maxBlastForce: 5, // Set a lower force
                minBlastForce: 2, // Set a lower force
                numberOfParticles: 50, // Adjust the number of particles
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    _confettiController.dispose();
    _soundManager.dispose();
    super.dispose();
  }
}
