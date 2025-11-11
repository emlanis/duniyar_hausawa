import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int dailyProverbId = 1;
  static const int quizReminderId = 2;
  static const int streakReminderId = 3;

  // SharedPreferences keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _dailyProverbTimeKey = 'daily_proverb_time';
  static const String _quizReminderTimeKey = 'quiz_reminder_time';
  static const String _lastStreakDateKey = 'last_streak_date';

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Set local timezone (you can make this dynamic based on user location)
    final String timeZoneName = 'Africa/Lagos'; // West Africa Time
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Combined initialization settings
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to specific screen based on payload
    final String? payload = response.payload;

    if (payload != null) {
      // You can add navigation logic here based on payload
      // For example: navigate to proverb detail, quiz screen, etc.
      // print('Notification tapped with payload: $payload');
    }
  }

  // Handle iOS foreground notifications (older iOS versions)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // print('iOS notification received: $title');
  }

  // Request permissions (especially important for iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Android 13+ requires runtime permission
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS permissions
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true;
  }

  // Enable all notifications
  Future<void> enableNotifications() async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, true);

    // Schedule all default notifications
    await scheduleDailyProverb();
    await scheduleQuizReminder();
  }

  // Disable all notifications
  Future<void> disableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, false);

    // Cancel all notifications
    await _notifications.cancelAll();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  // Schedule daily proverb notification - gets NEW random proverb each day
  Future<void> scheduleDailyProverb({int hour = 9, int minute = 0}) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? false;

    if (!enabled) return;

    // Save preferred time
    await prefs.setInt(_dailyProverbTimeKey, hour * 60 + minute);

    // Cancel existing notification to avoid duplicates
    await _notifications.cancel(dailyProverbId);

    // Get a NEW random proverb each time
    final db = DatabaseService.instance;
    final proverbs = await db.getRandomProverbs(1);

    if (proverbs.isEmpty) return;
    final proverb = proverbs.first;

    // Schedule notification for today/tomorrow (NOT repeating - we'll reschedule daily)
    await _notifications.zonedSchedule(
      dailyProverbId,
      'Karin Maganarmu a Yau 📚',
      proverb.hausa,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_proverb',
          'Karin Magana ta Yau da Kullun',
          channelDescription: 'Daily Hausa proverb notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'daily_proverb:${proverb.id}',
    );
  }

  // Schedule quiz reminder notification - gets NEW random message each day
  Future<void> scheduleQuizReminder({int hour = 18, int minute = 0}) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? false;

    if (!enabled) return;

    // Save preferred time
    await prefs.setInt(_quizReminderTimeKey, hour * 60 + minute);

    // Cancel existing notification to avoid duplicates
    await _notifications.cancel(quizReminderId);

    // Attractive random quiz messages in corrected Hausa
    final messages = [
      'Gwada ƙwarewarku a yau! Ko kun iya samun 100%? 🎯',
      'Yane? Wane matsayi kuke ciki a gasar kacici-kacici? Ku gwada yanzu! 🏆',
      'Kacici-kacici yana jiran ku! A zo a baje-kolin ilimi 💪',
      'Lokacin koyo yayi! Gwada kacici-kacicin karin magana a yau 📚',
      'Nawa kuke ga zaku iya amsawa daidai? Ku shiga kacici-kacici yanzu! ✨',
      'Kun tuna da karin maganar da muka koya a yau? Ku zo mu gwada wasu! 🧠',
      'Kuna ƙoƙari sosai! Ku zo mu sake gwada kacici-kacici dan ƙwarewa sosai 🎓',
      'Gwanaye suna jiran ku! Ku shiga gasar kacici-kacici yanzu 🔥',
      'Wata sabuwar karin magana tana jiran ku! Ku bude app ɗin 🌟',
      'Ku gwada kacici-kacici kafin gari ya waye! 🌙',
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    await _notifications.zonedSchedule(
      quizReminderId,
      'Kacici-kacici 🧠',
      message,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'quiz_reminder',
          'Tunatarwa ta Kacici-kacici',
          channelDescription: 'Daily quiz reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quiz_reminder',
    );
  }

  // Send streak reminder if user hasn't opened app today
  Future<void> checkAndSendStreakReminder() async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? false;

    if (!enabled) return;

    final lastDate = prefs.getString(_lastStreakDateKey);
    final today = DateTime.now().toString().split(' ')[0];

    // If user hasn't opened app today, send reminder
    if (lastDate != today) {
      await _showStreakReminder();
    }
  }

  Future<void> _showStreakReminder() async {
    final messages = [
      'Kada ka yanke raga! 🔥 Bude app yau.',
      'Rage ka yana jira! Ka dawo yau.',
      'Kar ka daina koyo! 📖 Bude app.',
      'Ka tuna da mu? Mu ci gaba da koyo!',
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    await _notifications.show(
      streakReminderId,
      'Rage na Yau da Kullun 🔥',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          'Tunatarwa ta Rage',
          channelDescription: 'Daily streak reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'streak_reminder',
    );
  }

  // Mark today as visited (call this when app opens)
  Future<void> markTodayAsVisited() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    await prefs.setString(_lastStreakDateKey, today);
  }

  // Refresh daily notifications with new random content
  // Call this when app opens to ensure fresh notifications each day
  Future<void> refreshDailyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? false;

    if (!enabled) return;

    // Get saved notification times or use defaults
    final proverbTime = prefs.getInt(_dailyProverbTimeKey) ?? (9 * 60); // 9:00 AM
    final quizTime = prefs.getInt(_quizReminderTimeKey) ?? (18 * 60); // 6:00 PM

    final proverbHour = proverbTime ~/ 60;
    final proverbMinute = proverbTime % 60;
    final quizHour = quizTime ~/ 60;
    final quizMinute = quizTime % 60;

    // Reschedule both notifications with fresh random content
    await scheduleDailyProverb(hour: proverbHour, minute: proverbMinute);
    await scheduleQuizReminder(hour: quizHour, minute: quizMinute);
  }

  // Send immediate test notification
  Future<void> sendTestNotification() async {
    if (!_initialized) await initialize();

    await _notifications.show(
      999,
      'Gwaji! ✅',
      'Sanarwa tana aiki! Notifications are working perfectly!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Update daily proverb time
  Future<void> updateDailyProverbTime(int hour, int minute) async {
    await scheduleDailyProverb(hour: hour, minute: minute);
  }

  // Update quiz reminder time
  Future<void> updateQuizReminderTime(int hour, int minute) async {
    await scheduleQuizReminder(hour: hour, minute: minute);
  }

  // Get scheduled notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}