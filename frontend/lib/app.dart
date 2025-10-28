import 'package:frontend/imports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "API",
      home: InventoryUploadPage(),
      debugShowCheckedModeBanner: false,
    );
  
  }
}
