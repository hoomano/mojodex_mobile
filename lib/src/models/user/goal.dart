import 'package:mojodex_mobile/src/models/http_caller.dart';

// This class represents the goal the users choosed during the onboarding process was completed
class Goal with HttpCaller {
  late String description;

  Future<bool> set(String goal) async {
    description = goal;

    Map<String, dynamic>? response =
        await put(service: 'goal', body: {'goal': goal});

    if (response == null) return false;

    return true;
  }
}
