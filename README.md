# English Tutor (ஆங்கில ஆசிரியர்) 🎓

A personal AI-powered English learning assistant designed specifically for Tamil speakers. This application helps users learn English through natural conversation, translation, and interactive practice.

## 🌟 Features

- **Billingual Interface**: tailored for Tamil speakers with a Tamil-first approach.
- **AI-Powered Tutoring**: Uses Google's Gemini AI to act as a patient, friendly English tutor.
- **Four Learning Modes**:
  - 🔄 **Translation (மொழிபெயர்ப்பு)**: Translate between Tamil and English with context.
  - 💡 **Explanation (விளக்கம்)**: Get detailed explanations of English sentence structures and meaning in Tamil.
  - ✏️ **Correction (திருத்தம்)**: Fix grammar mistakes in your English sentences with explanations.
  - 💬 **Practice (பயிற்சி)**: Have open-ended conversations in English to build confidence.
- **Voice Support**:
  - 🗣️ **Text-to-Speech**: Listen to proper English pronunciation and Tamil explanations.
  - 🎙️ **Speech-to-Text**: Practice speaking by using voice input for both Tamil and English.
- **Offline History**: Saves your chat history and vocabulary for review.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **AI Engine**: Google Gemini (via `google_generative_ai`)
- **State Management**: Provider
- **Local Storage**: Sqflite & Shared Preferences
- **Voice Services**: `flutter_tts` & `speech_to_text`

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- A Gemini API Key (optional for demo, required for full usage)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Adithya-Monish-Kumar-K/English-Tutor.git
   cd translator_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

1. On first launch, you will be greeted by the **Language Setup** screen.
2. (Optional) Enter your **Gemini API Key** to enable the AI features.
3. Choose a mode from the bottom menu:
   - Tap **Translate** to translate text.
   - Tap **Explain** to understand English phrases.
   - Tap **Correct** to fix your grammar.
   - Tap **Practice** to chat.
4. Use the **Microphone** button to speak instead of typing.
5. Tap the **Speaker** icon on any message to hear it read aloud.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
*Built with ❤️ for Tamil speakers learning English.*
