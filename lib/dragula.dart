library dragula;

import 'dart:html';
import 'package:js/js.dart';

/// By default, `dragula` will allow the user to drag an element in any of the
/// [containers] and drop it in any other container in the list. If the element
/// is dropped anywhere that's not one of the [containers], the event will be
/// gracefully cancelled according to the [revertOnSpill] and [removeOnSpill]
/// options.
///
/// Note that dragging is only triggered on left clicks, and only if no meta keys
/// are pressed.
///
/// The example below allows the user to drag elements from `left` into `right`,
/// and from `right` into `left`.
///
///     dragula([document.querySelector('#left'), document.querySelector('#right')]);
///
/// You can also provide optional parameters. Here's an **overview of the default values**.
///
///     dragula(containers,
///       isContainer: (Element el) {
///         return false; // only elements in drake.containers will be taken into account
///       },
///       moves: (Element el, Element source, Element handle, Element sibling) {
///         return true; // elements are always draggable by default
///       },
///       accepts: (Element el, Element target, Element source, Element sibling) {
///         return true; // elements can be dropped in any of the `containers` by default
///       },
///       invalid: (Element el, Element target) {
///         return false; // don't prevent any drags from initiating by default
///       },
///       direction: 'vertical',             // Y axis is considered when determining where an element would be dropped
///       copy: false,                       // elements are moved by default, not copied
///       copySortSource: false,             // elements in copy-source containers can be reordered
///       revertOnSpill: false,              // spilling will put the element back where it was dragged from, if this is true
///       removeOnSpill: false,              // spilling will `.remove` the element, if this is true
///       mirrorContainer: document.body,    // set the element that gets mirror elements appended
///       ignoreInputTextSelection: true     // allows users to select input text, see details below
///     );
///
Drake dragula(List<Element> containers,
    {String direction: 'vertical',
    dynamic /*bool|Function*/ copy: false,
    bool invalid(Element el, target),
    bool copySortSource: false,
    bool revertOnSpill: false,
    bool removeOnSpill: false,
    Element mirrorContainer /*: *document.body*/,
    ignoreInputTextSelection: true,
    bool isContainer(Element el),
    bool moves(Element el, Element source, Element handling, Element sibling),
    bool accepts(Element el, Element target, Element source, Element ref)}) {
  moves ??= allowInterop((Element el, Element source, Element handling, Element sibling) {
    return true;
  });
  accepts ??= allowInterop((Element el, Element target, Element source, Element reference) {
    return true;
  });
  invalid ??= allowInterop((Element el, target) => false);
  isContainer ??= allowInterop((Element el) => false);
  mirrorContainer ??= document.body;

  if (copy is Function) {
    copy = allowInterop(copy);
  }
  moves = allowInterop(moves);
  invalid = allowInterop(invalid);
  accepts = allowInterop(accepts);
  isContainer = allowInterop(isContainer);

  return _dragula(
      containers,
      new DragulaOptions(
          direction: direction,
          isContainer: isContainer,
          moves: moves,
          accepts: accepts,
          invalid: invalid,
          copy: copy,
          copySortSource: copySortSource,
          revertOnSpill: revertOnSpill,
          removeOnSpill: removeOnSpill,
          mirrorContainer: mirrorContainer,
          ignoreInputTextSelection: ignoreInputTextSelection));
}

/// The dragula method returns a tiny object with a concise API.
@JS()
class Drake {
  /// This property contains the collection of containers that was passed to
  /// `dragula` when building this `drake` instance. You can `push` more
  /// containers and `splice` old containers at will.
  List<Element> containers;

  /// This property will be `true` whenever an element is being dragged.
  external bool get dragging;

  /// Enter drag mode **without a shadow**. This method is most useful when
  /// providing complementary keyboard shortcuts to an existing drag and drop
  /// solution. Even though a shadow won't be created at first, the user will
  /// get one as soon as they click on `item` and start dragging it around.
  /// Note that if they click and drag something else, `.end` will be called
  /// before picking up the new item.
  external void start(Element item);

  /// Gracefully end the drag event as if using **the last position marked by
  /// the preview shadow** as the drop target. The proper `cancel` or `drop`
  /// event will be fired, depending on whether the item was dropped back where
  /// it was originally lifted from
  /// _(which is essentially a no-op that's treated as a `cancel` event)_.
  external void end();

  /// If an element managed by `drake` is currently being dragged, this method
  /// will gracefully cancel the drag action. You can also pass in `revert` at
  /// the method invocation level, effectively producing the same result as if
  /// `revertOnSpill` was `true`.
  ///
  /// Note that **a _"cancellation"_ will result in a `cancel` event** only in the following scenarios.
  ///
  /// - `revertOnSpill` is `true`
  /// - Drop target _(as previewed by the feedback shadow)_ is the source container **and** the item is dropped in the same position where it was originally dragged from
  external void cancel([bool revert]);

  /// If an element managed by `drake` is currently being dragged, this method will gracefully remove it from the DOM.
  external void remove();

  /// The `drake` is an event emitter. The following events can be tracked using `drake.on(type, listener)`:
  ///
  /// Event Name | Listener Arguments               | Event Description
  /// -----------|----------------------------------|-------------------------------------------------------------------------------------
  /// `drag`     | `el, source`                     | `el` was lifted from `source`
  /// `dragend`  | `el`                             | Dragging event for `el` ended with either `cancel`, `remove`, or `drop`
  /// `drop`     | `el, target, source, sibling`    | `el` was dropped into `target` before a `sibling` element, and originally came from `source`
  /// `cancel`   | `el, container, source`          | `el` was being dragged but it got nowhere and went back into `container`, its last stable parent; `el` originally came from `source`
  /// `remove`   | `el, container, source`          | `el` was being dragged but it got nowhere and it was removed from the DOM. Its last stable parent was `container`, and originally came from `source`
  /// `shadow`   | `el, container, source`          | `el`, _the visual aid shadow_, was moved into `container`. May trigger many times as the position of `el` changes, even within the same `container`; `el` originally came from `source`
  /// `over`     | `el, container, source`          | `el` is over `container`, and originally came from `source`
  /// `out`      | `el, container, source`          | `el` was dragged out of `container` or dropped, and originally came from `source`
  /// `cloned`   | `clone, original, type`          | DOM element `original` was cloned as `clone`, of `type` _(`'mirror'` or `'copy'`)_. Fired for mirror images and when `copy: true`
  external Drake on(String events, Function callback);

  /// Removes all drag and drop events used by `dragula` to manage drag and drop
  /// between the `containers`. If `.destroy` is called while an element is being
  /// dragged, the drag will be effectively cancelled.
  external void destroy();
}

@JS('dragula')
external Drake _dragula([List<Element> containers, DragulaOptions options]);

@anonymous
@JS()
/// Don't use this class, set the options directly in the [dragula] function.
class DragulaOptions {
  external factory DragulaOptions(
      {List<Element> containers,
      String direction,
      bool isContainer(Element el),
      bool moves(Element el, Element source, Element handling, Element sibling),
      bool accepts(
          Element el, Element target, Element source, Element reference),
      bool invalid(Element el, target),
      dynamic /*bool|Function*/ copy,
      bool copySortSource,
      bool revertOnSpill,
      bool removeOnSpill,
      dynamic /*bool|num*/ delay,
      Element mirrorContainer /*: *document.body*/,
      ignoreInputTextSelection});
}
