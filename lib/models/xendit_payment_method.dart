class XenditPaymentMethod {
  final String id;
  final String name;
  final String type;
  final List<String>? availableBanks;

  XenditPaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.availableBanks,
  });
}

class PaymentMethods {
  static List<XenditPaymentMethod> getAllMethods() {
    return [
      // Virtual Account Banks
      XenditPaymentMethod(
        id: 'MANDIRI',
        name: 'Bank Mandiri',
        type: 'VIRTUAL_ACCOUNT',
      ),
      XenditPaymentMethod(
        id: 'BNI',
        name: 'Bank BNI',
        type: 'VIRTUAL_ACCOUNT',
      ),
      XenditPaymentMethod(
        id: 'BRI',
        name: 'Bank BRI',
        type: 'VIRTUAL_ACCOUNT',
      ),
      XenditPaymentMethod(
        id: 'PERMATA',
        name: 'Bank Permata',
        type: 'VIRTUAL_ACCOUNT',
      ),
      XenditPaymentMethod(
        id: 'DANA',
        name: 'DANA',
        type: 'EWALLET',
      ),
      XenditPaymentMethod(
        id: 'LINKAJA',
        name: 'LinkAja',
        type: 'EWALLET',
      ),
      XenditPaymentMethod(
        id: 'SHOPEEPAY',
        name: 'ShopeePay',
        type: 'EWALLET',
      ),
    ];
  }
}
