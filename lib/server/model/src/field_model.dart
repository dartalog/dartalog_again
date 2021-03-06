part of model;

class FieldModel extends AIdNameBasedModel<Field> {
  static final Logger _log = new Logger('FieldModel');
  Logger get _logger => _log;
  AIdNameBasedDataSource<Field> get dataSource => data_sources.fields;

  @override
  String get _defaultReadPrivilegeRequirement => UserPrivilege.curator;

  @override
  Future _validateFieldsInternal(Map field_errors, Field field, bool creating) async {
    if (isNullOrWhitespace(field.type))
      field_errors["type"] = "Required";
    else if(!FIELD_TYPES.containsKey(field.type)) {
      field_errors["type"] = "Invalid";
    }

    if (!isNullOrWhitespace(field.format)) {
      String test = validateRegularExpression(field.format);
      if (!isNullOrWhitespace(test)) field_errors["format"] = test;
    }
  }

}