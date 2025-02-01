import "package:clothing/providers/cart_provider.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  leading: Image.network(item.product.image, width: 50, height: 50),
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
                        icon: Icon(Icons.remove),
                        onPressed: () => cart.updateQuantity(item, item.quantity - 1),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => cart.updateQuantity(item, item.quantity + 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(CartItem item, BuildContext context) {
    return DropdownButton<String>(
      value: item.size,
      items: item.product.sizes.map((size) {
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