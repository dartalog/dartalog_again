part of data;

class ImportSettings extends AData {
  String name;

  Map<String, String> fieldValues = new Map<String, String>();

  ImportSettings();

  Future validate() async {}
}
