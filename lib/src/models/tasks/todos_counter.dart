/* THIS CODE WAS FOR ACTIONS - NOT USED ANYMORE FOR NOW
import 'package:flutter/material.dart';


class TodosCounter {
  /// Number of processes the user has to reviewed and has not seen yet
  late int _processSuggestionTodosCount;

  /// Number of processes which current step is assigned to the user and the user has not seen yet
  late int _processStepAssignedToUserCount;

  /// Number of processes that are done but the user has not seen yet
  late int _processDoneCount;

  late ValueNotifier<int> numberOfTodosNotifier;

  TodosCounter(
      {int processSuggestionTodosCount = 0,
      int processNewSuggestionTodosCount = 0,
      int processStepAssignedToUserCount = 0,
      int processDoneCount = 0}) {
    _processSuggestionTodosCount = processSuggestionTodosCount;
    _processStepAssignedToUserCount = processStepAssignedToUserCount;
    _processDoneCount = processDoneCount;
    
    numberOfTodosNotifier = ValueNotifier<int>(numberOfTodos);
  }

  /// Number of todos
  int get numberOfTodos =>
      _processSuggestionTodosCount +
      _processStepAssignedToUserCount +
      _processDoneCount;

  void onSuggestionReviewed() {
    _processSuggestionTodosCount--;
    numberOfTodosNotifier.value = numberOfTodos;
  }

  void onStepAssignedToUser() {
    _processStepAssignedToUserCount--;
    numberOfTodosNotifier.value = numberOfTodos;
  }

  void onProcessDoneReviewed() {
    _processDoneCount--;
    numberOfTodosNotifier.value = numberOfTodos;
  }

  void onCurrentStepChangedToUserAssignedOne() {
    _processStepAssignedToUserCount++;
    numberOfTodosNotifier.value = numberOfTodos;
  }
}
*/
