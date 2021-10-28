class GetStripeResponse {
  Status status;
  Customer customer;

  GetStripeResponse({this.status, this.customer});

  GetStripeResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    return data;
  }
}

class Status {
  bool status;
  String message;
  int code;

  Status({this.status, this.message, this.code});

  Status.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

class Customer {
  String object;
  List<Data> data;
  bool hasMore;
  String url;

  Customer({this.object, this.data, this.hasMore, this.url});

  Customer.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    hasMore = json['has_more'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['has_more'] = this.hasMore;
    data['url'] = this.url;
    return data;
  }
}

class Data {
  String id;
  String object;
  String addressCity;
  String addressCountry;
  String addressLine1;
  String addressLine1Check;
  String addressLine2;
  String addressState;
  String addressZip;
  String addressZipCheck;
  String brand;
  String country;
  String customer;
  String cvcCheck;
  String dynamicLast4;
  int expMonth;
  int expYear;
  String fingerprint;
  String funding;
  String last4;
  String name;
  String tokenizationMethod;
  bool isCheck;

  Data(
      {this.id,
      this.object,
      this.addressCity,
      this.addressCountry,
      this.isCheck,
      this.addressLine1,
      this.addressLine1Check,
      this.addressLine2,
      this.addressState,
      this.addressZip,
      this.addressZipCheck,
      this.brand,
      this.country,
      this.customer,
      this.cvcCheck,
      this.dynamicLast4,
      this.expMonth,
      this.expYear,
      this.fingerprint,
      this.funding,
      this.last4,
      this.name,
      this.tokenizationMethod});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    addressCity = json['address_city'];
    addressCountry = json['address_country'];
    addressLine1 = json['address_line1'];
    addressLine1Check = json['address_line1_check'];
    addressLine2 = json['address_line2'];
    addressState = json['address_state'];
    addressZip = json['address_zip'];
    addressZipCheck = json['address_zip_check'];
    brand = json['brand'];
    country = json['country'];
    customer = json['customer'];
    cvcCheck = json['cvc_check'];
    dynamicLast4 = json['dynamic_last4'];
    expMonth = json['exp_month'];
    expYear = json['exp_year'];
    fingerprint = json['fingerprint'];
    funding = json['funding'];
    last4 = json['last4'];
    name = json['name'];
    isCheck = json['isCheck'];
    tokenizationMethod = json['tokenization_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['object'] = this.object;
    data['address_city'] = this.addressCity;
    data['address_country'] = this.addressCountry;
    data['address_line1'] = this.addressLine1;
    data['address_line1_check'] = this.addressLine1Check;
    data['address_line2'] = this.addressLine2;
    data['address_state'] = this.addressState;
    data['address_zip'] = this.addressZip;
    data['address_zip_check'] = this.addressZipCheck;
    data['brand'] = this.brand;
    data['country'] = this.country;
    data['customer'] = this.customer;
    data['cvc_check'] = this.cvcCheck;
    data['dynamic_last4'] = this.dynamicLast4;
    data['exp_month'] = this.expMonth;
    data['exp_year'] = this.expYear;
    data['fingerprint'] = this.fingerprint;
    data['funding'] = this.funding;
    data['last4'] = this.last4;
    data['name'] = this.name;
    data['isCheck'] = this.isCheck;
    data['tokenization_method'] = this.tokenizationMethod;
    return data;
  }
}