# SaveMe - Smart Savings Tracker

**Save smarter, one day at a time**

SaveMe is a Flutter-based mobile application designed to help users achieve their financial goals through intelligent daily savings tracking and progress monitoring.

## 📱 About The Project

SaveMe transforms the way you save money by breaking down large financial goals into manageable daily targets. The app calculates personalized saving recommendations based on your income, fixed expenses, and target goals, making it easier to stay on track without feeling overwhelmed.

### Key Features

- **Smart Tracking Mode**: Set up personalized saving plans with intelligent calculations
- **Daily Savings Calendar**: Interactive calendar view to track your daily saving progress
- **Missed Days Tracking**: Visual indicators for days you missed saving within your plan period
- **Fixed Expenses Management**: Track and manage recurring monthly expenses
- **Progress Monitoring**: Real-time updates on total saved amount and daily suggestions
- **Multiple Saving Plans**: Create and manage multiple saving goals simultaneously
- **Plan History**: View and access archived saving plans
- **Suggested Daily Savings**: Automatic calculation based on your financial situation

## 🎯 How It Works

1. **Create a Saving Goal**: Enter your goal name and target amount
2. **Input Financial Details**: Add your monthly income and fixed expenses
3. **Get Smart Recommendations**: The app calculates your optimal daily saving amount
4. **Track Daily Progress**: Mark each day you save money on the calendar
5. **Monitor Your Journey**: View total saved, missed days, and progress towards your goal

## 🏗️ Architecture

SaveMe follows clean architecture principles with clear separation of concerns:

```
lib/
├── data/              # Data layer - JSON storage and data management
├── domain/            # Business logic and models
│   ├── logic/        # Calculation algorithms
│   └── model/        # Domain entities
├── ui/               # Presentation layer
│   ├── screens/      # App screens
│   └── widgets/      # Reusable UI components
└── utils/            # Utility classes and constants
```

## 🛠️ Built With

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Table Calendar** - Interactive calendar widget
- **Device Preview** - Testing across different screen sizes
- **Path Provider** - File system access
- **Intl** - Internationalization and date formatting

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.6.1)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone https://github.com/taingchhay/SaveMe-projectApp
cd SaveMe-projectApp
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run -d windows  # For Windows
flutter run -d android  # For Android
flutter run -d ios      # For iOS
```

## 📊 Key Features Breakdown

### Smart Calculation Engine
- Analyzes monthly income and fixed expenses
- Calculates realistic daily savings targets
- Adjusts recommendations based on estimated daily spending
- Determines optimal plan duration to reach your goal

### Visual Progress Tracking
- ✅ Green check marks for days you saved
- ❌ Red cross marks for missed days (only within plan period)
- Clear visual distinction between active and inactive days
- Real-time progress updates

### Flexible Plan Management
- Create multiple saving goals
- Archive completed plans
- View historical saving patterns
- Edit existing daily records

## 🎨 Design Principles

- **User-Centric**: Simple, intuitive interface
- **Visual Feedback**: Color-coded indicators and progress cards
- **Responsive Design**: Adapts to different screen sizes
- **Material Design**: Follows Flutter's Material Design guidelines

## 📱 Supported Platforms

- ✅ Windows Desktop
- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS

## 📂 Project Structure

- **Data Persistence**: JSON-based local storage
- **State Management**: StatefulWidget with setState
- **Navigation**: MaterialPageRoute
- **Form Validation**: Built-in Flutter form validators

## 🔄 App Flow

```
Welcome Screen → Smart Tracking Mode → Form Input → Plan Creation → 
Daily Tracking Calendar → Progress Monitoring → Goal Achievement
```

## 📈 Future Enhancements

- Cloud synchronization
- Data export/import
- Advanced statistics and analytics
- Budget recommendations
- Notifications and reminders

## 👥 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## 📄 License

This project is part of a university course project.

## 📊 Project Presentation

For a detailed overview of the SaveMe project, including features, architecture, and development process, please view our presentation:

**[SaveMe Project Presentation](https://www.canva.com/design/DAG9kM_hO80/0rE-4FVVVfAZbqi71PbdXA/edit?utm_content=DAG9kM_hO80&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)**

---

*Built with ❤️ using Flutter*
