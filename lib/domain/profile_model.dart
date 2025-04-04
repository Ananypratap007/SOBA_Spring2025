/// A model that contains all information related to a user
class ProfileModel {
  ProfileModel({
    this.name,
    this.email,
    this.mobile,
  });

  /// The user's full name
  String? name;

  /// The user's email address
  String? email;

  /// The user's mobile phone number
  ///
  /// Note: This should include the area code
  String? mobile;
}

final dummyUsers = [
  _johnnyProfile,
  _sarahProfile,
];

final _johnnyProfile = ProfileModel(
  name: 'John Doe',
  email: 'abc@ou.edu',
  mobile: '405-555-1234',
);

final _sarahProfile = ProfileModel(
  name: 'John Doe',
  email: 'abc@ou.edu',
  mobile: '405-555-1234',
);
