import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inter_process/product_model.dart';
import 'package:inter_process/product_detail.dart';
import 'package:inter_process/splash_screen.dart';
import 'package:shimmer/shimmer.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    )
);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<ProductModel> futureProducts;
  late Future<List<Category>> futureCategories;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isLoading = false;
  // bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
    futureProducts = fetchProducts(selectedCategory, searchQuery);
  }

  Future<List<Category>> fetchCategories() async {
    const String _url = 'https://dummyjson.com/products/categories';
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((category) => Category.fromJson(category)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<ProductModel> fetchProducts(String category, String query) async {
    String _url = query.isEmpty
        ? (category == 'All'
        ? 'https://dummyjson.com/products'
        : 'https://dummyjson.com/products/category/$category')
        : 'https://dummyjson.com/products/search?q=$query';
    try {
      setState(() {
        isLoading = true; // Start loading
      });
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ProductModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to Load Products');
      }
    } catch (e) {
      throw Exception('Failed to Load Products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearch() {
    setState(() {
      futureProducts = fetchProducts(selectedCategory, searchController.text);
    });
  }

  void _onCategorySelect(String category) {
    setState(() {
      selectedCategory = category;
      futureProducts = fetchProducts(selectedCategory, searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Find Your Perfect Pair", style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                children: <Widget>[
                  // Search Bar
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      searchQuery = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Search for products...",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: _onSearch,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Get Products List
                  FutureBuilder<List<Category>>(
                    future: futureCategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return Center(child: CircularProgressIndicator());
                        return _buildShimmerEffect();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Failed to fetch Category', style: TextStyle(color: Colors.red)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No categories found.', style: TextStyle(fontSize: 18)));
                      }

                      final categories = snapshot.data!;

                      return Container(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final category = index == 0 ? 'All' : categories[index - 1].slug;
                            final categoryName = index == 0 ? 'All' : categories[index - 1].name;

                            return GestureDetector(
                              onTap: () => _onCategorySelect(category),
                              child: _buildCategoryChip(categoryName, selectedCategory == category),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  FutureBuilder<ProductModel>(
                    future: futureProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return Center(child: CircularProgressIndicator());
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return _buildShimmerEffect();
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Failed to fetch data from the server. Please try again', style: TextStyle(color: Colors.red)));
                      } else if (!snapshot.hasData || snapshot.data!.products!.isEmpty) {
                        return Center(child: Text('No products found.', style: TextStyle(fontSize: 18)));
                      }

                      final products = snapshot.data!.products;

                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: products!.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductItem(
                            title: product.title!,
                            description: product.description!,
                            image: product.images![0],
                            tag: product.title!,
                            price: product.price!,
                            rating: product.rating!,
                            context: context,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Animated loading indicator
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            // child: Center(
            //   child: CircularProgressIndicator(),
            // ),
          ),
        ],
      ),
    );
  }

  // Product Categories
  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 16)),
      ),
    );
  }

  // Get Product
  Widget _buildProductItem({
    required String title,
    required String description,
    required String image,
    required String tag,
    required double price,
    required double rating,
    required BuildContext context,
  }) {
    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(title: title,image: image,description: description,rating: rating,price: price,)));
        },
        child: Container(
          height: 250,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.2)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("$title", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                    child: Text("\$$price", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  buildStarRating(rating)
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    // setState(() {
                    //   isFavorited = !isFavorited; // Toggle favorite status
                    // });
                    // print('Is Favorite : ${isFavorited}');
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Waiting From Server
Widget _buildShimmerEffect() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey.shade200!,
    child: Container(
      height: 250,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
    ),
  );
}

// Get Rating
Widget buildStarRating(double rating) {
  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;
  int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

  return Row(
    children: [
      for (int i = 0; i < fullStars; i++)
        Icon(Icons.star, color: Colors.yellow, size: 18),
      if (hasHalfStar)
        Icon(Icons.star_half, color: Colors.yellow, size: 18),
      for (int i = 0; i < emptyStars; i++)
        Icon(Icons.star_border, color: Colors.yellow, size: 18),
      SizedBox(width: 5),
      Text(
        "$rating",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ],
  );
}
