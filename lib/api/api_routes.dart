// lib/api/api_routes.dart
class ApiRoutes {
  static const String services = '/api/services/active';
  static const String orders   = '/api/orders';
  static const String myOrders   = '/api/orders/my';
  static const String subs     = '/api/subscriptions';
  static const String notificationsCount = '/api/notifications';
  static const String profile            = '/api/auth/profile';
  static const cleanerOrders = '/api/orders/orders';
  static const cleanerRating  = '/api/cleaner/rating';

  static const cleanerOrder     = '/api/orders/orders';      // + {id}
  static const finishOrder      = '/api/orders/';      // + {id}/finish
  static const ratingCleaner    = '/api/rating/cleaner/';      // + {id}
  static const reviewsCleaner   = '/api/reviews/cleaner/';     // + {id}
  static const notificationsAll = '/api/notifications';
  static const userById = "/api/users";
  static const String gamificationStatus = '/api/users/gamification/status';
}
