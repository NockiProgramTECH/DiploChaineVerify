import 'package:dio/dio.dart';
import 'package:recruteur/service/dio_client.dart';


class ApiService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> verifyDiploma({
    required String diplomaId,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        "/api/diplomas/verify/scan/",
        data: {
          "diploma_id": diplomaId,
          if (lastName != null) "student_last_name": lastName,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        throw Exception("Erreur réseau");
      }
    }
  }
}