import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ostad_assignment_flutter_4/pages/add_product.dart';
import 'package:ostad_assignment_flutter_4/pages/update_product.dart';
import 'package:ostad_assignment_flutter_4/utils/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _getProductListInProgress = true;
  List<ProductModel> productList = [];

  @override
  void initState() {
    super.initState();
    _getProductList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _getProductList,
        child: Visibility(
          visible: _getProductListInProgress == false,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.separated(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              return _productList(productList[index]);
            },
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProduct(),
            ),
          );
          if (result == true) {
            _getProductList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _productList(ProductModel product) {
    return ListTile(
      leading: Image.network(
        product.image,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
      ),
      title: Text(product.productName),
      subtitle: Wrap(
        spacing: 16,
        children: [
          Text('Unit Price: ${product.unitPrice}'),
          Text('Quantity: ${product.quantity}'),
          Text('Total Price: ${product.totalPrice}'),
        ],
      ),
      trailing: Wrap(
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProduct(product: product),
                ),
              );
              if (result == true) {
                _getProductList();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => {
              _showDeleteConfirmationDialog(product.id),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getProductList() async {
    _getProductListInProgress = true;
    setState(() {});
    productList.clear();
    const String apiURL = 'https://crud.teamrabbil.com/api/v1/ReadProduct';
    Uri uri = Uri.parse(apiURL);
    Response response = await get(uri);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      List<dynamic> jsonProductList = decodedData['data'];

      for (Map<String, dynamic> p in jsonProductList) {
        ProductModel productModel = ProductModel(
          id: p['_id'] ?? '',
          productName: p['ProductName'] ?? '',
          productCode: p['ProductCode'] ?? '',
          image: p['Img'] ?? '',
          unitPrice: p['UnitPrice'] ?? '',
          quantity: p['Qty'] ?? '',
          totalPrice: p['TotalPrice'] ?? '',
        );

        productList.add(productModel);
      }
      _getProductListInProgress = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          'Something went wrong...',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ));
    }

    setState(() {});
  }

  Future<void> _deleteProduct(String productId) async {
    _getProductListInProgress = true;
    setState(() {});
    String deleteProductUrl =
        'https://crud.teamrabbil.com/api/v1/DeleteProduct/$productId';
    Uri uri = Uri.parse(deleteProductUrl);
    Response response = await get(uri);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      _getProductList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Product has been successfully deleted!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
      _getProductListInProgress = false;
    } else {
      _getProductListInProgress = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Product deleting failed! Try again.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    setState(() {});
  }

  void _showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content:
              const Text('Are you sure that you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId);
                Navigator.pop(context);
              },
              child: const Text('Yes, Delete'),
            ),
          ],
        );
      },
    );
  }
}
