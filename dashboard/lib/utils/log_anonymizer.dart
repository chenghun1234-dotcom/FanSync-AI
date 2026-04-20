class LogAnonymizer {
  static String filter(String text) {
    // 1. Email Redaction
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    // 2. Phone Number Redaction (Global)
    final phoneRegex = RegExp(r'(\+?\d{1,3}[-.\s]?)?(\d{2,4}[-.\s]?){2,3}\d{2,4}');
    // 3. Address Keyword Redaction (Basic)
    final addressKeywords = RegExp(r'(City|Street|Avenue|Road|Building|State|Zip|Province|District|Apartment|Room|Suite|Floor)\s*:?\s*[a-zA-Z0-9\s#\-,]+', caseSensitive: false);

    String filtered = text.replaceAll(emailRegex, '[EMAIL_REDACTED]');
    filtered = filtered.replaceAll(phoneRegex, '[PHONE_REDACTED]');
    filtered = filtered.replaceAll(addressKeywords, '[ADDRESS_REDACTED]');
    
    return filtered;
  }
}
