library dartalog;

// Just a place to put some shared tools

// JSON-schema-related stuff

// Reserved field names
const String FIELD_UUID = "x_uuid";

// Constants to define the json hyper schema link names
// Field-related links
const String SCHEMA_LINK_GET_PROPERTIES = "get_properties";
const String SCHEMA_LINK_GET_PROPERTY = "get_property";
const String SCHEMA_LINK_CREATE_PROPERTY = "create_property";
const String SCHEMA_LINK_UPDATE_PROPERTY = "update_property";
const String SCHEMA_LINK_DELETE_PROPERTY = "delete_property";
// Others
const String SCHEMA_LINK_GET_CLASSES = "get_classes";
const String SCHEMA_LINK_GET_CLASS = "get_class";
const String SCHEMA_LINK_CREATE_CLASS = "create_class";
const String SCHEMA_LINK_UPDATE_CLASS = "update_class";
const String SCHEMA_LINK_DELETE_CLASS = "delete_class";

const String SCHEMA_LINK_GET_OBJECTS = "get_objects";
const String SCHEMA_LINK_GET_SETTINGS = "get_settings";
const String SCHEMA_LINK_NUKE = "nuke";

final Map<String,String> FIELD_TYPES = {'numeric': 'Numeric', 'string': 'String', 'date': 'Date', 'image': 'Image'};

class ValidationException implements  Exception {
  String message;
  ValidationException(this.message);
}