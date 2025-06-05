// lib/api/api_routes.dart
class ApiRoutes {
  static const String services = '/api/services/active';
  static const String orders   = '/api/orders';
  static const String subs     = '/api/subscriptions';
  static const String notificationsCount = '/api/notifications';
  static const String profile            = '/api/auth/profile';
  static const cleanerOrders = '/api/orders/my';
  static const cleanerRating  = '/api/cleaner/rating';

  static const cleanerOrder     = '/api/cleaner/orders/';      // + {id}
  static const finishOrder      = '/api/cleaner/orders/';      // + {id}/finish
  static const ratingCleaner    = '/api/rating/cleaner/';      // + {id}
  static const reviewsCleaner   = '/api/reviews/cleaner/';     // + {id}
  static const notificationsAll = '/api/notifications';
}
