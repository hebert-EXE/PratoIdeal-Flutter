import '../models/place_models.dart';

/// Subconjunto de dados mockados (porte reduzido do `MOCK_RESTAURANTS` do web),
/// usado como fallback quando não há chave da Places API ou em modo dev.
const List<RestaurantCard> kMockRestaurants = [
  RestaurantCard(
    id: 'mock-1',
    name: 'La Bella Italia',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.8,
    distance: '800m',
    image:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=800',
    openUntil: '23:00',
    category: 'Italiana',
  ),
  RestaurantCard(
    id: 'mock-2',
    name: 'Sushi Master',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.5,
    distance: '1.2km',
    image:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=800',
    openUntil: '22:30',
    category: 'Japonesa',
  ),
  RestaurantCard(
    id: 'mock-3',
    name: 'Burguer Haven',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.2,
    distance: '2.5km',
    image:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800',
    openUntil: '00:00',
    category: 'Hambúrguer',
  ),
  RestaurantCard(
    id: 'mock-4',
    name: 'Veggie Delight',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.7,
    distance: '3.1km',
    image:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800',
    openUntil: '21:00',
    category: 'Saudável',
  ),
  RestaurantCard(
    id: 'mock-5',
    name: 'Figueira Rubaiyat',
    city: 'Santo André',
    state: 'SP',
    rating: 4.9,
    distance: '1.5km',
    image:
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&q=80&w=800',
    openUntil: '23:30',
    category: 'Carnes',
  ),
  RestaurantCard(
    id: 'mock-6',
    name: 'Braz Pizzaria',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.9,
    distance: '1.8km',
    image:
        'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&q=80&w=800',
    openUntil: '00:00',
    category: 'Pizza',
  ),
  RestaurantCard(
    id: 'mock-7',
    name: 'Green House Salads',
    city: 'São Paulo',
    state: 'SP',
    rating: 4.7,
    distance: '1.0km',
    image:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800',
    openUntil: '22:00',
    category: 'Saudável',
  ),
  RestaurantCard(
    id: 'mock-8',
    name: 'Peixe do Litoral',
    city: 'Santos',
    state: 'SP',
    rating: 4.6,
    distance: '500m',
    image:
        'https://images.unsplash.com/photo-1534482421-64566f976cfa?auto=format&fit=crop&q=80&w=800',
    openUntil: '22:00',
    category: 'Frutos do mar',
  ),
];
