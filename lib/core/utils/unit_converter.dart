

class UnitConverter {
  UnitConverter._();


  static const Map<String, double> unitToGrams = {
    'g': 1,
    'kg': 1000,
    'ml': 1,
    'L': 1000,
    'piece': 100,
    'pieces': 100,
    'pcs': 100,
    'cup': 240,
    'cups': 240,
    'tbsp': 15,
    'tsp': 5,
    'cloves': 5,
  };


  static double toGrams(double quantity, String unit) {
    final factor = unitToGrams[unit.toLowerCase()] ?? 100;
    return quantity * factor;
  }


  static double calculatePricePer100g(
    double price,
    double quantity,
    String unit,
  ) {
    final gramsPerUnit = unitToGrams[unit.toLowerCase()] ?? 100;
    final totalGrams = quantity * gramsPerUnit;
    if (totalGrams <= 0) return 0;
    return (price / totalGrams) * 100;
  }


  static String formatPrice(double price) {
    if (price <= 0) return '-';
    return 'Rp${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }


  static double getConversionFactor(String fromUnit, String toUnit) {
    final fromFactor = unitToGrams[fromUnit.toLowerCase()] ?? 100;
    final toFactor = unitToGrams[toUnit.toLowerCase()] ?? 100;
    return fromFactor / toFactor;
  }
}
