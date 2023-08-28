import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '/db/firebase_service.dart';
import '/models/sale.dart';
import '/saledetails_screen.dart';

class SalesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Ventas')),
      body: StreamBuilder<List<Sale>>(
        stream: FirestoreService().getSalesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No hay ventas registradas.'),
            );
          }

          // Ordenar las ventas por fecha y hora
          snapshot.data!.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final sale = snapshot.data![index];

              // Formatear la fecha y la hora
              final formattedDate =
                  DateFormat('yyyy-MM-dd').format(sale.timestamp);
              final formattedTime =
                  DateFormat('hh:mm a').format(sale.timestamp);

              return ListTile(
                title: Text('Fecha: $formattedDate, Hora: $formattedTime'),
                subtitle:
                    Text('Total: \$${sale.totalAmount.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaleDetailsScreen(sale: sale),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
