part of data_sources.interfaces;

abstract class AUserDataSource extends AIdNameBasedDataSource<User> {
  static final Logger _log = new Logger('AUserDataSource');

  Future<List<User>> getAdmins();

  Future setPassword(String id, String password);
  Future<Option<String>> getPasswordHash(String id);
}