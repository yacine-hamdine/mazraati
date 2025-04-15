class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Simple regex for international phone numbers
    final phoneRegExp = RegExp(r'^\+?[0-9\s\-\(\)]{8,}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    if (value.length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a product name';
    }
    if (value.length < 3) {
      return 'Product name must be at least 3 characters';
    }
    return null;
  }
  
  static String? validateProductPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    
    try {
      final price = double.parse(value);
      if (price <= 0) {
        return 'Price must be greater than zero';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  static String? validateProductStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter available stock';
    }
    
    try {
      final stock = double.parse(value);
      if (stock < 0) {
        return 'Stock cannot be negative';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}