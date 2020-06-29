import 'package:flutter/material.dart';
import 'dart:math';

class AppConfig {
  final String OnboardingText1 = 'Already have a saved Sudoku Image in your device? You can upload it to our App and the AI will take care of the rest. Try to ensure the puzzle fits within the frame.';
  final String OnboardingText2 = 'You can also directly use the Camera on your phone to capture an image of a Sudoku. The AI will process and solve it. Try to ensure the puzzle fits within the frame.';
  final String OnboardingText3 = 'You have the option to crop, resize or rotate the image according to your preference. The AI will take any help you can give it.';
  final String OnboardingText4 = 'Feel free to download and share the solution that our App produces for your puzzle.';
  

  final String postUrl = 'http://192.168.0.132:5000/sudomagic';
  final String getUrl = 'http://192.168.0.132:5000/answer';
}