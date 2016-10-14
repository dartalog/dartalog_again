library tools;

import 'package:uuid/uuid.dart';

/// An empty [String] constant, to possibly save the tiniest amount of memory.
const String emptyString = "";

/// A [RegExp]-compatible [String] that matches against [String]s that contain ONLY a formatted [Uuid].
const String uuidRegexString = "\^$uuidRegexStringSnippet\$";

/// A [RegExp]-compatible [String] that matches against [String]s that contain a formatted [Uuid].
const String uuidRegexStringSnippet =
    r"[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";

/// A pre-prepared [RegExp] that matches against [Uuid] [String]s.
final RegExp uuidRegex = new RegExp(uuidRegexString);

/// Takes a hex character only uuid string and formats it with dashes at the appropriate locations.
String formatUuid(String input) {
  StringBuffer output = new StringBuffer();
  if (input.length < 32) {
    throw new Exception("UUID too short: $input");
  }
  output.write(input.substring(0, 8));
  output.write("-");
  output.write(input.substring(8, 12));
  output.write("-");
  output.write(input.substring(12, 16));
  output.write("-");
  output.write(input.substring(16, 20));
  output.write("-");
  output.write(input.substring(20, 32));
  return output.toString();
}

/// Generate a brand new uuid.
String generateUuid() {
  Uuid id = new Uuid();
  String u4 = id.v4();
  return u4;
}

/// Converts an enum value to a string of the post-type name.
String getEnumValueString(dynamic enumValue) =>
    enumValue.toString().substring(enumValue.toString().indexOf('.') + 1);

/// Checks if the [input] String is [null], only whitespace, or blank, returning a [true] if any of these conditions are met. Returns a [false] otherwise.
bool isNullOrWhitespace(String input) {
  if (input == null) {
    return true;
  }

  if (input.trim() == emptyString) {
    return true;
  }

  return false;
}

/// Returns a [bool] indicating whether the provided [String] is formatted as a [Uuid]
bool isUuid(String uuid) {
  return uuidRegex.hasMatch(uuid);
}

/// Checks if the [map] has a key matching the provided [key], then checks if the key's value is [null], only whitespace, or blank. Returns a [bool] indicating the status.
bool keyExistsAndHasValue(Map<dynamic, dynamic> map, String key) {
  if (!map.containsKey(key)) {
    return false;
  }
  if (map[key] == null) {
    return false;
  }
  return !isNullOrWhitespace(map[key]);
}

/// Returns a [String] containing the validation error message for the specified input [String], or an empty [String] if the input is valid for use as a [RegExp]
String validateRegularExpression(String input) {
  try {
    RegExp test = new RegExp(input);
    test.hasMatch("Fishmobabywhirlamagig");
    return emptyString;
  } on FormatException catch (e) {
    return e.message;
  }
}
