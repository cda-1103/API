

import 'package:flutter/material.dart';
import 'package:frontend/comunication_api.dart';

import 'package:frontend/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen ({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>{
  final ApiService _apiService = ApiService();

  late Future <List<Product>> _inventoryFuture;

  bool _filterInSock = false;

  @override
  void initState(){
    super.initState();
    _updateData();
  }

  void _updateData(){
    setState(() {
      _inventoryFuture = _apiService.getInventory(filterByStock: _filterInSock);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filtrar solo con stock mayor a 0",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _filterInSock,
                  onChanged: (bool newValue){
                    setState(() {
                      _filterInSock = newValue;
                    });
                    _updateData();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _inventoryFuture,
              builder: (context, snapshot){

                if (snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator() ,
                    );
                }

                if(snapshot.hasError){
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error al cargar el inventario: \n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty){
                  return const Center(
                    child: Text(
                      "No se encontraron productos,",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final products = snapshot.data!;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index){
                    final product = products[index];
                    return ListTile(
                      title: Text(product.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text("Serial: ${product.serialNumber}"),
                      trailing: Chip(
                        label: Text(
                          "Stock: ${product.quantity.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: product.quantity > 0
                          ? Colors.green
                          : Colors.red,
                      ),
                    );
                  },
                );
              },
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateData,
        tooltip: 'Refrescar',
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}