import 'package:mojodex_mobile/src/role_manager/profile.dart';

class Role {
  final Profile profile;
  final int? remainingDays;
  final int? nTasksConsumed;

  Role({required this.profile, this.remainingDays, this.nTasksConsumed});
}
