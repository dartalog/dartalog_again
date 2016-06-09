part of model;

class UserModel extends AIdNameBasedModel<User> {
  static final Logger _log = new Logger('UserModel');
  Logger get _logger => _log;

  AUserDataSource get dataSource =>
      data_sources.users;

  Future<List<IdNamePair>> getAllIdsAndNames() async {
    await checkUserForPrivilege(USER_PRIVILEGE_CHECKOUT);
    return await super.getAllIdsAndNames();
  }

  Future<User> getMe() async {
    if(!userAuthenticated())
      throw new NotAuthorizedException();

    Option<Principal> princ = getUserPrincipal();
    Option<User> output = await dataSource.getById(princ.get().name);
    return output.getOrElse(() =>throw new Exception("Authenticated user not present in database"));
  }

  Future setPrivileges(String id, List<String> privilege) async {
    await checkUserForPrivilege(USER_PRIVILEGE_ADMIN);
    if(!await dataSource.exists(id))
      throw new NotFoundException("User not found");

    await dataSource.setPrivileges(id, privilege);
  }

  @override
  Future<String> create(User user, {List<String> privileges}) async {
    await checkUserForPrivilege(USER_PRIVILEGE_ADMIN);

    String output = await super.create(user);

    await _setPassword(output, user.password);

    return output;
  }

  Future changePassword(
      String id, String currentPassword, String newPassword) async {
    if (!userAuthenticated()) {
      throw new NotAuthorizedException();
    }
    if(currentUserId!=id)
      throw new NotAuthorizedException.withMessage("You do not have permission to change another user's password");

    Map<String, String> field_errors = new Map<String, String>();

    String userPassword = (await data_sources.users.getPasswordHash(id)).getOrElse(() => throw new Exception("User ${id} does not have a current password"));

    await DataValidationException.PerformValidation((Map field_errors) async {
      if (isNullOrWhitespace(currentPassword)) {
        field_errors["currentPassword"] = "Required";
      } else if (!verifyPassword(userPassword, currentPassword)) {
        field_errors["currentPassword"] = "Incorrect";
      }
    });
    await _setPassword(id, newPassword);
  }

  Future _setPassword(String id, String newPassword) async {
    await DataValidationException.PerformValidation((Map field_errors) async {
      if (isNullOrWhitespace(newPassword)) {
        field_errors["newPassword"] = "Required";
      } else if (newPassword.length < 8) {
        //TODO: Additional restrictions? Keep them sane.
        field_errors["newPassword"] = "Must be at least 8 digits long";
      }
    });

    String passwordHash = hashPassword(newPassword);
    await dataSource.setPassword(id, passwordHash);

  }

  String hashPassword(String password) {
    return new Crypt.sha256(password).toString();
  }

  bool verifyPassword(String hash, String password) =>
      new Crypt(hash).match(password);

}
