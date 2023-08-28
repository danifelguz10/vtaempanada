import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '/models/sale.dart';
import '/models/saleproduct.dart';
import '../models/deptor.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String username, String password) async {
    try {
      await _db.collection('users').add({
        'username': username,
        'password': password,
      });
      print('Usuario insertado en Firestore.');
    } catch (e) {
      print('Error al insertar usuario en Firestore: $e');
    }
  }

  Future<bool> verifyCredentials(String username, String password) async {
    try {
      final QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar las credenciales: $e');
      return false;
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      // Convierte el producto en un mapa y agrega la URL de la imagen
      Map<String, dynamic> productData = product.toMap();

      await _db.collection('products').add(productData);
      print('Producto insertado en Firestore.');
    } catch (e) {
      print('Error al insertar producto en Firestore: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // Obtiene la referencia del documento del producto
      DocumentReference productDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId);

      // Convierte el producto en un mapa y agrega la URL de la imagen
      Map<String, dynamic> productData = product.toMap();

      await productDocRef.update(productData);
      print('Producto actualizado en Firestore.');
    } catch (e) {
      print('Error al actualizar producto en Firestore: $e');
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      // Obtiene la referencia del documento del producto
      DocumentReference productDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId);

      await productDocRef.delete();
      print('Producto eliminado de Firestore.');
    } catch (e) {
      print('Error al eliminar producto en Firestore: $e');
    }
  }

  Future<String> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      print('No se seleccionó ninguna imagen.');
      return ''; // Cambia esto según tu lógica
    }
  }

  Future<void> addToInventory(Product product, int quantity) async {
    try {
      DocumentReference inventoryDocRef = FirebaseFirestore.instance
          .collection('inventories')
          .doc(); // Firestore generará un nuevo ID para el documento
      String inventoryProductId = inventoryDocRef.id; // Obtén el ID generado

      // Ahora puedes usar este ID en la colección inventories
      inventoryDocRef.set({
        'productId': inventoryProductId,
        'name': product.name,
        'price': product.price,
        'inventoryQuantity': quantity,
      });

      print('Producto agregado al inventario.');
    } catch (e) {
      print('Error al agregar producto al inventario: $e');
    }
  }

  Future<void> createDebtor(Debtor debtor) async {
    try {
      await _db.collection('debtors').add(debtor.toMap());
      print('Deudor insertado en Firestore: ${debtor.name}');
    } catch (e) {
      print('Error al insertar deudor en Firestore: $e');
    }
  }

  Future<void> updateDebtorPaymentStatus(String debtorId, bool isPaid) async {
    try {
      await _db.collection('debtors').doc(debtorId).update({
        'isPaid': isPaid,
      });
    } catch (e) {
      print('Error updating debtor payment status: $e');
    }
  }

  Future<void> deleteDebtor(String debtorId) async {
    try {
      await _db.collection('debtors').doc(debtorId).delete();
    } catch (e) {
      print('Error deleting debtor: $e');
    }
  }

  Stream<List<Debtor>> getDebtorsStream() {
    return _db.collection('debtors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Debtor(
          id: doc.id,
          name: data['name'],
          amount: data['amount'].toDouble(),
          isPaid: data['isPaid'],
        );
      }).toList();
    });
  }

  Stream<List<Sale>> getSalesStream() {
    return _db.collection('sales').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<SaleProduct> products = (data['products'] as List)
            .map((productData) => SaleProduct(
                  productId: productData['productId'],
                  name: productData['name'],
                  price: productData['price'],
                  quantity: productData['quantity'],
                ))
            .toList();

        return Sale(
          id: doc.id,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          totalAmount: data['totalAmount'],
          products: products,
        );
      }).toList();
    });
  }
}
