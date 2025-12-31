# 🔗 การเชื่อมต่อ Jira API ใน Flutter App

## 📋 สิ่งที่ต้องเตรียม

### 1. Jira API Token
1. ไปที่ [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
2. คลิก **Create API token**
3. ตั้งชื่อ token (เช่น "Flutter App")
4. คัดลอก token ที่สร้าง (จะแสดงแค่ครั้งเดียว!)

### 2. Jira Base URL
- Cloud: `https://your-company.atlassian.net`
- Server: `https://jira.your-company.com`

### 3. Email
- ใช้ email ที่ใช้ login Jira

## 📦 ติดตั้ง Dependencies

เพิ่มใน `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

จากนั้นรัน:
```bash
flutter pub get
```

## 🔧 การใช้งาน

### 1. สร้าง JiraService Instance

```dart
final jiraService = JiraService(
  baseUrl: 'https://your-company.atlassian.net',
  email: 'your-email@example.com',
  apiToken: 'your-api-token-here',
);
```

### 2. ดึงข้อมูล Issue

```dart
try {
  final issue = await jiraService.getIssue('PROJ-123');
  print('Issue: ${issue['fields']['summary']}');
} catch (e) {
  print('Error: $e');
}
```

### 3. ค้นหา Issues

```dart
try {
  final results = await jiraService.searchIssues(
    jql: 'project = PROJ AND status = "In Progress"',
    maxResults: 10,
  );
  
  final issues = results['issues'] as List;
  for (var issue in issues) {
    print('${issue['key']}: ${issue['fields']['summary']}');
  }
} catch (e) {
  print('Error: $e');
}
```

### 4. สร้าง Issue ใหม่

```dart
try {
  final newIssue = await jiraService.createIssue(
    projectKey: 'PROJ',
    issueType: 'Task',
    summary: 'New Task from Flutter App',
    description: 'This is created from Flutter app',
  );
  
  print('Created issue: ${newIssue['key']}');
} catch (e) {
  print('Error: $e');
}
```

## 🔐 Security Best Practices

### 1. เก็บ Credentials อย่างปลอดภัย

**❌ ไม่ควรทำ:**
```dart
// Hardcode ในโค้ด
final jiraService = JiraService(
  baseUrl: 'https://company.atlassian.net',
  email: 'user@example.com',
  apiToken: 'hardcoded-token', // อันตราย!
);
```

**✅ ควรทำ:**
```dart
// ใช้ environment variables หรือ secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final apiToken = await storage.read(key: 'jira_api_token');

final jiraService = JiraService(
  baseUrl: await storage.read(key: 'jira_base_url') ?? '',
  email: await storage.read(key: 'jira_email') ?? '',
  apiToken: apiToken ?? '',
);
```

### 2. ใช้ .env file

สร้างไฟล์ `.env`:
```
JIRA_BASE_URL=https://your-company.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-token-here
```

เพิ่มใน `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.0.2
```

ใช้งาน:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final jiraService = JiraService(
  baseUrl: dotenv.env['JIRA_BASE_URL']!,
  email: dotenv.env['JIRA_EMAIL']!,
  apiToken: dotenv.env['JIRA_API_TOKEN']!,
);
```

**⚠️ อย่าลืมเพิ่ม `.env` ใน `.gitignore`!**

## 📱 ตัวอย่างการใช้งานใน Widget

```dart
class JiraIssuesPage extends StatefulWidget {
  @override
  _JiraIssuesPageState createState() => _JiraIssuesPageState();
}

class _JiraIssuesPageState extends State<JiraIssuesPage> {
  final jiraService = JiraService(
    baseUrl: 'https://your-company.atlassian.net',
    email: 'your-email@example.com',
    apiToken: 'your-token',
  );
  
  List<dynamic> issues = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final results = await jiraService.searchIssues(
        jql: 'project = PROJ ORDER BY created DESC',
        maxResults: 20,
      );
      
      setState(() {
        issues = results['issues'] as List;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: _loadIssues,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return ListTile(
          title: Text(issue['fields']['summary']),
          subtitle: Text(issue['key']),
          trailing: Text(issue['fields']['status']['name']),
        );
      },
    );
  }
}
```

## 🔍 JQL (Jira Query Language) Examples

```dart
// Issues ที่ assign ให้ฉัน
'assignee = currentUser()'

// Issues ที่อยู่ใน sprint ปัจจุบัน
'sprint in openSprints()'

// Issues ที่สร้างในสัปดาห์นี้
'created >= startOfWeek()'

// Issues ที่มี priority สูง
'priority = High'

// Issues ที่เกี่ยวข้องกับ project นี้
'project = PROJ'
```

## 📚 Jira REST API Documentation

- [Jira REST API v3](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- [Authentication](https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/)
- [JQL Syntax](https://www.atlassian.com/software/jira/guides/expand-jira/jql)

## ⚠️ ข้อควรระวัง

1. **Rate Limiting**: Jira มี rate limit ตรวจสอบ quota
2. **Permissions**: ต้องมีสิทธิ์ที่เหมาะสม
3. **API Version**: ใช้ API v3 (ล่าสุด)
4. **Error Handling**: จัดการ errors ให้ดี

## 🎯 Next Steps

1. ✅ ติดตั้ง `http` package
2. ✅ สร้าง Jira API Token
3. ✅ ใช้ `JiraService` ในแอป
4. ✅ เก็บ credentials อย่างปลอดภัย
5. ✅ เพิ่ม error handling
6. ✅ ทดสอบการเชื่อมต่อ

---

**ต้องการความช่วยเหลือเพิ่มเติมไหม?** 🚀


