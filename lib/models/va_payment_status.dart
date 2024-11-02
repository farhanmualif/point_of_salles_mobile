class VAPaymentStatus {
  final String id;
  final String ownerId;
  final String externalId;
  final String accountNumber;
  final String bankCode;
  final String merchantCode;
  final String name;
  final bool isClosed;
  final int expectedAmount;
  final String expirationDate;
  final bool isSingleUse;
  final String status;
  final String currency;
  final String country;

  VAPaymentStatus({
    required this.id,
    required this.ownerId,
    required this.externalId,
    required this.accountNumber,
    required this.bankCode,
    required this.merchantCode,
    required this.name,
    required this.isClosed,
    required this.expectedAmount,
    required this.expirationDate,
    required this.isSingleUse,
    required this.status,
    required this.currency,
    required this.country,
  });

  factory VAPaymentStatus.fromJson(Map<String, dynamic> json) {
    return VAPaymentStatus(
      id: json['id'],
      ownerId: json['owner_id'],
      externalId: json['external_id'],
      accountNumber: json['account_number'],
      bankCode: json['bank_code'],
      merchantCode: json['merchant_code'],
      name: json['name'],
      isClosed: json['is_closed'],
      expectedAmount: json['expected_amount'],
      expirationDate: json['expiration_date'],
      isSingleUse: json['is_single_use'],
      status: json['status'],
      currency: json['currency'],
      country: json['country'],
    );
  }
}