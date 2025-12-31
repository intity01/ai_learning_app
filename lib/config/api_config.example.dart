// api_config.example.dart
// 
// 📋 INSTRUCTIONS:
// 1. Copy this file to api_config.dart
// 2. Fill in your actual API keys below
// 3. Never commit api_config.dart to Git!

class ApiConfig {
  // 🔥 Google Gemini API Key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // 🎤 ElevenLabs API Key (optional - for voice features)
  // Get your key from: https://elevenlabs.io/app/settings/api-keys
  static const String elevenLabsApiKey = 'YOUR_ELEVENLABS_API_KEY_HERE';
  
  // 📊 Jira API (optional - for project management integration)
  // Get your token from: https://id.atlassian.com/manage-profile/security/api-tokens
  static const String jiraEmail = 'YOUR_EMAIL@example.com';
  static const String jiraApiToken = 'YOUR_JIRA_API_TOKEN';
  static const String jiraDomain = 'YOUR_DOMAIN.atlassian.net';
}

