///Email validator
String validateEmail(String value) {
  Pattern pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9.])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9.])?)*$";
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value) || value == null)
    return 'Enter a valid email address.';
  else
    return null;
}

///Password validator
String validatePassword(String value) {
  if (value.isEmpty) {
    return "Please Re-Enter New Password.";
  } else if (value.length < 8) {
    return "Password must be atleast 8 characters long.";
  } else {
    return null;
  }
}

///Phone number validator
String validateMobile(String value) {
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return 'Please enter mobile number.';
  } else if (!regExp.hasMatch(value)) {
    return 'Please enter valid mobile number.';
  }
  return null;
}

///Phone number validator
String validateNames(String value) {
  if (value.length <= 0) {
    return 'This field is required.';
  }
  return null;
}

String validateWeight(String value) {
  if (value.length == 0) {
    return 'This field is required.';
  }
  return null;
}
