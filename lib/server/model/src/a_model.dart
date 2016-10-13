import 'dart:async';
import 'package:logging/logging.dart';
import 'package:option/option.dart';
import 'package:shelf_auth/shelf_auth.dart';
import 'package:dartalog/dartalog.dart';
import 'package:dartalog/server/server.dart';
import 'package:dartalog/server/data/data.dart';
import 'package:dartalog/server/data_sources/data_sources.dart' as data_sources;
import 'package:meta/meta.dart';

abstract class AModel {
  @protected
  String get currentUserId =>
      userPrincipal.map((Principal p) => p.name).getOrDefault("");

  @protected
  String get defaultCreatePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;
  @protected
  String get defaultDeletePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;
  @protected
  String get defaultPrivilegeRequirement => UserPrivilege.admin;
  @protected
  String get defaultReadPrivilegeRequirement => defaultPrivilegeRequirement;
  @protected
  String get defaultUpdatePrivilegeRequirement =>
      defaultWritePrivilegeRequirement;
  @protected
  String get defaultWritePrivilegeRequirement => defaultPrivilegeRequirement;

  @protected
  Logger get childLogger;

  @protected
  bool get userAuthenticated => userPrincipal
      .map((Principal p) => true)
      .getOrDefault(false); // High-security defaults

  @protected
  Option<Principal> get userPrincipal => authenticatedContext()
      .map((AuthenticatedContext context) => context.principal);

  @protected
  Future<User> getCurrentUser() async {
    Principal p = userPrincipal.getOrElse(
        () => throw new NotAuthorizedException.withMessage("Please log in"));
    return (await data_sources.users.getById(p.name)).getOrElse(
        () => throw new NotAuthorizedException.withMessage("User not found"));
  }

  @protected
  Future<bool> userHasPrivilege(String userType) async {
    if (userType == UserPrivilege.none)
      return true; //None is equivalent to not being logged in, or logged in as a user with no privileges
    User user = await getCurrentUser();
    return UserPrivilege.evaluate(userType, user.type);
  }

  @protected
  Future<bool> validateCreatePrivilegeRequirement() =>
      validateUserPrivilege(defaultCreatePrivilegeRequirement);

  @protected
  Future validateCreatePrivileges() async {
    if (!userAuthenticated) {
      throw new NotAuthorizedException();
    }
    await validateCreatePrivilegeRequirement();
  }

  @protected
  Future<bool> validateDefaultPrivilegeRequirement() =>
      validateUserPrivilege(defaultPrivilegeRequirement);

  @protected
  Future<bool> validateDeletePrivilegeRequirement() =>
      validateUserPrivilege(defaultDeletePrivilegeRequirement);

  @protected
  Future validateDeletePrivileges(String id) async {
    if (!userAuthenticated) {
      throw new NotAuthorizedException();
    }
    await validateDeletePrivilegeRequirement();
  }

  @protected
  Future validateGetPrivileges() async {
    await validateReadPrivilegeRequirement();
  }

  @protected
  Future<bool> validateReadPrivilegeRequirement() =>
      validateUserPrivilege(defaultReadPrivilegeRequirement);

  @protected
  Future<bool> validateUpdatePrivilegeRequirement() =>
      validateUserPrivilege(defaultUpdatePrivilegeRequirement);

  @protected
  Future validateUpdatePrivileges(String id) async {
    if (!userAuthenticated) {
      throw new NotAuthorizedException();
    }
    await validateUpdatePrivilegeRequirement();
  }

  @protected
  Future<bool> validateUserPrivilege(String privilege) async {
    if (await userHasPrivilege(privilege)) return true;
    throw new ForbiddenException.withMessage("${privilege} required");
  }
}
