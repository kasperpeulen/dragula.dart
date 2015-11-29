/// The difference between this API and the [raw_dragula] API is that here
/// you don't need to use [allowInterop] for the dart functions you pass to
/// javascript. Also in [raw_dragula] you have to use:
///
///     dragula(containers, new DragulaOptions(copy: true));
///
/// In this API, you can use the shorter:
///
///     dragula(containers, copy: true)
///
library dragula;

import 'dart:html';

import 'package:js/js.dart';
import 'package:dragula/dragula_raw.dart' as raw;

/// Makes all the elements in the [containers] draggable.
///
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
/// ### options.containers
///
/// Setting this option is effectively the same as passing the containers in the first argument to `dragula(containers)`.
///
/// ### options.isContainer
///
/// Besides the containers that you pass to `dragula`, or the containers you dynamically `push` or `unshift` from [drake.containers](#drakecontainers), you can also use this method to specify any sort of logic that defines what is a container for this particular `drake` instance.
///
/// The example below dynamically treats all DOM elements with a CSS class of `dragula-container` as dragula containers for this `drake`.
///
///  ```dart
///  var drake = dragula([],
///    isContainer: (el) {
///      return el.classList.contains('dragula-container');
///    }
///  );
///  ```
///
///  ### options.moves
///  ///
/// You can define a `moves` method which will be invoked with `(el, source, handle, sibling)` whenever an element is clicked. If this method returns `false`, a drag event won't begin, and the event won't be prevented either. The `handle` element will be the original click target, which comes in handy to test if that element is an expected _"drag handle"_.
///
/// ### options.accepts
///
/// You can set `accepts` to a method with the following signature: `(el, target, source, sibling)`. It'll be called to make sure that an element `el`, that came from container `source`, can be dropped on container `target` before a `sibling` element. The `sibling` can be `null`, which would mean that the element would be placed as the last element in the container. Note that if `options.copy` is set to `true`, `el` will be set to the copy, instead of the originally dragged element.
///
/// Also note that **the position where a drag starts is always going to be a valid place where to drop the element**, even if `accepts` returned `false` for all cases.
///
/// ### options.copy
///
/// If `copy` is set to `true` _(or a method that returns `true`)_, items will be copied rather than moved. This implies the following differences:
///
/// Event     | Move                                     | Copy
/// ----------|------------------------------------------|---------------------------------------------
/// `drag`    | Element will be concealed from `source`  | Nothing happens
/// `drop`    | Element will be moved into `target`      | Element will be cloned into `target`
/// `remove`  | Element will be removed from DOM         | Nothing happens
/// `cancel`  | Element will stay in `source`            | Nothing happens
///
/// If a method is passed, it'll be called whenever an element starts being dragged in order to decide whether it should follow `copy` behavior or not. Consider the following example.
///
/// ```dart
/// copy: (el, source) {
///   return el.className === 'you-may-copy-us';
/// }
/// ```
///
/// ### options.copySortSource
///
/// If `copy` is set to `true` _(or a method that returns `true`)_ and `copySortSource` is `true` as well, users will be able to sort elements in `copy`-source containers.
///
/// ```dart
/// copy: true,
/// copySortSource: true
/// ```
///
/// ### options.revertOnSpill
///
/// By default, spilling an element outside of any containers will move the element back to the _drop position previewed by the feedback shadow_. Setting `revertOnSpill` to `true` will ensure elements dropped outside of any approved containers are moved back to the source element where the drag event began, rather than stay at the _drop position previewed by the feedback shadow_.
///
/// ### options.removeOnSpill
///
/// By default, spilling an element outside of any containers will move the element back to the _drop position previewed by the feedback shadow_. Setting `removeOnSpill` to `true` will ensure elements dropped outside of any approved containers are removed from the DOM. Note that `remove` events won't fire if `copy` is set to `true`.
///
/// ### options.direction
///
/// When an element is dropped onto a container, it'll be placed near the point where the mouse was released. If the `direction` is `'vertical'`, the default value, the Y axis will be considered. Otherwise, if the `direction` is `'horizontal'`, the X axis will be considered.
///
/// ### options.invalid
///
/// You can provide an `invalid` method with a `(el, target)` signature. This method should return `true` for elements that shouldn't trigger a drag. Here's the default implementation, which doesn't prevent any drags.
Drake dragula(List<Element> containers,
    {String direction: 'vertical',
    bool copySortSource: false,
    bool revertOnSpill: false,
    bool removeOnSpill: false,
    ignoreInputTextSelection: true,
    dynamic /*bool|(Element el, Element source) -> bool*/copy: false,
    Element mirrorContainer /*: *document.body*/,
    bool invalid(Element el, target),
    bool isContainer(Element el),
    bool moves(Element el, Element source, Element handling, Element sibling),
    bool accepts(Element el, Element target, Element source, Element ref)}) {
  // other default values
  mirrorContainer ??= document.body;
  moves ??= (Element el, Element source, Element handling, Element sibling) => true;
  accepts ??= (Element el, Element target, Element source, Element reference) => true;
  invalid ??= (Element el, target) => false;
  isContainer ??= (Element el) => false;

  if (copy is Function) copy = allowInterop(copy);
  moves = allowInterop(moves);
  invalid = allowInterop(invalid);
  accepts = allowInterop(accepts);
  isContainer = allowInterop(isContainer);

  raw.Drake drake = raw.dragula(
      containers,
      new raw.DragulaOptions(
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
  return new Drake._(drake);
}

/// The dragula method returns this tiny object with a concise API.
class Drake {
  raw.Drake _rawDrake;

  Drake._(this._rawDrake);

  /// This property contains the collection of containers that was passed to
  /// `dragula` when building this `drake` instance. You can `push` more
  /// containers and `splice` old containers at will.
  List<Element> get containers => _rawDrake.containers;

  /// This property will be `true` whenever an element is being dragged.
  bool get dragging => _rawDrake.dragging;

  /// Enter drag mode **without a shadow**.
  ///
  /// This method is most useful when providing complementary keyboard shortcuts
  /// to an existing drag and drop
  /// solution. Even though a shadow won't be created at first, the user will
  /// get one as soon as they click on `item` and start dragging it around.
  /// Note that if they click and drag something else, `.end` will be called
  /// before picking up the new item.
  void start(Element item) => _rawDrake.start(item);

  /// Gracefully end the drag event as if using **the last position marked by
  /// the preview shadow** as the drop target. The proper `cancel` or `drop`
  /// event will be fired, depending on whether the item was dropped back where
  /// it was originally lifted from
  /// _(which is essentially a no-op that's treated as a `cancel` event)_.
  void end() => _rawDrake.end();

  /// If an element managed by `drake` is currently being dragged, this method
  /// will gracefully cancel the drag action. You can also pass in `revert` at
  /// the method invocation level, effectively producing the same result as if
  /// `revertOnSpill` was `true`.
  ///
  /// Note that **a _"cancellation"_ will result in a `cancel` event** only in the following scenarios.
  ///
  /// - `revertOnSpill` is `true`
  /// - Drop target _(as previewed by the feedback shadow)_ is the source container **and** the item is dropped in the same position where it was originally dragged from
  void cancel([bool revert]) => _rawDrake.cancel(revert);

  /// If an element managed by `drake` is currently being dragged, this method will gracefully remove it from the DOM.
  void remove() => _rawDrake.remove();

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
  void on(String event, Function callback) {
    _rawDrake.on(event, allowInterop(callback));
  }

  /// [el] was lifted from [source]
  void onDrag(void callback(Element el, Element source)) {
    _rawDrake.on('drag', allowInterop(callback));
  }

  /// Dragging event for [el] ended with either `cancel`, `remove`, or `drop`
  void onDragEnd(void callback(Element el)) {
    _rawDrake.on('dragend', allowInterop(callback));
  }

  /// [el] was dropped into [target] before a [sibling] element, and originally came from [source[.
  void onDrop(void callback(
      Element el, Element target, Element source, Element sibling)) {
    _rawDrake.on('drop', allowInterop(callback));
  }

  /// [el] was being dragged but it got nowhere and went back into [container],
  /// its last stable parent; [el] originally came from [source]
  void onCancel(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('cancel', allowInterop(callback));
  }

  /// [el] was being dragged but it got nowhere and it was removed from the DOM.
  /// Its last stable parent was [container], and originally came from [source]
  void onRemove(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('remove', allowInterop(callback));
  }

  /// [el], _the visual aid shadow_, was moved into [container]. May trigger
  /// many times as the position of [el] changes, even within the same [container];
  /// [el] originally came from [source]
  void onShadow(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('shadow', allowInterop(callback));
  }

  /// [el] is over [container], and originally came from [source]
  void onOver(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('over', allowInterop(callback));
  }

  /// [el] was dragged out of [container] or dropped, and originally came from [source]
  void onOut(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('out', allowInterop(callback));
  }

  /// DOM element `original` was cloned as `clone`, of `type` _(`'mirror'` or `'copy'`)_.
  /// Fired for mirror images and when `copy: true`
  void onCloned(void callback(Element el, Element container, Element source)) {
    _rawDrake.on('cloned', allowInterop(callback));
  }

  /// Removes all drag and drop events used by `dragula` to manage drag and drop
  /// between the `containers`. If `.destroy` is called while an element is being
  /// dragged, the drag will be effectively cancelled.
  void destroy() => _rawDrake.destroy();
}
