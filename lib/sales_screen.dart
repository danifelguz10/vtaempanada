import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/deptor_screen.dart';
import 'inventory_screen.dart';
import 'listproducts_screen.dart';
import '/models/sale.dart';
import 'saleslist_screen.dart';
import 'models/product.dart';
import 'models/saleproduct.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<SaleProduct> selectedProducts = [];
  Product? selectedProduct;
  List<Product> products = [];
  Map<String, int> originalQuantities = {};

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('inventories').get();
    final docs = snapshot.docs;

    List<Product> inventoryProducts = [];
    docs.forEach((doc) {
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
      originalQuantities[doc.id] = inventoryQuantity;
    });

    setState(() {
      products = inventoryProducts;
    });
  }

  void addProductToSale(Product product) {
    if (product.inventoryQuantity > 0) {
      setState(() {
        product.inventoryQuantity--;
        bool productExists = false;
        for (var saleProduct in selectedProducts) {
          if (saleProduct.productId == product.productId) {
            saleProduct.quantity++;
            productExists = true;
            break;
          }
        }
        if (!productExists) {
          selectedProducts.add(SaleProduct(
            productId: product.productId,
            name: product.name,
            price: product.price,
            quantity: 1,
          ));
        }
        print('Producto añadido a la selección: ${product.name}, '
            'Cantidad disponible: ${product.inventoryQuantity}');
        print('Productos seleccionados: $selectedProducts');
      });
    }
  }

  void removeProductFromSale(SaleProduct saleProduct) {
    setState(() {
      for (var product in products) {
        if (product.productId == saleProduct.productId) {
          product.inventoryQuantity +=
              saleProduct.quantity; // Restaurar cantidad original
          break;
        }
      }
      if (saleProduct.quantity > 1) {
        saleProduct.quantity--;
      } else {
        selectedProducts.remove(saleProduct);
      }
      print('Producto eliminado de la selección: ${saleProduct.name}');
      print('Productos seleccionados: $selectedProducts');
    });
  }

  void registerSale() async {
    double totalAmount = 0;
    List<Map<String, dynamic>> updatedInventory = [];

    for (int i = 0; i < selectedProducts.length; i++) {
      var saleProduct = selectedProducts[i];
      totalAmount += saleProduct.price * saleProduct.quantity;

      // Actualizar el inventario
      int updatedQuantity =
          originalQuantities[saleProduct.productId]! - saleProduct.quantity;
      updatedInventory.add({
        'productId': saleProduct.productId,
        'inventoryQuantity': updatedQuantity,
      });
    }

    // Registrar la venta en Firestore
    try {
      await FirebaseFirestore.instance.collection('sales').add({
        'timestamp': FieldValue.serverTimestamp(),
        'totalAmount': totalAmount,
        'products': selectedProducts
            .map((saleProduct) => {
                  'productId': saleProduct.productId,
                  'name': saleProduct.name,
                  'price': saleProduct.price,
                  'quantity': saleProduct.quantity,
                })
            .toList(),
      });

      // Actualizar inventario en Firestore
      for (var inventoryUpdate in updatedInventory) {
        await FirebaseFirestore.instance
            .collection('inventories')
            .doc(inventoryUpdate['productId'])
            .update({
          'inventoryQuantity': inventoryUpdate['inventoryQuantity'],
        });
      }

      // Limpiar los productos seleccionados después de registrar la venta
      selectedProducts.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venta registrada correctamente'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la venta'),
        ),
      );
    }

    setState(() {});
  }

  List<Sale> createSalesFromProducts(List<SaleProduct> products) {
    return products.map((product) {
      return Sale(
        id: '', // Puedes generar un ID aquí si es necesario
        timestamp: DateTime.now(),
        totalAmount: product.price * product.quantity,
        products: [
          SaleProduct(
            productId: product.productId,
            name: product.name,
            price: product.price,
            quantity: product.quantity,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta de Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(products[index].name),
                  subtitle: Text(
                    'Precio: \$${products[index].price.toStringAsFixed(2)} - Cantidad disponible: ${products[index].inventoryQuantity.toString()}',
                  ),
                  onTap: () {
                    addProductToSale(products[index]);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(selectedProducts[index].name),
                  subtitle: Text(
                    'Cantidad: ${selectedProducts[index].quantity.toString()}',
                  ),
                  onTap: () {
                    removeProductFromSale(selectedProducts[index]);
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: selectedProducts.isEmpty ? null : registerSale,
            child: Text('Registrar Venta'),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (index) {
        setState(() {
          if (index != 2) {
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

void main() {
  runApp(MaterialApp(
    home: SalesScreen(),
  ));
}
