/// The difference between this API and the raw_dragula API is that in this API
/// you don't need to use `allowInterop` for the dart functions you pass to
/// javascript. Also instead of `dragula(containers, new DragulaOptions(copy: true));`
/// , you must write in this API `dragula(containers, copy: true)`.
library dragula;

import 'dart:html';

import 'package:js/js.dart';
import 'package:dragula/dragula_raw.dart' as raw;
import 'package:dragula/dragula_raw.dart' show Drake;
export 'package:dragula/dragula_raw.dart' show Drake;

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
  moves ??= (Element el, Element source, Element handling, Element sibling) {
    return true;
  };
  accepts ??= (Element el, Element target, Element source, Element reference) {
    return true;
  };
  invalid ??= (Element el, target) => false;
  isContainer ??= (Element el) => false;
  mirrorContainer ??= document.body;

  if (copy is Function) {
    copy = allowInterop(copy);
  }
  moves = allowInterop(moves);
  invalid = allowInterop(invalid);
  accepts = allowInterop(accepts);
  isContainer = allowInterop(isContainer);

  return raw.dragula(
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
}
