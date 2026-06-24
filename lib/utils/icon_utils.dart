import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'utensils': return Icons.restaurant;
      case 'car': return Icons.directions_car;
      case 'shopping-bag': return Icons.shopping_bag;
      case 'gamepad': return Icons.videogame_asset;
      case 'money-bill': return Icons.attach_money;
      case 'gift': return Icons.card_giftcard;
      case 'laptop-code': return Icons.laptop_mac;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'local_taxi': return Icons.local_taxi;
      case 'flight': return Icons.flight;
      case 'fastfood': return Icons.fastfood;
      case 'cake': return Icons.cake;
      case 'icecream': return Icons.icecream;
      case 'rice_bowl': return Icons.rice_bowl;
      case 'breakfast_dining': return Icons.breakfast_dining;
      case 'directions_boat': return Icons.directions_boat;
      case 'donut_large': return Icons.donut_large;
      case 'videocam': return Icons.videocam;
      case 'coffee': return Icons.local_cafe;
      case 'star': return Icons.star;
      case 'checkroom': return Icons.checkroom;
      case 'straighten': return Icons.straighten;
      case 'wine_bar': return Icons.wine_bar;
      default: return Icons.category;
    }
  }
}
