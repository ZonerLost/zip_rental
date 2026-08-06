import 'package:zip_peer/models/profile/dashboard_models.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class DashboardResult {
  const DashboardResult({required this.success, required this.message, this.stats});

  final bool success;
  final String message;
  final DashboardStats? stats;
}

class DashboardService extends ApiServiceBase {
  DashboardService({super.authService});

  /// 10.1 — GET /dashboard (auth required). Aggregated stats for the
  /// current user — no params.
  Future<DashboardResult> getDashboard() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/dashboard',
      requiresAuth: true,
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);
    if (!ok) return DashboardResult(success: false, message: msg);

    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    final statsMap = data is Map ? stringKeyMap(data) : root;

    return DashboardResult(
      success: true,
      message: msg,
      stats: DashboardStats.fromJson(statsMap),
    );
  }
}
