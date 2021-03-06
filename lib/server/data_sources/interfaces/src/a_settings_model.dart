part of data_sources.interfaces;

abstract class ASettingsModel extends _ADataSource {
  static final Logger _log = new Logger('ASettingsModel');

  AFieldModel();

  Future<Map<String, String>> getAll();
  Future<Field> get(Settings setting);

  Future write(Settings setting, String value);

}