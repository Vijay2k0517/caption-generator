# 📸 Smart Caption Generator - Full Stack Application

<div align="center">

![Caption Generator](https://img.shields.io/badge/AI-Caption%20Generator-blue?style=for-the-badge&logo=robot)
![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B?style=for-the-badge&logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?style=for-the-badge&logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A production-ready, AI-powered Instagram caption generator with user authentication, conversation history, and SQLite database integration.**

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Usage](#-usage) • [API Documentation](#-api-documentation) • [Contributing](#-contributing) • [Contact](#-contact)

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Demo](#-demo)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Installation](#-installation)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Database Schema](#-database-schema)
- [Screenshots](#-screenshots)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [Future Enhancements](#-future-enhancements)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🌟 Overview

Smart Caption Generator is a full-stack mobile and web application that leverages Google's Gemini AI to generate creative, engaging Instagram captions from images. Built with Flutter and FastAPI, it features a complete authentication system, persistent data storage, and a beautiful conversation-style interface.

## ✨ Features

### 🎯 Core Functionality

- **🤖 AI-Powered Caption Generation**

  - Generates 3 unique, creative captions using Google Gemini AI
  - Multiple style options (aesthetic, funny, trendy, motivational)
  - Smart fallback system for API failures
  - Context-aware caption customization

- **🔄 Regenerate Without Loss** ⭐

  - Generate unlimited caption variations
  - Previous captions remain visible in conversation
  - All regenerations saved to database
  - Perfect for finding the ideal caption

- **💬 Conversation-Style Interface**
  - Beautiful chat-like UI
  - Distinct user and bot message styling
  - Image preview in conversations
  - Smooth scrolling and animations

### 🔐 Authentication & Security

- **User Management**
  - Secure registration and login
  - SHA-256 password hashing
  - Token-based authentication (30-day validity)
  - Session management with automatic expiry
  - Logout functionality

### 💾 Data Persistence

- **SQLite Database Integration**
  - Complete user profile storage
  - Conversation history tracking
  - Message persistence with timestamps
  - Saved captions management
  - Auto-creates database on first run

### 📱 User Interface

- **Beautiful Material Design 3**
  - Gradient themes and modern aesthetics
  - Smooth animations and transitions
  - Responsive design for all screen sizes
  - Loading states and empty state illustrations
  - Intuitive bottom navigation

### 📚 Additional Features

- **Conversation History**

  - View all past conversations
  - Timestamps with smart formatting
  - Tap to view full conversation details
  - See all caption variations

- **Saved Captions**

  - Bookmark favorite captions
  - Share to social media
  - Delete management
  - Quick access from dedicated tab

- **User Profile**
  - Display user information
  - Account management
  - About section
  - Logout option

---

## 🎬 Demo

### Key Highlights

1. **📝 Registration & Login**

   - Quick and secure user onboarding
   - Automatic session management

2. **📸 Upload & Generate**

   - Select image from gallery
   - AI generates 3 unique captions instantly

3. **🔄 Regenerate Magic**

   - Click regenerate for new variations
   - Old captions stay visible
   - Unlimited regenerations

4. **💾 Save & Share**

   - Bookmark favorite captions
   - Share directly to social media
   - Access saved captions anytime

5. **📚 History**
   - View all past conversations
   - See complete caption history
   - Track all regenerations

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                         │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   Login    │  │    Chat    │  │   Saved    │            │
│  │  Screen    │  │   Screen   │  │  Captions  │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│         │                │                │                  │
│         └────────────────┴────────────────┘                  │
│                          │                                   │
│                   ┌──────▼──────┐                           │
│                   │ API Service │                           │
│                   └──────┬──────┘                           │
└──────────────────────────┼──────────────────────────────────┘
                           │ HTTP/REST
                    ┌──────▼──────┐
                    │   FastAPI   │
                    │   Backend   │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
    │  SQLite   │   │   Auth    │   │  Gemini   │
    │ Database  │   │  System   │   │    AI     │
    └───────────┘   └───────────┘   └───────────┘
```

---

## 💻 Technology Stack

### Backend

| Technology                                                                                  | Version | Purpose               |
| ------------------------------------------------------------------------------------------- | ------- | --------------------- |
| ![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)     | 3.10+   | Core language         |
| ![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?logo=fastapi&logoColor=white) | 0.104+  | REST API framework    |
| ![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite&logoColor=white)         | 3       | Database              |
| ![Gemini](https://img.shields.io/badge/Google_Gemini-AI-4285F4?logo=google&logoColor=white) | Latest  | AI caption generation |
| ![Pillow](https://img.shields.io/badge/Pillow-10.1+-yellow)                                 | 10.1+   | Image processing      |
| ![Uvicorn](https://img.shields.io/badge/Uvicorn-0.24+-purple)                               | 0.24+   | ASGI server           |

### Frontend

| Technology                                                                                                     | Version | Purpose                  |
| -------------------------------------------------------------------------------------------------------------- | ------- | ------------------------ |
| ![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B?logo=flutter&logoColor=white)                      | 3.3+    | Cross-platform framework |
| ![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)                               | 3.0+    | Programming language     |
| ![Material Design](https://img.shields.io/badge/Material_Design-3-757575?logo=material-design&logoColor=white) | 3       | UI components            |
| ![Provider](https://img.shields.io/badge/Provider-6.1+-orange)                                                 | 6.1+    | State management         |

### Key Dependencies

- **google-generativeai**: AI caption generation
- **image_picker**: Image selection from gallery
- **share_plus**: Social media sharing
- **shared_preferences**: Local storage
- **http**: API communication
- **intl**: Date/time formatting

---

## 📥 Installation

### Prerequisites

Ensure you have the following installed:

- ✅ Python 3.10 or higher
- ✅ Flutter SDK 3.3 or higher
- ✅ Git
- ✅ Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

### Quick Setup (5 minutes)

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Vijay2k0517/caption-generator.git
cd caption-generator
```

#### 2️⃣ Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install Python dependencies
pip install -r requirements.txt

# Create .env file with your API key
echo "GEMINI_API_KEY=your_api_key_here" > .env

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

✅ Backend should now be running on `http://localhost:8000`

#### 3️⃣ Frontend Setup

Open a new terminal:

```bash
# Navigate to frontend directory
cd frontend

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run
```

Choose your target platform:

- **Chrome**: Web application
- **Android Emulator**: Mobile app
- **iOS Simulator**: iOS app (macOS only)

---

## 🚀 Usage

### For End Users

1. **First Time Setup**

   ```
   Open App → Splash Screen → Register Account → Login
   ```

2. **Generate Captions**

   ```
   Chat Tab → Upload Image → View 3 AI Captions
   ```

3. **Regenerate Captions**

   ```
   Click "Regenerate" → New Captions Appear → Old Captions Stay Visible
   ```

4. **Save Favorites**

   ```
   Click Bookmark Icon → Access via "Saved" Tab
   ```

5. **View History**
   ```
   Click History Icon → See All Conversations → Tap to View Details
   ```

### For Developers

#### Running Tests

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
flutter test
```

#### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📚 API Documentation

### Base URL

```
http://localhost:8000
```

### Authentication Endpoints

#### Register User

```http
POST /register
Content-Type: application/json

{
  "username": "string",
  "email": "string",
  "password": "string"
}

Response: 200 OK
{
  "message": "User registered successfully",
  "user_id": int,
  "username": "string",
  "token": "string"
}
```

#### Login

```http
POST /login
Content-Type: application/json

{
  "username": "string",
  "password": "string"
}

Response: 200 OK
{
  "message": "Login successful",
  "user_id": int,
  "username": "string",
  "email": "string",
  "token": "string"
}
```

#### Logout

```http
POST /logout
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Logout successful"
}
```

### Caption Generation

#### Generate Captions

```http
POST /generate-captions
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: (image file)

Response: 200 OK
{
  "captions": ["caption1", "caption2", "caption3"],
  "service": "gemini-free",
  "model": "Gemini Flash"
}
```

### Conversation Management

#### Create Conversation

```http
POST /conversations
Authorization: Bearer {token}

Response: 200 OK
{
  "conversation_id": int,
  "title": "New Conversation"
}
```

#### Get All Conversations

```http
GET /conversations
Authorization: Bearer {token}

Response: 200 OK
{
  "conversations": [
    {
      "id": int,
      "title": "string",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ]
}
```

#### Get Conversation Messages

```http
GET /conversations/{conversation_id}/messages
Authorization: Bearer {token}

Response: 200 OK
{
  "messages": [
    {
      "id": int,
      "role": "user|bot",
      "content": "string",
      "captions": ["string"],
      "created_at": "timestamp"
    }
  ]
}
```

### Saved Captions

#### Save Caption

```http
POST /saved-captions
Authorization: Bearer {token}
Content-Type: application/json

{
  "caption": "string"
}

Response: 200 OK
{
  "caption_id": int,
  "message": "Caption saved successfully"
}
```

#### Get Saved Captions

```http
GET /saved-captions
Authorization: Bearer {token}

Response: 200 OK
{
  "captions": [
    {
      "id": int,
      "caption": "string",
      "created_at": "timestamp"
    }
  ]
}
```

#### Delete Caption

```http
DELETE /saved-captions/{caption_id}
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Caption deleted successfully"
}
```

---

## 🗄️ Database Schema

## 🗄️ Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐
│     Users       │
├─────────────────┤
│ id (PK)         │
│ username        │──┐
│ email           │  │
│ password_hash   │  │
│ created_at      │  │
└─────────────────┘  │
                     │
       ┌─────────────┼─────────────┐
       │             │             │
       ▼             ▼             ▼
┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│  Sessions   │ │Conversations │ │SavedCaptions │
├─────────────┤ ├──────────────┤ ├──────────────┤
│ id (PK)     │ │ id (PK)      │ │ id (PK)      │
│ user_id(FK) │ │ user_id (FK) │ │ user_id (FK) │
│ token       │ │ title        │ │ caption      │
│ expires_at  │ │ created_at   │ │ created_at   │
│ created_at  │ │ updated_at   │ └──────────────┘
└─────────────┘ └──────────────┘
                       │
                       │
                       ▼
                ┌──────────────┐
                │   Messages   │
                ├──────────────┤
                │ id (PK)      │
                │ conv_id (FK) │
                │ role         │
                │ content      │
                │ captions     │
                │ created_at   │
                └──────────────┘
```

### Table Definitions

#### Users Table

| Column        | Type      | Constraints               | Description             |
| ------------- | --------- | ------------------------- | ----------------------- |
| id            | INTEGER   | PRIMARY KEY               | Unique user identifier  |
| username      | TEXT      | UNIQUE, NOT NULL          | User's username         |
| email         | TEXT      | UNIQUE, NOT NULL          | User's email address    |
| password_hash | TEXT      | NOT NULL                  | SHA-256 hashed password |
| created_at    | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time   |

#### Sessions Table

| Column     | Type      | Constraints               | Description           |
| ---------- | --------- | ------------------------- | --------------------- |
| id         | INTEGER   | PRIMARY KEY               | Session identifier    |
| user_id    | INTEGER   | FOREIGN KEY               | Reference to users.id |
| token      | TEXT      | UNIQUE, NOT NULL          | Authentication token  |
| expires_at | TIMESTAMP | NOT NULL                  | Token expiration time |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Session creation time |

#### Conversations Table

| Column     | Type      | Constraints               | Description             |
| ---------- | --------- | ------------------------- | ----------------------- |
| id         | INTEGER   | PRIMARY KEY               | Conversation identifier |
| user_id    | INTEGER   | FOREIGN KEY               | Reference to users.id   |
| title      | TEXT      | -                         | Conversation title      |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time           |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update time        |

#### Messages Table

| Column          | Type      | Constraints               | Description                   |
| --------------- | --------- | ------------------------- | ----------------------------- |
| id              | INTEGER   | PRIMARY KEY               | Message identifier            |
| conversation_id | INTEGER   | FOREIGN KEY               | Reference to conversations.id |
| role            | TEXT      | NOT NULL                  | 'user' or 'bot'               |
| content         | TEXT      | NOT NULL                  | Message text                  |
| captions        | TEXT      | -                         | JSON array of captions        |
| created_at      | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Message creation time         |

#### Saved Captions Table

| Column     | Type      | Constraints               | Description           |
| ---------- | --------- | ------------------------- | --------------------- |
| id         | INTEGER   | PRIMARY KEY               | Caption identifier    |
| user_id    | INTEGER   | FOREIGN KEY               | Reference to users.id |
| caption    | TEXT      | NOT NULL                  | Caption text          |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Save time             |

---

## 📸 Screenshots

### Mobile App Flow

<div align="center">

|                          Login Screen                           |                          Chat Screen                          |                         Saved Captions                          |
| :-------------------------------------------------------------: | :-----------------------------------------------------------: | :-------------------------------------------------------------: |
|                       User authentication                       |                     AI caption generation                     |                        Favorite captions                        |
| ![Login](https://via.placeholder.com/200x400?text=Login+Screen) | ![Chat](https://via.placeholder.com/200x400?text=Chat+Screen) | ![Saved](https://via.placeholder.com/200x400?text=Saved+Screen) |

|                     Conversation History                     |                           Profile                            |                         Regenerate Feature                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------------: |
|                       View past chats                        |                         User profile                         |                       Multiple caption sets                        |
| ![History](https://via.placeholder.com/200x400?text=History) | ![Profile](https://via.placeholder.com/200x400?text=Profile) | ![Regenerate](https://via.placeholder.com/200x400?text=Regenerate) |

</div>

---

## 📁 Project Structure

```
caption-generator/
├── backend/
│   ├── main.py                 # FastAPI application & endpoints
│   ├── database.py             # Database operations & models
│   ├── requirements.txt        # Python dependencies
│   ├── .env                    # Environment variables
│   ├── Procfile               # Deployment configuration
│   └── caption_maker.db       # SQLite database (auto-created)
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart          # App entry point
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   ├── conversation_history_screen.dart
│   │   │   ├── saved_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── home_screen.dart
│   │   ├── services/
│   │   │   ├── api.dart           # API communication
│   │   │   └── auth_service.dart  # Authentication
│   │   ├── providers/
│   │   │   └── app_state.dart     # State management
│   │   ├── widgets/
│   │   │   ├── gradient_button.dart
│   │   │   └── caption_sheet.dart
│   │   └── theme/
│   │       └── app_theme.dart     # App styling
│   ├── pubspec.yaml           # Flutter dependencies
│   ├── android/               # Android configuration
│   ├── ios/                   # iOS configuration
│   └── web/                   # Web configuration
│
├── README.md                  # This file
├── QUICK_START.md            # Quick setup guide
├── TESTING_GUIDE.md          # Testing instructions
└── IMPLEMENTATION_SUMMARY.md # Feature documentation
```

---

## 🔧 Troubleshooting

### Backend Issues

#### Issue: "Database not found"

**Solution:** The database is created automatically on first run. Ensure write permissions in the backend directory.

#### Issue: "Gemini API Error 429"

**Solution:**

- Check your API key in `.env`
- Verify API quota on [Google AI Studio](https://makersuite.google.com/)
- The app has a fallback system for API failures

#### Issue: "Port 8000 already in use"

**Solution:**

```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :8000
kill -9 <PID>
```

### Frontend Issues

#### Issue: "Cannot connect to backend"

**Solutions:**

- ✅ Verify backend is running on port 8000
- ✅ For Android emulator: Use `http://10.0.2.2:8000`
- ✅ For physical device: Update IP in `lib/services/api.dart`

```dart
// In api.dart, update:
return 'http://YOUR_PC_IP:8000'; // e.g., 'http://192.168.1.100:8000'
```

#### Issue: "Image picker not working"

**Solution:** Grant storage permissions in device settings

#### Issue: "Build errors"

**Solution:**

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

#### Issue: "Token expired"

**Solution:** Logout and login again (tokens are valid for 30 days)

---

## 🚀 Future Enhancements

### Planned Features

- [ ] **Image Storage**: Save uploaded images with captions
- [ ] **Edit Conversations**: Rename conversation titles
- [ ] **Delete Conversations**: Remove old conversations
- [ ] **Caption Categories**: Organize by style/mood
- [ ] **Search Functionality**: Find captions and conversations
- [ ] **Dark Mode**: Eye-friendly theme
- [ ] **Export Options**: PDF/Image with captions
- [ ] **Direct Sharing**: Post to Instagram/Twitter
- [ ] **Multi-language**: Support multiple languages
- [ ] **Caption Analytics**: Track popular captions
- [ ] **Custom Styles**: User-defined caption styles
- [ ] **Batch Processing**: Generate captions for multiple images
- [ ] **Voice Input**: Generate captions from voice descriptions
- [ ] **Hashtag Suggestions**: AI-generated hashtags

### Technical Improvements

- [ ] **Redis Caching**: Improve API performance
- [ ] **PostgreSQL**: Switch to production database
- [ ] **Docker**: Containerized deployment
- [ ] **CI/CD Pipeline**: Automated testing and deployment
- [ ] **API Rate Limiting**: Prevent abuse
- [ ] **WebSocket**: Real-time updates
- [ ] **PWA Support**: Progressive Web App
- [ ] **Offline Mode**: Local caption generation
- [ ] **Unit Tests**: Comprehensive test coverage
- [ ] **E2E Tests**: Automated UI testing

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### How to Contribute

1. **Fork the Repository**

   ```bash
   git clone https://github.com/Vijay2k0517/caption-generator.git
   ```

2. **Create a Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**

   - Write clean, documented code
   - Follow existing code style
   - Add tests if applicable

4. **Commit Changes**

   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push to GitHub**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Describe your changes
   - Reference any related issues
   - Wait for review

### Contribution Guidelines

- ✅ Follow PEP 8 for Python code
- ✅ Follow Dart style guide for Flutter
- ✅ Write meaningful commit messages
- ✅ Update documentation
- ✅ Add tests for new features
- ✅ Ensure all tests pass

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Report bugs and security issues responsibly

---

## 📄 License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2024 Vijaya Narayanan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📧 Contact

<div align="center">

### 👨‍💻 Developer: Vijaya Narayanan

[![Email](https://img.shields.io/badge/Email-vijaynarayanancool%40gmail.com-red?style=for-the-badge&logo=gmail&logoColor=white)](mailto:vijaynarayanancool@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Vijaya%20Narayanan-blue?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/vijaya-narayanan)
[![GitHub](https://img.shields.io/badge/GitHub-Vijay2k0517-black?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Vijay2k0517)

---

### 💬 Get in Touch

**Email:** [vijaynarayanancool@gmail.com](mailto:vijaynarayanancool@gmail.com)

**LinkedIn:** [www.linkedin.com/in/vijaya-narayanan](https://www.linkedin.com/in/vijaya-narayanan)

**GitHub:** [github.com/Vijay2k0517](https://github.com/Vijay2k0517)

---

### 🐛 Report Issues

Found a bug or have a feature request?

📝 [Create an Issue](https://github.com/Vijay2k0517/caption-generator/issues)

---

### ⭐ Show Your Support

If you find this project useful, please consider:

- ⭐ Starring the repository
- 🍴 Forking the project
- 📢 Sharing with others
- 💬 Providing feedback

---

<p align="center">
  <sub>Built with ❤️ using Flutter & FastAPI</sub>
</p>

<p align="center">
  <sub>© 2024 Vijaya Narayanan. All rights reserved.</sub>
</p>

</div>
