# 🔧 การตั้งค่า MCP (Model Context Protocol) สำหรับ Claude Memory

## 📋 MCP คืออะไร?

MCP (Model Context Protocol) เป็นโปรโตคอลที่ช่วยให้ AI assistants เช่น Claude สามารถ:
- เข้าถึงข้อมูลจาก external sources
- เก็บและเรียกใช้ context ระหว่างการสนทนา
- เชื่อมต่อกับ tools และ services ต่างๆ

## 🚀 วิธีตั้งค่า MCP ใน Cursor

### วิธีที่ 1: ใช้ Cursor Settings (แนะนำ)

1. **เปิด Cursor Settings**
   - กด `Ctrl+,` (Windows/Linux) หรือ `Cmd+,` (Mac)
   - หรือ File → Preferences → Settings

2. **ค้นหา "MCP" หรือ "Model Context Protocol"**

3. **เพิ่ม MCP Server Configuration**

### วิธีที่ 2: แก้ไขไฟล์ Config โดยตรง

#### สำหรับ Cursor/VS Code:

สร้างหรือแก้ไขไฟล์: `%APPDATA%\Cursor\User\settings.json` (Windows)

```json
{
  "mcp.servers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {}
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/directory"
      ]
    }
  }
}
```

#### สำหรับ macOS:
`~/Library/Application Support/Cursor/User/settings.json`

#### สำหรับ Linux:
`~/.config/Cursor/User/settings.json`

## 📦 ติดตั้ง MCP Servers

### 1. Memory Server (สำหรับ Claude Memory)

```bash
npm install -g @modelcontextprotocol/server-memory
```

หรือใช้ npx (ไม่ต้องติดตั้ง):
```bash
npx -y @modelcontextprotocol/server-memory
```

### 2. Filesystem Server (สำหรับเข้าถึงไฟล์)

```bash
npm install -g @modelcontextprotocol/server-filesystem
```

### 3. GitHub Server (ถ้าต้องการ)

```bash
npm install -g @modelcontextprotocol/server-github
```

## 🔧 Configuration Example

### ไฟล์ `.cursor/mcp.json` (สร้างในโปรเจกต์)

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "MEMORY_STORAGE_PATH": "./.cursor/memory"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${workspaceFolder}"
      ]
    }
  }
}
```

## 🎯 ข้อมูลที่ควรเก็บใน Memory

### 1. Project Information
```json
{
  "project": {
    "name": "Flutter AI Learning App",
    "type": "Flutter/Dart",
    "platform": "Android",
    "preferredEmulator": "pixel_6_-_api_34_naphat"
  }
}
```

### 2. Development Preferences
```json
{
  "preferences": {
    "primaryPlatform": "Android",
    "language": "Thai",
    "codeStyle": "Flutter Best Practices",
    "stateManagement": "ValueNotifier"
  }
}
```

### 3. Known Issues
```json
{
  "issues": {
    "pixel_7_api_35": "Exit code 1 error - use Pixel 6 instead",
    "deprecationWarnings": "72 withOpacity warnings - should use withValues"
  }
}
```

## 🔍 ตรวจสอบว่า MCP ทำงาน

### 1. ตรวจสอบใน Cursor
- ดูที่ status bar ว่ามี MCP indicator หรือไม่
- ตรวจสอบ Developer Tools (Help → Toggle Developer Tools)

### 2. ทดสอบ Memory
- ถาม Claude เกี่ยวกับข้อมูลโปรเจกต์
- ตรวจสอบว่า Claude จำข้อมูลได้หรือไม่

## 📚 Resources

- [MCP Documentation](https://modelcontextprotocol.io/)
- [MCP GitHub](https://github.com/modelcontextprotocol)
- [Cursor MCP Guide](https://cursor.sh/docs/mcp)

## ⚠️ Troubleshooting

### ปัญหา: MCP ไม่ทำงาน

1. **ตรวจสอบ Node.js**
   ```bash
   node --version
   npm --version
   ```

2. **ตรวจสอบ MCP Server**
   ```bash
   npx -y @modelcontextprotocol/server-memory --version
   ```

3. **ตรวจสอบ Cursor Logs**
   - Help → Toggle Developer Tools
   - ดู Console สำหรับ errors

### ปัญหา: Memory ไม่ถูกเก็บ

1. ตรวจสอบว่า MCP server ทำงานอยู่
2. ตรวจสอบ permissions ของไฟล์
3. ตรวจสอบ storage path

## 🎯 Next Steps

1. ✅ ติดตั้ง Node.js (ถ้ายังไม่มี)
2. ✅ ติดตั้ง MCP Memory Server
3. ✅ ตั้งค่า Cursor settings
4. ✅ ทดสอบการทำงาน
5. ✅ เริ่มเก็บข้อมูลใน Memory

---

**ต้องการความช่วยเหลือเพิ่มเติมไหม?** 🚀


