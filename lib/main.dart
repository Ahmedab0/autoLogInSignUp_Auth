
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restful_api/auth_provider.dart';
import 'package:restful_api/splash.dart';

import 'add_products.dart';
import 'auth_screen.dart';
import 'product_details.dart';
import 'products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Products>(
          create: (_) => Products(),
          update: (context, value, previousProducts) =>
          previousProducts!..passingData(value.token!, previousProducts.productsList),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, value, _) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.orange,
            canvasColor: const Color.fromRGBO(255, 238, 219, 1)),
        debugShowCheckedModeBanner: false,
        home: value.isAuth
            ? const MyHomePage()
            : FutureBuilder(
                future: value.tryAutoLogin(),
                builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting ? const SplashScreen() : const AuthScreen(),
              ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    Provider.of<Products>(context, listen: false)
        .fetchData()
        .then((_) => _isLoading = false);

    super.initState();
  }

  Widget detailCard(id, tile, desc, price, imageUrl) {
    return Builder(
      builder: (innerContext) => TextButton(
        onPressed: () {
          print(id);
          Navigator.push(
            innerContext,
            MaterialPageRoute(builder: (_) => ProductDetails(id)),
          ).then(
              (id) => Provider.of<Products>(context, listen: false).delete(id));
        },
        child: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              elevation: 10,
              color: const Color.fromRGBO(115, 138, 119, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      width: 130,
                      child: Hero(
                        tag: id,
                        child: Image.network(imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          tile,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white),
                        SizedBox(
                          width: 200,
                          child: Text(
                            desc,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                        const Divider(color: Colors.white),
                        Text(
                          "\$$price",
                          style: const TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: true).productsList;

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (prodList.isEmpty
              ? const Center(
                  child: Text('No Products Added.',
                      style: TextStyle(fontSize: 22)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      await Provider.of<Products>(context, listen: false)
                          .fetchData(),
                  child: ListView(
                    children: prodList
                        .map(
                          (item) => detailCard(item.id, item.title,
                              item.description, item.price, item.imageUrl),
                        )
                        .toList(),
                  ),
                )),
      floatingActionButton: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor,
        ),
        child: TextButton.icon(
          label: const Text("Add Product",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddProduct())),
        ),
      ),
    );
  }
}
