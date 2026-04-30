import 'package:dio/dio.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> verifyDiploma({
    required String diplomaId,
    String? lastName,
  }) async {
    print("Tentative de vérification pour l'ID: $diplomaId");
    try {
      final response = await _dio.post(
        "/api/diplomas/verify/scan/",
        data: {
          "diploma_id": diplomaId,
          if (lastName != null && lastName.isNotEmpty)
            "student_last_name": lastName,
        },
      );
      print("Appel réussi !");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print("ÉCHEC de l'appel API.");
      if (e.type == DioExceptionType.connectionTimeout) {
        print("ERREUR: Timeout de connexion (le serveur ne répond pas).");
      } else if (e.type == DioExceptionType.connectionError) {
        print("ERREUR: Impossible de joindre l'adresse 192.168.1.69. Vérifiez que votre téléphone et votre PC sont sur le même Wi-Fi.");
      }
      
      if (e.response?.data != null) {
        return e.response!.data as Map<String, dynamic>;
      }
      throw Exception("Erreur réseau : ${e.message}");
    }
  }
}