import 'package:dragula/dragula.dart';
import 'dart:html';
import 'dart:async';

main() {
  dragula([$('left-defaults'), $('right-defaults')]);

  dragula([$('left-events'), $('right-events')])
    ..onDrag((Element el, _) {
      return el.classes.remove('ex-moved');
    })
    ..onDrop((Element el, _, __, ___) {
      return el.classes.add('ex-moved');
    })
    ..onOver((_, Element container, __) {
      return container.classes.add('ex-over');
    })
    ..onOut((_, Element container, __) {
      return container.classes.remove('ex-over');
    });

  dragula([$('left-rm-spill'), $('right-rm-spill')], removeOnSpill: true);

  dragula([$('left-rollbacks'), $('right-rollbacks')], revertOnSpill: true);

  dragula([$('left-copy'), $('right-copy')], copy: true);

  dragula([$('left-copy-1tomany'), $('right-copy-1tomany')],
      copy: (Element el, Element source) => source == $('left-copy-1tomany'),
      accepts:
          (Element el, Element source, Element handling, Element sibling) =>
              source != $('left-copy-1tomany'));

  dragula([$('left-lovehandles'), $('right-lovehandles')],
      moves: (el, container, handle, sibling) => handle.className == 'handle');

  var sortable = $('sortable');
  dragula([sortable]);
  sortable.onClick.listen((e) {
    DivElement target = e.target;
    if (target == sortable) {
      return;
    }
    target.text += ' [click!]';
    new Future.delayed(
        new Duration(milliseconds: 500),
        () => target.text =
            target.text.replaceAll(new RegExp(r'\[click!\]'), ''));
  });
}

Element $(String id) => document.getElementById(id);
