import 'dart:html' as html;

class AuthHelper {
  static void syncLoginToExtension(String accessToken) {
    // Send message to the window which extension content scripts listen to
    html.window.postMessage({
      'type': 'FANSYNC_LOGIN_SUCCESS',
      'token': accessToken,
    }, '*');
  }
}
