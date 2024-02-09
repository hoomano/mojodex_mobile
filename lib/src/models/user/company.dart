import 'package:mojodex_mobile/src/models/http_caller.dart';

// This class represents the user's company if the onboarding process was completed
class Company with HttpCaller{

  late String emoji;
  late String name;
  late String description;

  Future<bool> searchFromWebUri(String webUri) async {
    Map<String, dynamic>? response = await put(
      service: 'company', 
      body: {'website_url' : webUri}
    );
    
    if (response == null) return false;
    
    emoji = response["company_emoji"];
    name = response["company_name"];
    description = response["company_description"];

    return true;
  }

  Future<bool> update(String feedback, String correct) async {
    Map<String, dynamic>? response = await post(
      service: 'company', 
      body: {
        'feedback' : feedback,
        'correct' : correct
    });
    
    emoji = response?["company_emoji"] ?? emoji;
    name = response?["company_name"] ?? name;
    description = response?["company_description"] ?? description;

    return response != null;
  }
}