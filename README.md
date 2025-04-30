# Usave

## Personal Financial Management Mobile Application

Usave is a personal financial management mobile application designed to help users track their daily income, expenses, and savings. Users can set savings goals and monitor their progress over time. One of the standout features of Usave is its integration with the Google Gemini API, which provides personalized financial insights and daily notifications based on user transaction data. These AI-generated recommendations help users improve their financial management skills day by day.

Usave is built using **Flutter** with the **Dart** programming language. It utilizes **SQLite** for local data storage, ensuring maximum security for personal financial data as all information is stored directly on the user’s device. Unlike cloud-based financial apps, Usave operates entirely offline, reducing the risk of data breaches and unauthorized access. By storing financial data locally, users maintain full control over their sensitive information without the need for an internet connection. This makes Usave an ideal choice for individuals who prioritize privacy and data security while managing their finances efficiently.

---

## Features & Screens

Usave features a **bottom navigation bar** with three primary sections: **Home, Chatbot, and Settings.**

### Home Screen
The home screen is designed with a clean and user-friendly UI. At the top, it displays the Usave logo and a notification icon, allowing users to read AI-generated financial notifications. Below that, the app greets users based on the time of day (e.g., "Good morning").

#### Main Menu:
- **Data Category:** View and organize transactions based on predefined or custom categories to analyze spending habits and track financial patterns.
- **Data Table:** A structured table displaying all transaction records (income, expenses, and savings) with sorting and filtering options. Users can also export all transaction data as a **CSV file**.
- **Report:** A visual dashboard summarizing all financial data, including spending insights, income, and savings amount.
- **Saving Goal:** Set, monitor, and update savings goals. The app tracks progress and provides reminders and insights.
- **Transaction History:** A detailed log of all monthly transactions, including date, category, and amount to help track cash flow and identify saving opportunities.

At the bottom, users can see a **recent transactions** section displaying income, expenses, and savings with corresponding amounts and dates.

### Chatbot Screen
The chatbot screen enables users to interact with AI for financial guidance using the **Google Gemini API**. It offers three main tools:
1. **Saving Plan:** Users enter their monthly income and expenses, and the AI provides financial planning suggestions.
2. **Income Planner:** Generates insights to optimize income management.
3. **Expense Tracker:** Helps users analyze and control their spending.

Additionally, users can select their **preferred language** for AI responses.

### Settings Screen
The settings screen allows users to customize various aspects of the app. It includes:

- **User Profile:** Users can update their name via an edit button below the app logo.
- **Categories:** Manage transaction categories. Default categories include:
  - **Income:** Interest, Sales, Bonus, Salary.
  - **Expense:** Food & Drinks, Gifts & Donations, Transportation.
  - **Savings:** Emergency Fund, Investment.
  - Users can also add or customize categories.
- **Currency:** Set a custom currency. The default is **USD ($)**, but users can select their preferred currency.
- **Trash Bin:** Stores deleted transactions, allowing users to restore or permanently delete them.
- **Appearance Settings:**
  - Language selection (**English, Thai, Khmer**).
  - Theme mode (**Light/Dark mode**).
  - Local daily notifications for transactions and reminders.
- **Reset Data:** Resets all app data to its initial state.
- **About Developer:** Displays developer profile and contact information.
- **Open Source Licenses:** Lists all open-source libraries used in the app.

## Technologies Used
- **Framework:** Flutter
- **Language:** Dart
- **Database:** SQLite
- **AI API:** Google Gemini API

---

## Security & Privacy
- **Offline-First:** All data is stored locally, ensuring privacy.
- **No Cloud Storage:** Eliminates risk of data leaks or unauthorized access.
- **User Control:** Users have full control over their financial data.


