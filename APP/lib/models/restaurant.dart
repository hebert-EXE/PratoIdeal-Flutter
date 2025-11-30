class Restaurant {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String imageUrl;
  final String phone;
  final String priceRange;
  final Address address;

  Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.imageUrl,
    required this.phone,
    required this.priceRange,
    required this.address,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['Id'] ?? json['id'] ?? '',
      name: json['Nome'] ?? json['nome'] ?? '',
      category: json['Categoria'] ?? json['categoria'] ?? '',
      rating: (json['AvaliacaoMedia'] ?? json['avaliacaoMedia'] ?? 0).toDouble(),
      imageUrl: json['Foto'] ?? json['foto'] ?? '',
      phone: json['Telefone'] ?? json['telefone'] ?? '',
      priceRange: json['FaixaPreco'] ?? json['faixaPreco'] ?? '',
      address: Address.fromJson(json['Endereco'] ?? json['endereco'] ?? {}),
    );
  }
}

class Address {
  final String street;
  final int number;
  final String city;
  final String state;

  Address({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['Rua'] ?? json['rua'] ?? '',
      number: json['Numero'] ?? json['numero'] ?? 0,
      city: json['Cidade'] ?? json['cidade'] ?? '',
      state: json['Estado'] ?? json['estado'] ?? '',
    );
  }
  
  @override
  String toString() {
    return '$street, $number - $city/$state';
  }
}
