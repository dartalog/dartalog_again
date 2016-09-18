// Copyright (c) 2015, Matthew Barbour. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@HtmlImport("item_view.html")
library dartalog.client.pages.item_view;

import 'dart:async';
import 'dart:html';

import 'package:dartalog/client/client.dart';
import 'package:dartalog/client/data/data.dart';
import 'package:dartalog/client/pages/pages.dart';
import 'package:dartalog/dartalog.dart' as dartalog;
import 'package:dartalog/tools.dart';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_flex_layout.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_dialog_scrollable.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_icon_button.dart';
import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_item_body.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:web_components/web_components.dart';
import 'package:dartalog/client/api/dartalog.dart' as API;
import 'package:dartalog/client/controls/image_zoomer/image_zoomer.dart';

@PolymerRegister('item-view')
class ItemViewPage extends APage
    with ARefreshablePage, ADeletablePage, AEditablePage {
  static final Logger _log = new Logger("ItemViewPage");
  @property
  String currentItemId = "";

  @Property(notify: true)
  Item currentItem = new Item();

  @Property(notify: true)
  List<Collection> collections = new List<Collection>();

  @Property(notify: true)
  ItemCopy currentItemCopy = new ItemCopy();

  @property
  bool createCopy = false;

  ItemViewPage.created() : super.created("Item View") {
    this.showBackButton = true;
  }

  Logger get loggerImpl => _log;

  @override
  Future activateInternal([bool forceRefresh = false]) async {
    if(routeData!=null) {
      if(!routeData.containsKey("item")||
          isNullOrWhitespace(routeData["item"])) {
        throw new Exception("Item is required");
      }
      this.currentItemId = routeData["item"];
    } else {
      // TODO: Handle no parameters for item page
    }

    await this.refresh();
  }

  @Observe('cart.*')
  addCartCopyClicked(event, [_]) async {
    await handleApiExceptions(() async {
      dynamic ele = getParentElement(event.target, "paper-item");
      String copy = ele.dataset["copy"];
      API.ItemCopy itemCopy =
          await api.items.copies.get(this.currentItem.id, int.parse(copy));
      await this.mainApp.addToCart(new ItemCopy.copyFrom(itemCopy));
    });
  }

  @reflectable
  addCopyClicked(event, [_]) async {
    if (!await loadAvailableCollections()) return;
    clearValidation();
    set("currentItemCopy", new ItemCopy());
    set("createCopy", true);
    $['copyEditDialog'].open();
  }

  @override
  Future delete() async {
    await handleApiExceptions(() async {
      if (!window.confirm("Are you sure you want to delete this item?")) return;
      await api.items.delete(currentItem.id);
      showMessage("Item deleted");
      mainApp.changeRoute("items");
    });
  }

  @override
  Future edit() async {
    try {
      mainApp.changeRoute("item_edit", {"item": currentItemId});
    } catch (e, st) {
      _log.severe(e, st);
      this.handleException(e, st);
    }
  }

  @reflectable
  editItemCopyClicked(event, [_]) async {
    if (!await loadAvailableCollections()) return;
    await handleApiExceptions(() async {
      clearValidation();
      dynamic ele = getParentElement(event.target, "paper-item");
      String copy = ele.dataset["copy"];
      API.ItemCopy newCopy =
          await api.items.copies.get(this.currentItem.id, int.parse(copy));
      set("currentItemCopy", new ItemCopy.copyFrom(newCopy));
      set("createCopy", false);
      $['copyEditDialog'].open();
    });
  }

  @reflectable
  String getOriginalImageUrl(String value) {
    return getImageUrl(value, ImageType.ORIGINAL);
  }

  @reflectable
  String getThumbnailUrl(String value) {
    String output = getImageUrl(value, ImageType.THUMBNAIL);
    return output;
  }

  @override
  Future goBack() async {
    mainApp.changeRoute("items");
  }

  Future<bool> loadAvailableCollections() async {
    bool output = await handleApiExceptions(() async {
      clear("collections");

      API.ListOfIdNamePair data = await api.collections.getAllIdsAndNames();

      if (data.length == 0) throw new Exception("No collections defined");

      set("collections", IdNamePair.copyList(data));
      return true;
    });
    if (output == true) return true;
    return false;
  }

  Future loadItem() async {
    await handleApiExceptions(() async {
      API.Item item = await api.items.getById(this.currentItemId,
          includeType: true,
          includeFields: true,
          includeCopies: true,
          includeCopyCollection: true);
      Item newItem = new Item.copy(item);
      set("currentItem", newItem);
      notifyPath(
          "currentItem.imageFieldsWithValue", newItem.imageFieldsWithValue);
      notifyPath("currentItem.fields", newItem.fields);
      notifyPath("currentItem.copies", newItem.copies);

      this.showDeleteButton = item.canDelete;

      setTitle(newItem.name);
    });
  }

  @override
  Future refresh() async {
    await loadItem();
  }

  @reflectable
  saveItemCopyClicked(event, [_]) async {
    await handleApiExceptions(() async {
      API.ItemCopy newCopy = new API.ItemCopy();
      this.currentItemCopy.copyTo(newCopy);
      if (createCopy)
        await api.items.copies.create(newCopy, this.currentItem.id);
      else
        await api.items.copies
            .update(newCopy, this.currentItem.id, this.currentItemCopy.copy);
      showMessage("Copy saved");
      $['copyEditDialog'].close();
      this.refresh();
    });
  }

  _updateCurrentItem(ItemCopy itemCopy) {
    set("currentItemCopy", itemCopy);
    //itemCopy.
  }
}
