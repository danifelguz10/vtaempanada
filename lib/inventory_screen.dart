import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listproducts_screen.dart';
import 'models/product.dart';
import 'deptor_screen.dart';
import 'sales_screen.dart';

class InventoryScreen extends StatelessWidget {
  final Product product;

  InventoryScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('inventories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<Product> inventoryProducts = [];
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String name = data['name'] ?? 'Nombre Desconocido';
            double price = (data['price'] ?? 0).toDouble();
            int inventoryQuantity = data['inventoryQuantity'] ?? 0;

            Product inventoryProduct = Product(
              name: name,
              price: price,
              productId: doc.id,
              id: '',
              inventoryQuantity: inventoryQuantity,
            );
            inventoryProducts.add(inventoryProduct);
          });

          return ListView.builder(
            itemCount: inventoryProducts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(inventoryProducts[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Precio: \$${inventoryProducts[index].price.toStringAsFixed(0)}'),
                    Text(
                        'Cantidad: ${inventoryProducts[index].inventoryQuantity}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Eliminar Producto'),
                              content: Text(
                                  '¿Deseas eliminar este producto del inventario?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete == true) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('inventories')
                                .doc(inventoryProducts[index].productId)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Producto eliminado del inventario.'),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al eliminar el producto.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      onTap: (index) {
        if (index != 3) {
          Navigator.pushReplacement(context, getRouteForIndex(index));
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list, color: Colors.deepPurple),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, color: Colors.deepPurple),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, color: Colors.deepPurple),
          label: 'Ventas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory, color: Colors.deepPurple),
          label: 'Inventario',
        ),
      ],
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.deepPurple,
    );
  }

  MaterialPageRoute getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return MaterialPageRoute(builder: (context) => ProductsListScreen());
      case 1:
        return MaterialPageRoute(builder: (context) => DebtorsScreen());
      case 2:
        return MaterialPageRoute(builder: (context) => SalesScreen());
      case 3:
        return MaterialPageRoute(builder: (context) => ProductsListScreen());
    }
    return MaterialPageRoute(builder: (context) => ProductsListScreen());
  }
}
