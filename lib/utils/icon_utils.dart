
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconUtils {
  static dynamic getIconData(String iconName) {
    switch (iconName) {
      case 'utensils': return FontAwesomeIcons.utensils;
      case 'car': return FontAwesomeIcons.car;
      case 'shopping-bag': return FontAwesomeIcons.bagShopping;
      case 'gamepad': return FontAwesomeIcons.gamepad;
      case 'money-bill': return FontAwesomeIcons.moneyBill;
      case 'gift': return FontAwesomeIcons.gift;
      case 'laptop-code': return FontAwesomeIcons.laptopCode;
      case 'hospital': return FontAwesomeIcons.hospital;
      case 'graduation-cap': return FontAwesomeIcons.graduationCap;
      case 'house': return FontAwesomeIcons.house;
      case 'phone': return FontAwesomeIcons.phone;
      case 'plane': return FontAwesomeIcons.plane;
      case 'shopping_cart': return FontAwesomeIcons.cartShopping;
      case 'local_taxi': return FontAwesomeIcons.taxi;
      case 'flight': return FontAwesomeIcons.plane;
      case 'fastfood': return FontAwesomeIcons.burger;
      case 'cake': return FontAwesomeIcons.cakeCandles;
      case 'icecream': return FontAwesomeIcons.iceCream;
      case 'rice_bowl': return FontAwesomeIcons.bowlRice;
      case 'breakfast_dining': return FontAwesomeIcons.egg;
      case 'directions_boat': return FontAwesomeIcons.ship;
      case 'donut_large': return FontAwesomeIcons.chartPie;
      case 'videocam': return FontAwesomeIcons.video;
      case 'coffee': return FontAwesomeIcons.mugHot;
      case 'star': return FontAwesomeIcons.star;
      case 'checkroom': return FontAwesomeIcons.shirt;
      case 'straighten': return FontAwesomeIcons.ruler;
      case 'wine_bar': return FontAwesomeIcons.wineGlass;
      case 'help':
      case 'question':
      default: return FontAwesomeIcons.circleQuestion;
    }
  }
}
