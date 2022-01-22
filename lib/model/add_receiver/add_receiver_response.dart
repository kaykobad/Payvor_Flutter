class AddReceiverResponse {
  Status status;
  Data data;
  StrAc strAc;
  BankAc bankAc;

  AddReceiverResponse({this.status, this.data, this.strAc, this.bankAc});

  AddReceiverResponse.fromJson(Map<String, dynamic> json) {
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    strAc = json['str_ac'] != null ? new StrAc.fromJson(json['str_ac']) : null;
    bankAc =
        json['bank_ac'] != null ? new BankAc.fromJson(json['bank_ac']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    if (this.strAc != null) {
      data['str_ac'] = this.strAc.toJson();
    }
    if (this.bankAc != null) {
      data['bank_ac'] = this.bankAc.toJson();
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

class Data {
  String object;
  int created;
  int expiresAt;
  String url;

  Data({this.object, this.created, this.expiresAt, this.url});

  Data.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    created = json['created'];
    expiresAt = json['expires_at'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['created'] = this.created;
    data['expires_at'] = this.expiresAt;
    data['url'] = this.url;
    return data;
  }
}

class StrAc {
  String id;
  String object;
  BusinessProfile businessProfile;
  String businessType;
  Capabilities capabilities;
  bool chargesEnabled;
  Company company;
  String country;
  int created;
  String defaultCurrency;
  bool detailsSubmitted;
  String email;
  ExternalAccounts externalAccounts;
  FutureRequirements futureRequirements;
  Individual individual;
  bool payoutsEnabled;
  Settings settings;
  TosAcceptance tosAcceptance;
  String type;

  StrAc(
      {this.id,
      this.object,
      this.businessProfile,
      this.businessType,
      this.capabilities,
      this.chargesEnabled,
      this.company,
      this.country,
      this.created,
      this.defaultCurrency,
      this.detailsSubmitted,
      this.email,
      this.externalAccounts,
      this.futureRequirements,
      this.individual,
      this.payoutsEnabled,
      this.settings,
      this.tosAcceptance,
      this.type});

  StrAc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    businessProfile = json['business_profile'] != null
        ? new BusinessProfile.fromJson(json['business_profile'])
        : null;
    businessType = json['business_type'];
    capabilities = json['capabilities'] != null
        ? new Capabilities.fromJson(json['capabilities'])
        : null;
    chargesEnabled = json['charges_enabled'];
    company =
        json['company'] != null ? new Company.fromJson(json['company']) : null;
    country = json['country'];
    created = json['created'];
    defaultCurrency = json['default_currency'];
    detailsSubmitted = json['details_submitted'];
    email = json['email'];
    externalAccounts = json['external_accounts'] != null
        ? new ExternalAccounts.fromJson(json['external_accounts'])
        : null;
    futureRequirements = json['future_requirements'] != null
        ? new FutureRequirements.fromJson(json['future_requirements'])
        : null;
    individual = json['individual'] != null
        ? new Individual.fromJson(json['individual'])
        : null;
    payoutsEnabled = json['payouts_enabled'];
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    tosAcceptance = json['tos_acceptance'] != null
        ? new TosAcceptance.fromJson(json['tos_acceptance'])
        : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['object'] = this.object;
    if (this.businessProfile != null) {
      data['business_profile'] = this.businessProfile.toJson();
    }
    data['business_type'] = this.businessType;
    if (this.capabilities != null) {
      data['capabilities'] = this.capabilities.toJson();
    }
    data['charges_enabled'] = this.chargesEnabled;
    if (this.company != null) {
      data['company'] = this.company.toJson();
    }
    data['country'] = this.country;
    data['created'] = this.created;
    data['default_currency'] = this.defaultCurrency;
    data['details_submitted'] = this.detailsSubmitted;
    data['email'] = this.email;
    if (this.externalAccounts != null) {
      data['external_accounts'] = this.externalAccounts.toJson();
    }
    if (this.futureRequirements != null) {
      data['future_requirements'] = this.futureRequirements.toJson();
    }
    if (this.individual != null) {
      data['individual'] = this.individual.toJson();
    }
    data['payouts_enabled'] = this.payoutsEnabled;
    if (this.settings != null) {
      data['settings'] = this.settings.toJson();
    }
    if (this.tosAcceptance != null) {
      data['tos_acceptance'] = this.tosAcceptance.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class BusinessProfile {
  String mcc;
  String name;
  String productDescription;
  String supportAddress;
  String supportEmail;
  String supportPhone;
  String supportUrl;
  String url;

  BusinessProfile(
      {this.mcc,
      this.name,
      this.productDescription,
      this.supportAddress,
      this.supportEmail,
      this.supportPhone,
      this.supportUrl,
      this.url});

  BusinessProfile.fromJson(Map<String, dynamic> json) {
    mcc = json['mcc'];
    name = json['name'];
    productDescription = json['product_description'];
    supportAddress = json['support_address'];
    supportEmail = json['support_email'];
    supportPhone = json['support_phone'];
    supportUrl = json['support_url'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mcc'] = this.mcc;
    data['name'] = this.name;
    data['product_description'] = this.productDescription;
    data['support_address'] = this.supportAddress;
    data['support_email'] = this.supportEmail;
    data['support_phone'] = this.supportPhone;
    data['support_url'] = this.supportUrl;
    data['url'] = this.url;
    return data;
  }
}

class Capabilities {
  String cardPayments;
  String transfers;

  Capabilities({this.cardPayments, this.transfers});

  Capabilities.fromJson(Map<String, dynamic> json) {
    cardPayments = json['card_payments'];
    transfers = json['transfers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_payments'] = this.cardPayments;
    data['transfers'] = this.transfers;
    return data;
  }
}

class Company {
  Address address;
  bool directorsProvided;
  bool executivesProvided;
  Null name;
  bool ownersProvided;
  bool taxIdProvided;
  Verification verification;

  Company(
      {this.address,
      this.directorsProvided,
      this.executivesProvided,
      this.name,
      this.ownersProvided,
      this.taxIdProvided,
      this.verification});

  Company.fromJson(Map<String, dynamic> json) {
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    directorsProvided = json['directors_provided'];
    executivesProvided = json['executives_provided'];
    name = json['name'];
    ownersProvided = json['owners_provided'];
    taxIdProvided = json['tax_id_provided'];
    verification = json['verification'] != null
        ? new Verification.fromJson(json['verification'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['directors_provided'] = this.directorsProvided;
    data['executives_provided'] = this.executivesProvided;
    data['name'] = this.name;
    data['owners_provided'] = this.ownersProvided;
    data['tax_id_provided'] = this.taxIdProvided;
    if (this.verification != null) {
      data['verification'] = this.verification.toJson();
    }
    return data;
  }
}

class Address {
  Null city;
  String country;
  Null line1;
  Null line2;
  Null postalCode;
  Null state;

  Address(
      {this.city,
      this.country,
      this.line1,
      this.line2,
      this.postalCode,
      this.state});

  Address.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    line1 = json['line1'];
    line2 = json['line2'];
    postalCode = json['postal_code'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    data['country'] = this.country;
    data['line1'] = this.line1;
    data['line2'] = this.line2;
    data['postal_code'] = this.postalCode;
    data['state'] = this.state;
    return data;
  }
}

class Verification {
  Document document;

  Verification({this.document});

  Verification.fromJson(Map<String, dynamic> json) {
    document = json['document'] != null
        ? new Document.fromJson(json['document'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.document != null) {
      data['document'] = this.document.toJson();
    }
    return data;
  }
}

class Document {
  Null back;
  Null details;
  Null detailsCode;
  Null front;

  Document({this.back, this.details, this.detailsCode, this.front});

  Document.fromJson(Map<String, dynamic> json) {
    back = json['back'];
    details = json['details'];
    detailsCode = json['details_code'];
    front = json['front'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['back'] = this.back;
    data['details'] = this.details;
    data['details_code'] = this.detailsCode;
    data['front'] = this.front;
    return data;
  }
}

class ExternalAccounts {
  String object;
  bool hasMore;
  int totalCount;
  String url;

  ExternalAccounts({this.object, this.hasMore, this.totalCount, this.url});

  ExternalAccounts.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    hasMore = json['has_more'];
    totalCount = json['total_count'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['has_more'] = this.hasMore;
    data['total_count'] = this.totalCount;
    data['url'] = this.url;
    return data;
  }
}

class FutureRequirements {
  String currentDeadline;
  String disabledReason;

  FutureRequirements({this.currentDeadline, this.disabledReason});

  FutureRequirements.fromJson(Map<String, dynamic> json) {
    currentDeadline = json['current_deadline'];
    disabledReason = json['disabled_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}

class Individual {
  String id;
  String object;
  String account;
  Address address;
  int created;
  Dob dob;
  String email;
  String firstName;
  FutureRequirements futureRequirements;
  String lastName;
  List<Null> metadata;
  Relationship relationship;
  Verification verification;

  Individual(
      {this.id,
      this.object,
      this.account,
      this.address,
      this.created,
      this.dob,
      this.email,
      this.firstName,
      this.futureRequirements,
      this.lastName,
      this.metadata,
      this.relationship,
      this.verification});

  Individual.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    account = json['account'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    created = json['created'];
    dob = json['dob'] != null ? new Dob.fromJson(json['dob']) : null;
    email = json['email'];
    firstName = json['first_name'];
    futureRequirements = json['future_requirements'] != null
        ? new FutureRequirements.fromJson(json['future_requirements'])
        : null;
    lastName = json['last_name'];
    relationship = json['relationship'] != null
        ? new Relationship.fromJson(json['relationship'])
        : null;
    verification = json['verification'] != null
        ? new Verification.fromJson(json['verification'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['object'] = this.object;
    data['account'] = this.account;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['created'] = this.created;
    if (this.dob != null) {
      data['dob'] = this.dob.toJson();
    }
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    if (this.futureRequirements != null) {
      data['future_requirements'] = this.futureRequirements.toJson();
    }
    data['last_name'] = this.lastName;
    if (this.relationship != null) {
      data['relationship'] = this.relationship.toJson();
    }
    if (this.verification != null) {
      data['verification'] = this.verification.toJson();
    }
    return data;
  }
}

class Dob {
  String day;
  String month;
  String year;

  Dob({this.day, this.month, this.year});

  Dob.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['month'] = this.month;
    data['year'] = this.year;
    return data;
  }
}

class Relationship {
  bool director;
  bool executive;
  bool owner;
  Null percentOwnership;
  bool representative;
  Null title;

  Relationship(
      {this.director,
      this.executive,
      this.owner,
      this.percentOwnership,
      this.representative,
      this.title});

  Relationship.fromJson(Map<String, dynamic> json) {
    director = json['director'];
    executive = json['executive'];
    owner = json['owner'];
    percentOwnership = json['percent_ownership'];
    representative = json['representative'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['director'] = this.director;
    data['executive'] = this.executive;
    data['owner'] = this.owner;
    data['percent_ownership'] = this.percentOwnership;
    data['representative'] = this.representative;
    data['title'] = this.title;
    return data;
  }
}

class Settings {
  Branding branding;
  CardIssuing cardIssuing;
  CardPayments cardPayments;
  Dashboard dashboard;
  Payments payments;
  Payouts payouts;
  List<Null> sepaDebitPayments;

  Settings(
      {this.branding,
      this.cardIssuing,
      this.cardPayments,
      this.dashboard,
      this.payments,
      this.payouts,
      this.sepaDebitPayments});

  Settings.fromJson(Map<String, dynamic> json) {
    branding = json['branding'] != null
        ? new Branding.fromJson(json['branding'])
        : null;
    cardIssuing = json['card_issuing'] != null
        ? new CardIssuing.fromJson(json['card_issuing'])
        : null;
    cardPayments = json['card_payments'] != null
        ? new CardPayments.fromJson(json['card_payments'])
        : null;
    dashboard = json['dashboard'] != null
        ? new Dashboard.fromJson(json['dashboard'])
        : null;
    payments = json['payments'] != null
        ? new Payments.fromJson(json['payments'])
        : null;
    payouts =
        json['payouts'] != null ? new Payouts.fromJson(json['payouts']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.branding != null) {
      data['branding'] = this.branding.toJson();
    }
    if (this.cardIssuing != null) {
      data['card_issuing'] = this.cardIssuing.toJson();
    }
    if (this.cardPayments != null) {
      data['card_payments'] = this.cardPayments.toJson();
    }
    if (this.dashboard != null) {
      data['dashboard'] = this.dashboard.toJson();
    }
    if (this.payments != null) {
      data['payments'] = this.payments.toJson();
    }
    if (this.payouts != null) {
      data['payouts'] = this.payouts.toJson();
    }
    return data;
  }
}

class Branding {
  String icon;
  String logo;
  String primaryColor;
  String secondaryColor;

  Branding({this.icon, this.logo, this.primaryColor, this.secondaryColor});

  Branding.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    logo = json['logo'];
    primaryColor = json['primary_color'];
    secondaryColor = json['secondary_color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['logo'] = this.logo;
    data['primary_color'] = this.primaryColor;
    data['secondary_color'] = this.secondaryColor;
    return data;
  }
}

class CardIssuing {
  TosAcceptance tosAcceptance;

  CardIssuing({this.tosAcceptance});

  CardIssuing.fromJson(Map<String, dynamic> json) {
    tosAcceptance = json['tos_acceptance'] != null
        ? new TosAcceptance.fromJson(json['tos_acceptance'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tosAcceptance != null) {
      data['tos_acceptance'] = this.tosAcceptance.toJson();
    }
    return data;
  }
}

class TosAcceptance {
  int date;
  String ip;

  TosAcceptance({this.date, this.ip});

  TosAcceptance.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    ip = json['ip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['ip'] = this.ip;
    return data;
  }
}

class CardPayments {
  DeclineOn declineOn;
  String statementDescriptorPrefix;

  CardPayments({this.declineOn, this.statementDescriptorPrefix});

  CardPayments.fromJson(Map<String, dynamic> json) {
    declineOn = json['decline_on'] != null
        ? new DeclineOn.fromJson(json['decline_on'])
        : null;
    statementDescriptorPrefix = json['statement_descriptor_prefix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.declineOn != null) {
      data['decline_on'] = this.declineOn.toJson();
    }
    data['statement_descriptor_prefix'] = this.statementDescriptorPrefix;
    return data;
  }
}

class DeclineOn {
  bool avsFailure;
  bool cvcFailure;

  DeclineOn({this.avsFailure, this.cvcFailure});

  DeclineOn.fromJson(Map<String, dynamic> json) {
    avsFailure = json['avs_failure'];
    cvcFailure = json['cvc_failure'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avs_failure'] = this.avsFailure;
    data['cvc_failure'] = this.cvcFailure;
    return data;
  }
}

class Dashboard {
  Null displayName;
  String timezone;

  Dashboard({this.displayName, this.timezone});

  Dashboard.fromJson(Map<String, dynamic> json) {
    displayName = json['display_name'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['display_name'] = this.displayName;
    data['timezone'] = this.timezone;
    return data;
  }
}

class Payments {
  Null statementDescriptor;
  Null statementDescriptorKana;
  Null statementDescriptorKanji;

  Payments(
      {this.statementDescriptor,
      this.statementDescriptorKana,
      this.statementDescriptorKanji});

  Payments.fromJson(Map<String, dynamic> json) {
    statementDescriptor = json['statement_descriptor'];
    statementDescriptorKana = json['statement_descriptor_kana'];
    statementDescriptorKanji = json['statement_descriptor_kanji'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statement_descriptor'] = this.statementDescriptor;
    data['statement_descriptor_kana'] = this.statementDescriptorKana;
    data['statement_descriptor_kanji'] = this.statementDescriptorKanji;
    return data;
  }
}

class Payouts {
  bool debitNegativeBalances;
  Schedule schedule;
  Null statementDescriptor;

  Payouts(
      {this.debitNegativeBalances, this.schedule, this.statementDescriptor});

  Payouts.fromJson(Map<String, dynamic> json) {
    debitNegativeBalances = json['debit_negative_balances'];
    schedule = json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : null;
    statementDescriptor = json['statement_descriptor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['debit_negative_balances'] = this.debitNegativeBalances;
    if (this.schedule != null) {
      data['schedule'] = this.schedule.toJson();
    }
    data['statement_descriptor'] = this.statementDescriptor;
    return data;
  }
}

class Schedule {
  int delayDays;
  String interval;

  Schedule({this.delayDays, this.interval});

  Schedule.fromJson(Map<String, dynamic> json) {
    delayDays = json['delay_days'];
    interval = json['interval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delay_days'] = this.delayDays;
    data['interval'] = this.interval;
    return data;
  }
}

class BankAc {
  String id;
  String object;
  String account;
  String accountHolderName;
  Null accountHolderType;
  Null accountType;
  List<String> availablePayoutMethods;
  String bankName;
  String country;
  String currency;
  bool defaultForCurrency;
  String fingerprint;
  String last4;
  List<Null> metadata;
  String routingNumber;
  String status;

  BankAc(
      {this.id,
      this.object,
      this.account,
      this.accountHolderName,
      this.accountHolderType,
      this.accountType,
      this.availablePayoutMethods,
      this.bankName,
      this.country,
      this.currency,
      this.defaultForCurrency,
      this.fingerprint,
      this.last4,
      this.metadata,
      this.routingNumber,
      this.status});

  BankAc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    account = json['account'];
    accountHolderName = json['account_holder_name'];
    accountHolderType = json['account_holder_type'];
    accountType = json['account_type'];
    availablePayoutMethods = json['available_payout_methods'].cast<String>();
    bankName = json['bank_name'];
    country = json['country'];
    currency = json['currency'];
    defaultForCurrency = json['default_for_currency'];
    fingerprint = json['fingerprint'];
    last4 = json['last4'];
    routingNumber = json['routing_number'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['object'] = this.object;
    data['account'] = this.account;
    data['account_holder_name'] = this.accountHolderName;
    data['account_holder_type'] = this.accountHolderType;
    data['account_type'] = this.accountType;
    data['available_payout_methods'] = this.availablePayoutMethods;
    data['bank_name'] = this.bankName;
    data['country'] = this.country;
    data['currency'] = this.currency;
    data['default_for_currency'] = this.defaultForCurrency;
    data['fingerprint'] = this.fingerprint;
    data['last4'] = this.last4;
    data['routing_number'] = this.routingNumber;
    data['status'] = this.status;
    return data;
  }
}
