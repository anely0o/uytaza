// lib/api/api_routes.dart
class ApiRoutes {
  // ───────── общие ─────────────────────────────────────────────
  static const String services            = '/api/services/active';
  static const String orders              = '/api/orders';
  static const String myOrders            = '/api/orders/my';
  static const String subs                = '/api/subscriptions';
  static const String notificationsCount  = '/api/notifications';
  static const String notificationsAll    = '/api/notifications';
  static const String profile             = '/api/auth/profile';
  static const String userById            = '/api/users';
  static const String gamificationStatus  = '/api/users/gamification/status';

  // ───────── cleaner-flow ──────────────────────────────────────
  static const String cleanerOrders   = '/api/orders/orders';
  static const String cleanerOrder    = '/api/orders/orders';          // + /{id}
  static const String confirmOrder     = '/api/orders';                 // + /{id}/confirm
  static const String ratingCleaner   = '/api/rating/cleaner';         // + /{id}
  static const String reviewsCleaner  = '/api/reviews/cleaner';        // + /{id}

  // ───────── media ─────────────────────────────────────────────
  static const String mediaByOrder = '/api/media/order';               // GET  /api/media/order/{orderId}
  static const String mediaReport    = '/api/media/report';         // POST /api/media/report/{orderId}
  static const String rating = '/api/rating';

  static const String avatarUpload   = '/api/media/avatar';         // POST /api/media/avatar
  static const String mediaReports   = '/api/media/reports';        // GET  /api/media/reports/{orderId}
  // --- profile & auth ---
  static const String profileUpdate  = '/api/auth/profile';     // PUT
  static const String passwordChange = '/api/auth/password/change'; // PUT {old,new}
  static const String passwordReset  = '/api/auth/password/reset';  // POST {email}
  static const String getAvatars   = '/api/media/avatars';

}
