typedef AddToCartCallback = void Function(String productId, int quantity);
typedef RemoveFromCartCallback = void Function(String productId);

/// Central event bus for cart-related callbacks.
class CartEventBus {
  AddToCartCallback? _onAddToCart;
  RemoveFromCartCallback? _onRemoveFromCart;

  void register({
    required AddToCartCallback onAddToCart,
    required RemoveFromCartCallback onRemoveFromCart,
  }) {
    _onAddToCart = onAddToCart;
    _onRemoveFromCart = onRemoveFromCart;
  }

  void notifyAddToCart(String productId, int quantity) {
    final cb = _onAddToCart;
    if (cb != null) {
      cb(productId, quantity);
    }
  }

  void notifyRemoveFromCart(String productId) {
    final cb = _onRemoveFromCart;
    if (cb != null) {
      cb(productId);
    }
  }
}

