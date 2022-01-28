class Coupon {
  String docId;
  String couponName;
  String discountPercentage;
  String numberOfUses;
  String expiryDate;
  bool loading;

  Coupon(
      {this.docId,
      this.couponName,
      this.discountPercentage,
      this.numberOfUses,
      this.expiryDate,
      this.loading= false});
}
