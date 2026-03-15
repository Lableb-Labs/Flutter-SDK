import 'package:get_it/get_it.dart';

import 'cart_event_bus.dart';

abstract interface class CartEventHandlersBuilderStart {
  CartEventHandlersBuilderRemove onAddToCart(AddToCartCallback callback);
}

abstract interface class CartEventHandlersBuilderRemove {
  CartEventHandlersBuilderReady onRemoveFromCart(RemoveFromCartCallback callback);
}

abstract interface class CartEventHandlersBuilderReady {
  Future<void> send();
}

class CartEventHandlersBuilder
    implements
        CartEventHandlersBuilderStart,
        CartEventHandlersBuilderRemove,
        CartEventHandlersBuilderReady {
  AddToCartCallback? _onAdd;
  RemoveFromCartCallback? _onRemove;

  @override
  CartEventHandlersBuilderRemove onAddToCart(AddToCartCallback callback) {
    _onAdd = callback;
    return this;
  }

  @override
  CartEventHandlersBuilderReady onRemoveFromCart(
    RemoveFromCartCallback callback,
  ) {
    _onRemove = callback;
    return this;
  }

  @override
  Future<void> send() async {
    final add = _onAdd;
    final remove = _onRemove;

    assert(add != null, 'onAddToCart callback is required');
    assert(remove != null, 'onRemoveFromCart callback is required');

    final bus = GetIt.instance<CartEventBus>();
    bus.register(onAddToCart: add!, onRemoveFromCart: remove!);
  }
}

