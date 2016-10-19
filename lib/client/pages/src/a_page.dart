import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:dartalog/client/controls/controls.dart';

abstract class APage<T extends APage<T>> extends AControl {
  APage.created(this.pageTitle) : super.created();

  @Property(notify: true)
  String pageTitle;

  bool showBackButton = false;

  int lastScrollPosition = 0;

  void setTitle(String newTitle) {
    this.pageTitle = newTitle;
    set("pageTitle", newTitle);
    this.evaluatePage();
  }

  Future<Null> goBack() async {}

  bool evaluate(APage<T> page, bool evaluate(T page)) {
    if (page is T) {
      return evaluate(page);
    }
    return false;
  }
}
