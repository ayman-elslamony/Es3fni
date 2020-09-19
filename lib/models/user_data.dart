class UserData {
  String docId;
  String points;
  String name;
  String email;
  String password;
  String address;
  String phoneNumber;
  String nationalId;
  String birthDate;
  String gender;
  String imgUrl;
  String aboutYou;
bool loading;
  UserData(
      {this.docId,
      this.address,
      this.nationalId,
      this.email,
      this.password,
      this.phoneNumber,
      this.name,
      this.points,
        this.aboutYou,
      this.imgUrl,
      this.gender,
        this.loading =false,
      this.birthDate});
}
