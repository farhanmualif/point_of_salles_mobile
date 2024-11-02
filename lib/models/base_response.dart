class BaseResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;

  BaseResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(Map<String, dynamic>)? fromJsonT,
  ]) {
    return BaseResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] is List
              ? (json['data'] as List).map((item) => fromJsonT!(item)).toList()
                  as T
              : fromJsonT!(json['data']))
          : null,
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(json['errors'].map((key, value) =>
              MapEntry(key, List<String>.from(value.map((e) => e.toString())))))
          : null,
    );
  }
}
