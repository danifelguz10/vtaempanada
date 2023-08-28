import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'listproducts_screen.dart';
import '/models/product.dart';
import 'sales_screen.dart';
import 'db/firebase_service.dart';
import 'models/deptor.dart';

class DebtorsScreen extends StatefulWidget {
  @override
  _DebtorsScreenState createState() => _DebtorsScreenState();
}

class _DebtorsScreenState extends State<DebtorsScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController debtorNameController = TextEditingController();
  final TextEditingController debtorAmountController = TextEditingController();
  Product? selectedProduct;
  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deudores')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: debtorNameController,
                  decoration: InputDecoration(labelText: 'Nombre del Deudor'),
                ),
                TextField(
                  controller: debtorAmountController,
                  decoration: InputDecoration(labelText: 'Monto Adeudado'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: addDebtor,
                  child: Text('Agregar Deudor'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white, // Cambia esto al color de fondo deseado
              child: StreamBuilder<List<Debtor>>(
                stream: firestoreService.getDebtorsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<Debtor> debtors = snapshot.data!;

                  return ListView.builder(
                    itemCount: debtors.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(debtors[index].name),
                        subtitle: Text(
                            'Monto: \$${debtors[index].amount.toStringAsFixed(2)}'),
                        trailing: debtors[index].isPaid
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: Icon(Icons.check_circle_outline),
                                onPressed: () => markAsPaid(debtors[index]),
                              ),
                        onTap: () => deleteDebtor(debtors[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1, // Cambia el índice según la vista actual
      onTap: (index) {
        setState(() {
          if (index != 1) {
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

  void addDebtor() {
    String debtorName = debtorNameController.text;
    double debtorAmount = double.parse(debtorAmountController.text);

    Debtor newDebtor = Debtor(
      id: '', // Firestore generará un nuevo ID para el documento
      name: debtorName,
      amount: debtorAmount,
    );

    // Inserta el nuevo deudor en Firestore directamente
    firestoreService.createDebtor(newDebtor);

    // Limpia los campos de entrada
    debtorNameController.clear();
    debtorAmountController.clear();
  }

  void markAsPaid(Debtor debtor) {
    // Implementa aquí la lógica para actualizar el estado de pago en Firestore
    firestoreService.updateDebtorPaymentStatus(debtor.id, true);
  }

  void deleteDebtor(Debtor debtor) {
    // Implementa aquí la lógica para eliminar el deudor de Firestore
    firestoreService.deleteDebtor(debtor.id);
  }
}
