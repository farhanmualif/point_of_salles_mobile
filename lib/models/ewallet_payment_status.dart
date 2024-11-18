class EWalletPaymentStatus {
  final String id;
  final String businessId;
  final String referenceId;
  final String status;
  final String currency;
  final int chargeAmount;
  final int captureAmount;
  final String? payerChargedCurrency;
  final int? payerChargedAmount;
  final int? refundedAmount;
  final String checkoutMethod;
  final String channelCode;
  final ChannelProperties channelProperties;
  final Actions actions;
  final bool isRedirectRequired;
  final String callbackUrl;
  final String created;
  final String updated;
  final String? voidStatus;
  final String? voidedAt;
  final bool captureNow;
  final String? customerId;
  final Customer customer;
  final String? paymentMethodId;
  final String? failureCode;
  final dynamic basket;
  final Map<String, dynamic> metadata;
  final dynamic shippingInformation;
  final PaymentDetail paymentDetail;

  EWalletPaymentStatus({
    required this.id,
    required this.businessId,
    required this.referenceId,
    required this.status,
    required this.currency,
    required this.chargeAmount,
    required this.captureAmount,
    this.payerChargedCurrency,
    this.payerChargedAmount,
    this.refundedAmount,
    required this.checkoutMethod,
    required this.channelCode,
    required this.channelProperties,
    required this.actions,
    required this.isRedirectRequired,
    required this.callbackUrl,
    required this.created,
    required this.updated,
    this.voidStatus,
    this.voidedAt,
    required this.captureNow,
    this.customerId,
    required this.customer,
    this.paymentMethodId,
    this.failureCode,
    this.basket,
    required this.metadata,
    this.shippingInformation,
    required this.paymentDetail,
  });

  factory EWalletPaymentStatus.fromJson(Map<String, dynamic> json) {
    return EWalletPaymentStatus(
      id: json['id'],
      businessId: json['business_id'],
      referenceId: json['reference_id'],
      status: json['status'],
      currency: json['currency'],
      chargeAmount: json['charge_amount'],
      captureAmount: json['capture_amount'],
      payerChargedCurrency: json['payer_charged_currency'],
      payerChargedAmount: json['payer_charged_amount'],
      refundedAmount: json['refunded_amount'],
      checkoutMethod: json['checkout_method'],
      channelCode: json['channel_code'],
      channelProperties: ChannelProperties.fromJson(json['channel_properties']),
      actions: Actions.fromJson(json['actions']),
      isRedirectRequired: json['is_redirect_required'],
      callbackUrl: json['callback_url'],
      created: json['created'],
      updated: json['updated'],
      voidStatus: json['void_status'],
      voidedAt: json['voided_at'],
      captureNow: json['capture_now'],
      customerId: json['customer_id'],
      customer: Customer.fromJson(json['customer']),
      paymentMethodId: json['payment_method_id'],
      failureCode: json['failure_code'],
      basket: json['basket'],
      metadata: Map<String, dynamic>.from(json['metadata']),
      shippingInformation: json['shipping_information'],
      paymentDetail: PaymentDetail.fromJson(json['payment_detail']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'reference_id': referenceId,
      'status': status,
      'currency': currency,
      'charge_amount': chargeAmount,
      'capture_amount': captureAmount,
      'payer_charged_currency': payerChargedCurrency,
      'payer_charged_amount': payerChargedAmount,
      'refunded_amount': refundedAmount,
      'checkout_method': checkoutMethod,
      'channel_code': channelCode,
      'channel_properties': channelProperties.toJson(),
      'actions': actions.toJson(),
      'is_redirect_required': isRedirectRequired,
      'callback_url': callbackUrl,
      'created': created,
      'updated': updated,
      'void_status': voidStatus,
      'voided_at': voidedAt,
      'capture_now': captureNow,
      'customer_id': customerId,
      'customer': customer.toJson(),
      'payment_method_id': paymentMethodId,
      'failure_code': failureCode,
      'basket': basket,
      'metadata': metadata,
      'shipping_information': shippingInformation,
      'payment_detail': paymentDetail.toJson(),
    };
  }
}

class ChannelProperties {
  final String successRedirectUrl;
  final String? failureRedirectUrl;

  ChannelProperties({
    required this.successRedirectUrl,
    this.failureRedirectUrl,
  });

  factory ChannelProperties.fromJson(Map<String, dynamic> json) {
    return ChannelProperties(
      successRedirectUrl: json['success_redirect_url'],
      failureRedirectUrl: json['failure_redirect_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success_redirect_url': successRedirectUrl,
      'failure_redirect_url': failureRedirectUrl,
    };
  }
}

class Actions {
  final String? desktopWebCheckoutUrl;
  final String? mobileWebCheckoutUrl;
  final String? mobileDeeplinkCheckoutUrl;
  final String? qrCheckoutString;

  Actions({
    this.desktopWebCheckoutUrl,
    this.mobileWebCheckoutUrl,
    this.mobileDeeplinkCheckoutUrl,
    this.qrCheckoutString,
  });

  factory Actions.fromJson(Map<String, dynamic> json) {
    return Actions(
      desktopWebCheckoutUrl: json['desktop_web_checkout_url'],
      mobileWebCheckoutUrl: json['mobile_web_checkout_url'],
      mobileDeeplinkCheckoutUrl: json['mobile_deeplink_checkout_url'],
      qrCheckoutString: json['qr_checkout_string'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desktop_web_checkout_url': desktopWebCheckoutUrl,
      'mobile_web_checkout_url': mobileWebCheckoutUrl,
      'mobile_deeplink_checkout_url': mobileDeeplinkCheckoutUrl,
      'qr_checkout_string': qrCheckoutString,
    };
  }
}

class Customer {
  final String? referenceId;
  final String givenNames;
  final String? surname;
  final String email; // tambahkan field lainnya
  // ...

  Customer({
    this.referenceId,
    required this.givenNames,
    this.surname,
    required this.email,
    // ...
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      referenceId: json['reference_id'],
      givenNames: json['given_names'],
      surname: json['surname'],
      email: json['email'],
      // ...
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_id': referenceId,
      'given_names': givenNames,
      'surname': surname,
      'email': email,
      // ...
    };
  }
}

class PaymentDetail {
  final String? fundSource;
  final String? source;

  PaymentDetail({
    this.fundSource,
    this.source,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      fundSource: json['fund_source'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fund_source': fundSource,
      'source': source,
    };
  }
}
