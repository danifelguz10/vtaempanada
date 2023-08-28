import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'db/firebase_service.dart';
import 'deptor_screen.dart';
import 'inventory_screen.dart';
import 'models/product.dart';

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final FirestoreService firestoreService = FirestoreService();
  Product? selectedProduct;
  List<Product> products = [];

  showQuantityModal(BuildContext context, Product product) {
    int quantity = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajustar Cantidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Producto: ${product.name}'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.parse(value);
                },
                decoration: InputDecoration(labelText: 'Cantidad'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                firestoreService.addToInventory(product, quantity);
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  showEditProductModal(BuildContext context, Product product) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    nameController.text = product.name;
    priceController.text = product.price.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                product.name = nameController.text;
                product.price = double.parse(priceController.text);

                await firestoreService.updateProduct(product);
                Navigator.pop(context);
              },
              child: Text('Guardar Cambios'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Productos'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          products.clear(); // Limpiar la lista antes de llenarla nuevamente
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            ''; // Si data['imageurl'] es null, asigna una cadena vacía
            Product product = Product(
              name: data['name'],
              price: data['price'].toDouble(),
              productId: doc.id,
              id: '',
              inventoryQuantity: data['inventoryQuantity'] ?? 0,
            );
            products.add(product);
          });

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Precio: \$${products[index].price.toStringAsFixed(2)}'),
                    SizedBox(height: 10),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        showQuantityModal(context, products[index]);
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.deepPurple,
                      ), // Icono que deseas utilizar
                    ),
                    SizedBox(width: 10), // Espacio entre los iconos
                    InkWell(
                      onTap: () {
                        showEditProductModal(context, products[index]);
                      },
                      child: Icon(Icons.edit_note_outlined,
                          color:
                              Colors.deepPurple), // Icono que deseas utilizar
                    ),
                    SizedBox(width: 10), // Espacio entre los iconos
                    InkWell(
                      onTap: () async {
                        await firestoreService.deleteProduct(products[index]);
                        setState(() {
                          products.removeAt(index);
                        });
                      },
                      child: Icon(Icons.delete_outline_outlined,
                          color:
                              Colors.deepPurple), // Icono que deseas utilizar
                    ),
                  ],
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0, // Cambia el índice según la vista actual
      onTap: (index) {
        setState(() {
          if (index != 0) {
            Navigator.pushReplacement(context, getRouteForIndex(index));
          }
        });
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
      case 1:
        return MaterialPageRoute(builder: (context) => DebtorsScreen());
      case 2:
        return MaterialPageRoute(builder: (context) => SalesScreen());
      case 3:
        if (products.isNotEmpty) {
          selectedProduct = products[0];
          return MaterialPageRoute(
            builder: (context) => InventoryScreen(product: selectedProduct!),
          );
        }
        break;
    }
    return MaterialPageRoute(builder: (context) => ProductsListScreen());
  }
}
