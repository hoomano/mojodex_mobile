import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/role_manager/profile.dart';
import 'package:mojodex_mobile/src/role_manager/profile_category.dart';
import 'package:mojodex_mobile/src/role_manager/role.dart';

import '../models/user/user.dart';

enum RoleEvent { success, canceled, error }

class RoleManager extends ChangeNotifier with HttpCaller {
  final Logger logger = Logger('RoleManager');

  List<Role>? _expiredRoles;
  List<Role>? get expiredRoles => _expiredRoles;

  List<Role>? _currentRoles;
  List<Role>? get currentRoles => _currentRoles;

  List<Profile> _availableProfiles = [];
  List<Profile> get availableProfiles => _availableProfiles;

  bool _roleInitialized = false;
  bool get roleInitialized => _roleInitialized;

  Future<void> init() async {
    await refreshRole();
  }

  Future<bool> activateFreeTrial(int profileCategoryPk) async {
    Map<String, dynamic>? newRole = await put(
        service: 'associate_free_profile',
        body: {'profile_category_pk': profileCategoryPk});
    if (newRole == null) return false;
    _currentRoles = (newRole['current_roles'] as List<dynamic>)
        .map((role) => Role(
            remainingDays: role['remaining_days'],
            nTasksConsumed: role['n_tasks_consumed'],
            profile: Profile(
                name: role['profile_name'],
                tasks: role['tasks'].cast<String>(),
                isFree: role['is_free_profile'],
                nValidityDays: role['n_validity_days'],
                nTasksLimit: role['n_tasks_limit'])))
        .toList();
    _availableProfiles = (newRole['available_profiles'] as List<dynamic>)
        .map((profile) => Profile(
              name: profile['name'],
              tasks: profile['tasks'].cast<String>(),
              isFree: false,
              nValidityDays: profile['n_validity_days'],
              nTasksLimit: profile['n_tasks_limit'],
              productStripeId: profile['product_stripe_id'],
              productAppleId: profile['product_apple_id'],
              stripePrice: profile['stripe_price'],
            ))
        .toList();
    await User().userTasksList.reloadItems();
    notifyListeners();
    return true;
  }

  List<ProfileCategory> _profileCategories = [];
  List<ProfileCategory> get profileCategories => _profileCategories;
  Future<void> getProfileCategories() async {
    Map<String, dynamic>? categories =
        await get(service: 'profile_category', params: '');
    if (categories == null) return;
    _profileCategories = (categories['profile_categories'] as List<dynamic>)
        .map((category) => ProfileCategory(
              profileCategoryPk: category['profile_category_pk'],
              name: category['name'],
              emoji: category['emoji'],
              description: category['description'],
            ))
        .toList();
  }

  Future<void> cancelSubscription() async {
    logger.shout('Cancel subscription not implemented');
  }

  Future<Map<String, dynamic>?> _getCurrentRole() async {
    String params = "datetime=${DateTime.now().toIso8601String()}";
    return await get(service: 'role', params: params);
  }

  Future<void> refreshRole() async {
    try {
      Map<String, dynamic>? roleState = await _getCurrentRole();
      if (roleState == null) return;
      if (roleState['current_roles'] != null) {
        _currentRoles = (roleState['current_roles'] as List<dynamic>)
            .map((role) => Role(
                remainingDays: role['remaining_days'],
                nTasksConsumed: role['n_tasks_consumed'],
                profile: Profile(
                    name: role['profile_name'],
                    tasks: role['tasks'].cast<String>(),
                    isFree: role['is_free_profile'],
                    nValidityDays: role['n_validity_days'],
                    nTasksLimit: role['n_tasks_limit'])))
            .toList();
      }
      _availableProfiles = (roleState['available_profiles'] as List<dynamic>)
          .map((profile) => Profile(
                name: profile['name'],
                tasks: profile['tasks'].cast<String>(),
                isFree: false,
                nValidityDays: profile['n_validity_days'],
                nTasksLimit: profile['n_tasks_limit'],
                productStripeId: profile['product_stripe_id'],
                productAppleId: profile['product_apple_id'],
                stripePrice: profile['stripe_price'],
              ))
          .toList();
      _expiredRoles = (roleState['last_expired_role'] as List<dynamic>)
          .map((role) => Role(
              remainingDays: role['remaining_days'],
              nTasksConsumed: role['n_tasks_consumed'],
              profile: Profile(
                  name: role['profile_name'],
                  tasks: role['tasks'].cast<String>(),
                  isFree: role['is_free_profile'],
                  nValidityDays: role['n_validity_days'],
                  nTasksLimit: role['n_tasks_limit'])))
          .toList();

      _roleInitialized = true;
      await User().userTasksList.loadMoreItems(offset: 0);
      notifyListeners();
    } catch (e) {
      logger.severe("Error while refreshing role: $e");
    }
  }

  Future<void> contactUsForRole() async {
    logger.shout("ContactUsForRole not implemented");
  }
}
