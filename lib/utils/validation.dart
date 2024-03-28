class Validation {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final int age = int.tryParse(value) ?? -1;
    if (age < 18 || age > 50) {
      return 'Invalid age. Age should be between 18 and 50';
    }

    return null;
  }

  static String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Write Something';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    // Email validation regex pattern
    const pattern =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';
    final regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    // Password validation criteria
    const minLength = 6; // Minimum password length
    // const pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    // final regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    // else if (value.length < minLength) {
    //   return 'Password must be at least $minLength characters long';
    // } else if (!regExp.hasMatch(value)) {
    //   return 'Password must contain at least one uppercase letter, one lowercase letter, and one digit';
    // }

    return null;
  }

  static String? validateMobileNumber(String? value) {
    // Mobile number validation regex pattern
    const pattern = r'^[0-9]{10}$';
    final regExp = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Enter a valid mobile number';
    }

    return null;
  }
}
