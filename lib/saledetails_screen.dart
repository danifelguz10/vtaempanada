import 'package:flutter/material.dart';
import 'models/sale.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  SaleDetailsScreen({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la Venta')),
      body: Column(
        children: [
          Text('Fecha y Hora: ${sale.timestamp}'),
          Text('Total: \$${sale.totalAmount.toStringAsFixed(2)}'),
          Divider(),
          Text('Productos Vendidos:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: sale.products.length,
            itemBuilder: (context, index) {
              final product = sale.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(
                    'Cantidad: ${product.quantity} - Precio: \$${product.price.toStringAsFixed(2)}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
