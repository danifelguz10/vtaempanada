import 'package:flutter/material.dart';
import 'deptor_screen.dart';
import 'inventory_screen.dart';
import 'listproducts_screen.dart';
import 'sales_screen.dart';
import '../models/product.dart';
import '../db/firebase_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  Product? selectedProduct;
  List<Product> products = [];

  String? selectedImagePath;

  void addProduct() async {
    String productName = productNameController.text;
    double productPrice = double.parse(productPriceController.text);

    FirestoreService firestoreService = FirestoreService();

    // Crear un nuevo producto con los valores ingresados
    Product newProduct = Product(
      id: '', // Configura esto según tu lógica
      name: productName,
      price: productPrice,
      inventoryQuantity: 0, // La cantidad inicial es 0 al registrar el producto
      productId: '', // Configura esto según tu lógica
    );

    // Llama a la función para crear el producto en Firestore
    firestoreService.createProduct(newProduct);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProductsListScreen()),
    );
    // Limpia los campos y la imagen seleccionada
    productNameController.clear();
    productPriceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(labelText: 'Nombre del Producto'),
            ),
            TextField(
              controller: productPriceController,
              decoration: InputDecoration(labelText: 'Precio del Producto'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Registrar Producto'),
            ),
          ],
        ),
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
