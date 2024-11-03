class ProductModel {
  List<Product>? products;
  int? total;
  int? skip;
  int? limit;

  ProductModel({
    this.products,
    this.total,
    this.skip,
    this.limit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      products: json['products'] != null
          ? List<Product>.from(json['products'].map((item) => Product.fromJson(item)))
          : null,
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Product {
  int? id;
  String? title;
  String? description;
  String? category;
  double? price;
  double? discountPercentage;
  double? rating;
  int? stock;
  List<String>? tags;
  String? brand;
  String? sku;
  int? weight;
  String? warrantyInformation;
  String? shippingInformation;
  List<Review>? reviews;
  int? minimumOrderQuantity;
  List<String>? images;
  String? thumbnail;

  Product({
    this.id,
    this.title,
    this.description,
    this.category,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.warrantyInformation,
    this.shippingInformation,
    this.reviews,
    this.minimumOrderQuantity,
    this.images,
    this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: json['price']?.toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      rating: json['rating']?.toDouble(),
      stock: json['stock'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      brand: json['brand'],
      sku: json['sku'],
      weight: json['weight'],
      warrantyInformation: json['warrantyInformation'],
      shippingInformation: json['shippingInformation'],
      reviews: json['reviews'] != null ? List<Review>.from(json['reviews'].map((review) => Review.fromJson(review))) : null,
      minimumOrderQuantity: json['minimumOrderQuantity'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      thumbnail: json['thumbnail'],
    );
  }
}

class Review {
  int? rating;
  String? comment;
  DateTime? date;
  String? reviewerName;
  String? reviewerEmail;

  Review({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json['rating'],
      comment: json['comment'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      reviewerName: json['reviewerName'],
      reviewerEmail: json['reviewerEmail'],
    );
  }
}

class Category {
  final String slug;
  final String name;

  Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'],
      name: json['name'],
    );
  }
}

