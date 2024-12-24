import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'English'; // Default language

  String get selectedLanguage => _selectedLanguage;

  // Load the language from SharedPreferences when the app starts
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('selectedLanguage') ??
        'English'; // Default to 'English'
    notifyListeners();
  }

  // Set a new language and save it to SharedPreferences
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLanguage', language); // Save the selected language
    notifyListeners();
  }

  // Get translations for the current language
  String translate(String key) {
    final translations = _translations[_selectedLanguage] ?? {};
    return translations[key] ??
        key; // Return the key if no translation is found
  }

  // Translations for different languages
  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // ReportScreen
      'FinancialReport': 'Financial Report',
      'report': 'Report',
      'Income': 'Income',
      'Expense': 'Expense',
      'Saving': 'Saving',
      'balance': 'Balance',
      'income_vs_expense': 'Income vs Expense',
      'donut_chart': 'Doughnut Chart',
      'line_chart': 'Line Chart',
      'data_exported': 'Data exported to',

      // bot screen
      'chat_bot_title': 'AI Chat Bot',
      'start_chat': 'Start Chat',
      'submit': 'Submit',
      'savings_plan': 'Savings Plan',
      'income_planner': 'Income Planner',
      'expense_tracker': 'Expense Tracker',
      'monthly_income': 'Monthly Income',
      'monthly_expenses': 'Monthly Expenses',
      'savings_goal': 'Savings Goal',
      'target_income': 'Target Income',
      'current_income': 'Current Income',
      'fixed_expenses': 'Fixed Expenses',
      'variable_expenses': 'Variable Expenses',
      // settings screen
      'settings': 'Settings',
      'edit_user_name': 'Edit User Name',
      'category': 'Category',
      'cancel': 'Cancel',
      'save': 'Save',
      'profile_updated': 'Profile updated successfully!',
      'name': 'Name',
      'currency': 'Currency',
      'savingGoal': 'Saving Goal',
      'datatotal': 'Total Data',
      'dataTable': 'Data Table',
      'Trashbin': 'Trashbin',
      'appearance': 'Appearance',
      'AboutMe': 'About Me',
      'OpenSource': 'Open Source',

      'language': 'Language',
      'select_language': 'Select Language',
      'saving_goal': 'Saving Goal',
      'not_set': 'Not set',
      'your_saving_goal': 'Your saving goal:',
      'theme': 'Theme',
      'dark': 'Dark',
      'light': 'Light',

      'delete_all': 'Delete Your Data',
      'choose_delete_option': 'Please choose to delete',

      'delete_data': 'Delete your data',
      'delete_data_subtitle': 'Delete your chat or all data',
      'edit_saving_goal': 'Edit Saving Goal',
      'delete_chat': 'Delete Chat Data',
      'about_us': "About Us",
      'version_app': 'version 1.0.1'
    },
    'Thai': {
      // ReportScreen
      'FinancialReport': 'รายงานการเงิน',
      'report': 'รายงาน',
      'Income': 'รายรับ',
      'Expense': 'รายจ่าย',
      'Saving': 'เงินออม',
      'balance': 'ยอดคงเหลือ',
      'income_vs_expense': 'รายรับเทียบกับรายจ่าย',
      'donut_chart': 'กราฟโดนัท',
      'line_chart': 'กราฟเส้น',
      'data_exported': 'ข้อมูลถูกส่งออกไปยัง',

      // bot screen
      'chat_bot_title': 'บอท AI',
      'start_chat': 'เริ่ม',
      'submit': 'ส่ง',
      'cancel': 'ยกเลิก',
      'language': 'ภาษา',
      'savings_plan': 'แผนการออม',
      'income_planner': 'แผนการรายได้',
      'expense_tracker': 'ตัวติดตามค่าใช้จ่าย',
      'monthly_income': 'รายได้รายเดือน',
      'monthly_expenses': 'ค่าใช้จ่ายรายเดือน',
      'savings_goal': 'เป้าหมายการออม',
      'target_income': 'รายได้เป้าหมาย',
      'current_income': 'รายได้ปัจจุบัน',
      'fixed_expenses': 'ค่าใช้จ่ายคงที่',
      'variable_expenses': 'ค่าใช้จ่ายผันแปร',
      // settings screen
      'settings': 'การตั้งค่า',
      'category': 'ประเภท',
      'username': 'ชื่อผู้ใช้',
      'save': 'บันทึก',
      'profile_updated': 'โปรไฟล์ได้รับการอัปเดตเรียบร้อยแล้ว!',
      'name': 'ชื่อ',
      'edit_user_name': 'แก้ไขชื่อผู้ใช้',
      'currency': 'สกุลเงิน',
      'savingGoal': 'การออม',
      'datatotal': 'ข้อมูลทั้งหมด',
      'dataTable': 'ตารางข้อมูล',
      'Trashbin': 'ถังขยะ',
      'appearance': 'การกำหนด',
      'AboutMe': 'ผู้พัฒนา',
      'OpenSource': 'Open Source',

      'select_language': 'เลือกภาษา',
      'saving_goal': 'เป้าหมายการออม',
      'not_set': 'ไม่ได้ตั้งค่า',
      'your_saving_goal': 'เป้าหมายการออมของคุณ:',
      'theme': 'ธีม',
      'dark': 'มืด',
      'light': 'สว่าง',
      'delete_data': 'ลบข้อมูล',

      'delete_all': 'ลบข้อมูล',
      'choose_delete_option': 'กรุณาเลือกลบ',
      'delete_data_subtitle': 'ลบการหรือข้อมูลทั้งหมด',
      'edit_saving_goal': 'แก้ไขเป้าหมายการออม',

      'delete_chat': 'ลบข้อมูล bot',
      'about_us': "เกี่ยวกับเรา",
      'version_app': 'เวอร์ชัน 1.0.1'
    },
    'Khmer': {
      // ReportScreen
      'FinancialReport': 'របាយការណ៍ហិរញ្ញវត្ថុ',
      'report': 'របាយការណ៍',
      'Income': 'ចំណូល',
      'Expense': 'ចំណាយ',
      'Saving': 'សន្សំ',
      'balance': 'សមតុល្យ',
      'income_vs_expense': 'ចំណូលប្រកួតប្រជែងចំណាយ',
      'donut_chart': 'គំនូសតួអង្កាំ',
      'line_chart': 'គំនូសបន្ទាត់',
      'data_exported': 'ទិន្នន័យត្រូវបាននាំចេញទៅ',

      // bot screen
      'chat_bot_title': 'បូត AI',
      'start_chat': 'ចាប់ផ្ដើម',
      'submit': 'បញ្ជូន',
      'cancel': 'បោះបង់',
      'language': 'ភាសា',
      'savings_plan': 'ផែនការសន្សំ',
      'income_planner': 'ផែនការចំណូល',
      'expense_tracker': 'ផែនការចំណាយ',
      'monthly_income': 'ចំណូលប្រចាំខែ',
      'monthly_expenses': 'ចំណាយប្រចាំខែ',
      'savings_goal': 'គោលដៅសន្សំ',
      'target_income': 'ចំណូលគោលដៅ',
      'current_income': 'ចំណូលបច្ចុប្បន្ន',
      'fixed_expenses': 'ចំណាយថេរ',
      'variable_expenses': 'ចំណាយអវត្ដមាន',
      // settings screen
      'settings': 'ការកំណត់',
      'edit_user_name': 'កែប្រែឈ្មោះអ្នកប្រើ',
      'currency': 'រូបិយប័ណ្ណ',
      'savingGoal': 'គោលដៅសន្សំ',
      'dataTable': 'តារាងទិន្នន័យ',
      'Trashbin': 'ធុងសំរាម',
      'appearance': 'កាកាំណត់',
      'AboutMe': 'អំពីខ្ញុំ',
      'OpenSource': 'Open Source',
      'datatotal': 'ទិន្នន័យសរុប',

      'category': 'ប្រភេទ',
      'save': 'រក្សាទុក',
      'profile_updated': 'ប្រវត្តិរូបបានធ្វើបច្ចុប្បន្នភាពជោគជ័យ!',
      'name': 'ឈ្មោះ',
      'default_username': 'ឈ្មោះអ្នកប្រើ',
      'select_language': 'ជ្រើសរើសភាសា',
      'saving_goal': 'គោលដៅសន្សំ',
      'not_set': 'មិនបានកំណត់',
      'your_saving_goal': 'គោលដៅសន្សំរបស់អ្នក:',
      'theme': 'ស្ប៉ាត',
      'dark': 'ងងឹត',
      'light': 'ភ្លឺ',
      'export_data': 'នាំចេញទិន្នន័យ',
      'export_data_subtitle': 'នាំចេញទិន្នន័យទៅ Excel',

      'delete_all': 'លុបទិន្នន័យ',
      'delete_data': 'លុបទិន្នន័យ',
      'delete_data_subtitle': 'លុបទិន្នន័យ',
      'edit_saving_goal': 'កែសម្រួលគោលដៅសន្សំ',
      'delete_chat': 'លុបទិន្នន័យសារ',
      'about_us': "អំពី អ្នកបង្កើតកម្មវិធី",
      'version_app': 'កំណែ 1.0.1'
    },
  };
}
