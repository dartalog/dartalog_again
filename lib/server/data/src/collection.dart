part of data;

class Collection extends AIdData {
  String _id = "";
  String get id => _id;
  set id(String value) => _id = value;

  String _name = "";
  String get name => _name;
  set name(String value) => _name = value;

  Collection();

}