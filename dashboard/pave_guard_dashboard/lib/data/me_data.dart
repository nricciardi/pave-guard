class MeData {

  String firstName;
  String lastName;
  String createdAt;
  String email;
  String id;

  MeData(this.firstName, this.lastName, this.createdAt, this.email, this.id);

  String getFirstName(){ return firstName; }
  String getLastName(){ return lastName; }
  String getCreatedAt(){ return createdAt; }
  String getEmail(){ return email; }
  String getId(){ return id; }

}