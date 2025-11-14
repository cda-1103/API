import 'package:frontend/imports.dart';
import 'package:frontend/inventory_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "API",
      // home: InventoryCreen(),
      home: InventoryUploadPage(),
      debugShowCheckedModeBanner: false,
    );
  
  }
}
