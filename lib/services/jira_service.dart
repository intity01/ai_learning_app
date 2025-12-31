import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service สำหรับเชื่อมต่อ Jira API
class JiraService {
  final String baseUrl; // เช่น 'https://your-company.atlassian.net'
  final String email;
  final String apiToken; // Jira API Token (ไม่ใช่ password)
  
  JiraService({
    required this.baseUrl,
    required this.email,
    required this.apiToken,
  });

  /// สร้าง Basic Auth header
  String get _authHeader {
    final credentials = base64Encode(utf8.encode('$email:$apiToken'));
    return 'Basic $credentials';
  }

  /// ดึงข้อมูล Issue จาก Jira
  Future<Map<String, dynamic>> getIssue(String issueKey) async {
    try {
      final url = Uri.parse('$baseUrl/rest/api/3/issue/$issueKey');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching issue: $e');
    }
  }

  /// ค้นหา Issues
  Future<Map<String, dynamic>> searchIssues({
    String? jql,
    int startAt = 0,
    int maxResults = 50,
  }) async {
    try {
      final jqlQuery = jql ?? 'order by created DESC';
      final url = Uri.parse(
        '$baseUrl/rest/api/3/search?jql=${Uri.encodeComponent(jqlQuery)}&startAt=$startAt&maxResults=$maxResults',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search issues: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching issues: $e');
    }
  }

  /// ดึงข้อมูล Project
  Future<List<dynamic>> getProjects() async {
    try {
      final url = Uri.parse('$baseUrl/rest/api/3/project');

      final response = await http.get(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as List<dynamic>;
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// สร้าง Issue ใหม่
  Future<Map<String, dynamic>> createIssue({
    required String projectKey,
    required String issueType,
    required String summary,
    String? description,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/rest/api/3/issue');

      final body = {
        'fields': {
          'project': {'key': projectKey},
          'summary': summary,
          'issuetype': {'name': issueType},
          if (description != null) 'description': {
            'type': 'doc',
            'version': 1,
            'content': [
              {
                'type': 'paragraph',
                'content': [
                  {'type': 'text', 'text': description}
                ]
              }
            ]
          },
          if (customFields != null) ...customFields,
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create issue: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  /// อัปเดต Issue
  Future<void> updateIssue(
    String issueKey,
    Map<String, dynamic> fields,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/rest/api/3/issue/$issueKey');

      final body = {'fields': fields};

      final response = await http.put(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update issue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating issue: $e');
    }
  }

  /// ดึงข้อมูล User
  Future<Map<String, dynamic>> getUser(String accountId) async {
    try {
      final url = Uri.parse('$baseUrl/rest/api/3/user?accountId=$accountId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': _authHeader,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }
}


