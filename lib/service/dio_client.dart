import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.69:8000", // IP fournie par l'utilisateur
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("\n--- REQUÊTE API ---");
        print("URL: ${options.baseUrl}${options.path}");
        print("Méthode: ${options.method}");
        print("Headers: ${options.headers}");
        print("Body: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("\n--- RÉPONSE API ---");
        print("Status: ${response.statusCode}");
        print("Données: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("\n--- ERREUR API ---");
        print("Type d'erreur: ${e.type}");
        print("Message: ${e.message}");
        if (e.response != null) {
          print("Status de réponse: ${e.response?.statusCode}");
          print("Données d'erreur: ${e.response?.data}");
        }
        return handler.next(e);
      },
    ));
}