class UserData {
  String docId;
  String points;
  String name;
  String email;
  String password;
  String address;
  String lat;
  String lng;
  String phoneNumber;
  String nationalId;
  String birthDate;
  String gender;
  String imgUrl;
  String aboutYou;
  String isVerify;
bool loading;
  UserData(
      {this.docId,
      this.address,
        this.lat,this.lng,
      this.nationalId,
      this.email,
      this.password,
      this.phoneNumber,
      this.name,
      this.points,
        this.aboutYou,
      this.imgUrl,
      this.gender,
        this.isVerify,
        this.loading =false,
      this.birthDate});
}
