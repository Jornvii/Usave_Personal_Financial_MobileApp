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
    // ****************************************************************************************************************************************************************
    // ****************************************************************************************************************************************************************
    // ****************************************************************************************************************************************************************
    'English': {
      //Main Screen
      'home': 'Home',
      'chatbot': 'Chat bot',
      //Home Screen
      'MonthlyTransactions': 'Monthly Transactions',
      'PleaseSetASavingGoalForTransactionsNotifications':
          'Please set a saving goal for transactions notifications',
      'GotoSetSavingGoalsNow': 'Set a Saving Goal',
      "Cancel": 'Cancel',
      //MyHomePage
      "SetASavingGoal": "Set a Saving Goal",
      // sub home screen
      'GoodMorning': 'Good Morning',
      'GoodAfternoon': 'Good Afternoon',
      'GoodEvening': 'Good Evening',
      'Tapheretosetyourname': 'Tap here to set your name',
      'Menu': 'Menu',
      'DataCategory': "Data Category",
      'DataTable': 'Data Table',
      'Dashboard': 'Dashboard',
      'SavingGoal': 'Saving Goal',
      'Calculate': 'Calculate',
      'recent_transactions': 'Recent Transactions',
      'Notransactionsavailable': 'No transactions available',

// ListSummaryScreen
      'All': 'All',

// SavingGoalScreen
      'EmergencyFund': 'Emergency Fund',
      'CannotDelete': 'Cannot delete',
      'Areyousureyouwanttodeletethesavinggoalcategory?':
          'Are you sure you want to delete the saving goal category?',
      'ConfirmDeletion': 'Confirm Deletion',

      //Add Transaction Screen
      'add_transaction': 'Add Transaction',
      'Amount': 'Amount',
      'Enteramount': 'Enter amount',
      'Amountisrequired': 'Amount is required',
      'Enteravalidnumber': 'Enter a valid number',
      'Category': 'Category',
      'SelectCategory': 'Select Category',
      'Categoryisrequired': 'Category is required',
      'DateofTransaction': 'Date of Transaction',
      'Selectadate': 'Select a date',
      'Dateisrequired': 'Date is required',
      'Description': 'Description',
      'Enteranynotesordetails(optional)':
          'Enter any notes or details (optional)',
      "Submit": "Submit",
      "Transactions": "Transactions",

      // ReportScreen
      'FinancialReport': 'Summary Report',
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
      'default_username': ' User Name',
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

      'delete_all': 'Delete Data',
      'choose_delete_option': 'Please choose to delete',

      'delete_data': 'Delete data',
      'delete_data_subtitle': 'Delete your chat or all data',
      'reset_forever_warning' : 'Your Transaction data cannot be recycle. Are you sure you want to reset all data?',
      'confirm_delete': 'Confirm Delete',
      'edit_saving_goal': 'Edit Saving Goal',
      'delete_chat': 'Delete Chat Data',
      'about_us': "About Us",
      'version_app': 'version 1.0.1'
    },
    // ****************************************************************************************************************************************************************
    // ****************************************************************************************************************************************************************
    // ****************************************************************************************************************************************************************
    // ****************************************************************************************************************************************************************

    'Thai': {
      //Main Screen
      'home': 'หน้าหลัก',
      'chatbot': 'Chat bot',
      //Home Screen
      'MonthlyTransactions': 'รายการรายเดือน',
      //MyHomePage
      "SetASavingGoal": "ตั้งเป้าหมายการออม",
      'PleaseSetASavingGoalForTransactionsNotifications':
          'โปรดตั้งเป้าหมายการออมสำหรับการแจ้งเตือนรายการ',
      'GotoSetSavingGoalsNow': 'ตั้งเป้าหมายการออม',
      "Cancel": 'ยกเลิก',
      // sub home screen
      'GoodMorning': 'อรุณสวัสดิ์',
      'GoodAfternoon': 'สวัสดีตอนบ่าย',
      'GoodEvening': 'สวัสดีตอนเย็น',
      'Tapheretosetyourname': 'กดที่นี่เพื่อตั้งชื่อของคุณ',
      'Menu': 'เมนู',
      'DataCategory': "หมวดหมู่ข้อมูล",
      'DataTable': 'ตารางข้อมูล',
      'Dashboard': 'แดชบอร์ด',
      'SavingGoal': 'เป้าหมายการออม',
      'Calculate': 'คำนวณ',
      'recent_transactions': 'รายการ',
      'Notransactionsavailable': 'ไม่มีรายการ',

// ListSummaryScreen
      'All': 'ทั้งหมด',

// SavingGoalScreen
      'EmergencyFund': 'กองทุนฉุกเฉิน',
      'CannotDelete': 'ไม่สามารถลบ',
      'Areyousureyouwanttodeletethesavinggoalcategory?':
          "ลบหมวดหมู่เป้าหมายการออมนี้?",
      'ConfirmDeletion': 'ยืนยันการลบ',
      'Delete': 'ลบ',

      //Add Transaction Screen
      'add_transaction': 'เพิ่มรายการ',
      'Amount': 'จำนวนเงิน',
      'Enteramount': 'กรุณากรอกจำนวนเงิน',
      'Amountisrequired': 'กรุณากรอกจำนวนเงิน',
      'Enteravalidnumber': 'กรุณากรอกตัวเลขที่ถูกต้อง',
      'Category': 'ประเภท',
      'SelectCategory': 'เลือกประเภท',
      'Categoryisrequired': 'กรุณาเลือกประเภท',
      'DateofTransaction': 'วันที่ทำรายการ',
      'Selectadate': 'เลือกวันที่',
      'Dateisrequired': 'กรุณาเลือกวันที่',
      'Description': 'รายละเอียด',
      'Enteranynotesordetails(optional)': 'กรอกรายละเอียดเพิ่มเติม',
      "Submit": "เพิ่มข้อมูล",
      "Transactions": "รายการ",

      // ReportScreen
      'FinancialReport': 'รายสรุปการเงิน',
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
      'default_username': 'ชื่อผู้ใช้',
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
      'reset_forever_warning' : 'ข้อมูลทั้งหมดของคุณไม่สามารถคืนกลับได้ คุณแน่ใจว่าต้องการรีเซ็ตข้อมูลทั้งหมดหรือไหม?',
       'confirm_delete': 'ยืนยันการลบ',

      'delete_chat': 'ลบข้อมูล bot',
      'about_us': "เกี่ยวกับเรา",
      'version_app': 'เวอร์ชัน 1.0.1'
    },

    // ************************************************************************************************************************************************************************************************************
    // ************************************************************************************************************************************************************************************************************
    // ************************************************************************************************************************************************************************************************************
    // ************************************************************************************************************************************************************************************************************
    // ************************************************************************************************************************************************************************************************************
    'Khmer': {
      //Main Screen
      'home': 'ទំព័រដើម',
      'chatbot': 'Chat bot',
      //Home Screen
      'MonthlyTransactions': 'ប្រតិបត្តិការប្រចាំខែ',
      //MyHomePage
      "SetASavingGoal": "កំណត់គោលដៅសន្សំ",
      'PleaseSetASavingGoalForTransactionsNotifications':
          'សូមកំណត់គោលដៅសន្សំសម្រាប់ការជូនដំណឹងប្រតិបត្តិការ',
      'GotoSetSavingGoalsNow': 'កំណត់គោលដៅសន្សំ',
      "Cancel": 'បោះបង់',

      // sub home screen
      'GoodMorning': 'អរុណសួស្តី',
      'GoodAfternoon': 'ទិវាសួស្តី',
      'GoodEvening': 'សាយណ្ហសួស្តី',
      'Tapheretosetyourname': 'ចុចទីនេះដើម្បីកំណត់ឈ្មោះអ្នក',
      'Menu': 'ម៉ឺនុយ',
      'DataCategory': "ប្រភេទទិន្នន័យ",
      'DataTable': 'តារាងទិន្នន័យ',
      'Dashboard': 'ទិន្នន័យ',
      'SavingGoal': 'គោលដៅសន្សំ',
      'Calculate': 'គណនា',
      'recent_transactions': 'ប្រតិបត្តិការថ្មី',
      'Notransactionsavailable': 'មិនមានប្រតិបត្តិការ',

// ListSummaryScreen
      'All': 'ទាំងអស់',

// SavingGoalScreen
      'EmergencyFund': 'កម្ចីបន្ទាន់',
      'CannotDelete': 'មិនអាចលុប',
      'Areyousureyouwanttodeletethesavinggoalcategory?':
          'តើអ្នកប្រើចង់លុបប្រភេទគោលដៅសន្សំនេះមែនទេ?',

      //Add Transaction Screen
      'add_transaction': 'បញ្ចូលប្រតិបត្តិការ',
      'Enteramount': 'បញ្ចូលចំនួនទឹកប្រាក់',
      'Amountisrequired': 'សូមបញ្ចូលចំនួនទឹកប្រាក់',
      'Enteravalidnumber': 'សូមបញ្ចូលលេខត្រឹមត្រូវ',
      'Category': 'ប្រភេទ',
      'SelectCategory': 'ជ្រើសរើសប្រភេទ',
      'Categoryisrequired': 'សូមជ្រើសរើសប្រភេទ',
      'DateofTransaction': 'កាលបរិច្ឆេទ',
      'Selectadate': 'ជ្រើសរើសកាលបរិច្ឆេទ',
      'Dateisrequired': 'សូមជ្រើសរើសកាលបរិច្ឆេទ',
      'Description': 'កំណត់ចំណាំបន្ថែម ',
      'Enteranynotesordetails(optional)': 'បញ្ចូលកំណត់ចំណាំ ឬ ព័ត៌មានបន្ថែម ',
      "Submit": "បញ្ជូន",
      "Transactions": 'ប្រតិបត្តិការ',

      'Amount': 'ចំនួនទឹកប្រាក់',
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
      'theme': 'ធីមកម្មវិធី',
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
      'version_app': 'កំណែ 1.0.0',
      'reset_forever_warning' : 'ទិន្នន័យរបស់អ្នកមិនអាចយកត្រឡប់មកវិគវិញបានទេ តើអ្នកចង់លុបឡើងទិន្នន័យទាំងអស់របស់អ្នកមែនទេ?',
      'confirm_delete': 'បញ្ជាក់លុប',
    },
  };
}
