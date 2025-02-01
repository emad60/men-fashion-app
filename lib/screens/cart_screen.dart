import 'package:clothing/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  /// Helper widget to display a product image.
  /// Checks if the image path is a URL (using http/https) or a local asset.
  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  leading: _buildProductImage(item.product.image),
                  title: Text(item.product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSizeSelector(item, context),
                      Text('Quantity: ${item.quantity}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            cart.updateQuantity(item, item.quantity - 1),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            cart.updateQuantity(item, item.quantity + 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a dropdown for selecting a product size.
  /// If the product has no available sizes (like a bag), returns an empty container.
  Widget _buildSizeSelector(CartItem item, BuildContext context) {
    final availableSizes = item.product.availableSizes;
    if (availableSizes.isEmpty) {
      return Container();
    }

    // Ensure the item's size is valid. If not, default to the first available size.
    final selectedSize =
        availableSizes.contains(item.size) ? item.size : availableSizes.first;

    // Update the item size if necessary.
    if (item.size != selectedSize) {
      Provider.of<CartProvider>(context, listen: false)
          .updateSize(item, selectedSize);
    }

    return DropdownButton<String>(
      value: selectedSize,
      items: availableSizes.map((size) {
        return DropdownMenuItem(
          value: size,
          child: Text('Size: $size'),
        );
      }).toList(),
      onChanged: (newSize) {
        if (newSize != null) {
          Provider.of<CartProvider>(context, listen: false)
              .updateSize(item, newSize);
        }
      },
    );
  }
}
