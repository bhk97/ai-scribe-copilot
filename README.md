# 🩺 Medinotes – AI Scribe Copilot

A cross-platform **Flutter application** for **robust audio recording, real-time transcription, and resilient audio streaming**, built to handle real-world interruptions without losing data.

This app is designed for scenarios where **audio must never be lost**.

---

## 📖 Overview

**Medinotes AI Scribe Copilot** records audio and streams it to the backend **in small chunks instead of a single upload**.  
This allows the app to safely recover from interruptions such as phone calls, network failures, or app termination.

The recording state is persisted locally and automatically restored when the app resumes.

---

## 🚀 Key Highlights

- 🎙️ Chunk-based audio recording & streaming
- 🔄 Real-time audio upload to backend
- 📡 Live transcription support
- ⏸️ Pause & resume recording
- 📞 Phone call & system interruption handling
- 🌐 Network disconnection recovery
- 🔁 App kill / crash recovery
- 💾 Persistent session restoration

---

## 🎯 Why Chunked Streaming?

Instead of sending audio only after recording finishes, this app:

- Records audio in **small chunks**
- Streams each chunk immediately
- Stores metadata and progress locally

So even if:
- A phone call interrupts recording
- Internet connection drops
- The app is backgrounded or killed

👉 Recording continues seamlessly once the app resumes, **without losing audio**.

---

Demonstrates:
- Live audio recording
- Chunk streaming
- Phone call interruption
- Automatic resume & recovery

---

## 🌍 Backend

### Live API
http://medinotes-backend.onrender.com/test


### Backend Source Code & Docker Setup
Backend is maintained in a separate repository:
**medinotes-backend**

---

## 🛠️ Setup Instructions

### Clone Repository

git clone https://github.com/bhk97/ai-scribe-copilot
cd ai-scribe-copilot


🛠️ Setup Instructions
Clone and build
```bash
git clone https://github.com/bhk97/ai-scribe-copilot
```
```bash
cd ai-scribe-copilot
```
```bash
flutter pub get
```

Build APK

```bash
flutter build apk --release
```

Build iOS (simulator)

```bash
flutter build ios --simulator
```


