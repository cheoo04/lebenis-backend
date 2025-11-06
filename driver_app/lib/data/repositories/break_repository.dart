import 'dart:developer' as developer;
import '../../core/network/dio_client.dart';
import '../models/break_status_model.dart';
import '../../core/constants/api_constants.dart';

class BreakRepository {
  final DioClient dioClient;

  BreakRepository({required this.dioClient});

  /// Démarre une pause
  /// 
  /// Retourne les informations de la pause démarrée
  Future<BreakStatusModel> startBreak() async {
    try {
      final response = await dioClient.post(ApiConstants.startBreak);

      developer.log('📥 startBreak Response: ${response.statusCode}');
      
      // Backend retourne: { success: true, message: "...", break_started_at: "...", total_break_today: "..." }
      return BreakStatusModel.fromJson({
        'is_on_break': true,
        'break_started_at': response.data['break_started_at'],
        'total_break_today': response.data['total_break_today'],
      });
    } catch (e) {
      developer.log('❌ Erreur startBreak: $e');
      rethrow;
    }
  }

  /// Termine la pause en cours
  /// 
  /// Retourne la durée de la pause et le total du jour
  Future<Map<String, dynamic>> endBreak() async {
    try {
      final response = await dioClient.post(ApiConstants.endBreak);

      developer.log('📥 endBreak Response: ${response.statusCode}');
      
      // Backend retourne: { success: true, message: "...", break_duration: "...", total_break_today: "..." }
      return {
        'break_duration': response.data['break_duration'],
        'total_break_today': response.data['total_break_today'],
      };
    } catch (e) {
      developer.log('❌ Erreur endBreak: $e');
      rethrow;
    }
  }

  /// Récupère le statut actuel de pause
  /// 
  /// Retourne les informations complètes (en pause, durée, total du jour)
  Future<BreakStatusModel> getBreakStatus() async {
    try {
      final response = await dioClient.get(ApiConstants.breakStatus);

      developer.log('📥 getBreakStatus Response: ${response.statusCode}');
      return BreakStatusModel.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur getBreakStatus: $e');
      rethrow;
    }
  }
}
