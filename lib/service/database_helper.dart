import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ScanRecord {
  final int? id;
  final String diplomaId;
  final String? studentName;
  final String? degree;
  final String? university;
  final String? issuedAt;
  final String status; // 'authentic', 'revoked', 'not_found', 'name_mismatch', 'error'
  final String? reason;
  final String? message;
  final String scannedAt;
  final String? rawResponse; // full JSON stored for detail view

  ScanRecord({
    this.id,
    required this.diplomaId,
    this.studentName,
    this.degree,
    this.university,
    this.issuedAt,
    required this.status,
    this.reason,
    this.message,
    required this.scannedAt,
    this.rawResponse,
  });

  bool get isValid => status == 'authentic';
  bool? get isValidTristate {
    if (status == 'authentic') return true;
    if (status == 'revoked' || status == 'not_found' || status == 'name_mismatch') return false;
    return null; // error / unknown
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'diplomaId': diplomaId,
        'studentName': studentName,
        'degree': degree,
        'university': university,
        'issuedAt': issuedAt,
        'status': status,
        'reason': reason,
        'message': message,
        'scannedAt': scannedAt,
        'rawResponse': rawResponse,
      };

  factory ScanRecord.fromMap(Map<String, dynamic> map) => ScanRecord(
        id: map['id'],
        diplomaId: map['diplomaId'],
        studentName: map['studentName'],
        degree: map['degree'],
        university: map['university'],
        issuedAt: map['issuedAt'],
        status: map['status'],
        reason: map['reason'],
        message: map['message'],
        scannedAt: map['scannedAt'],
        rawResponse: map['rawResponse'],
      );

  /// Build a ScanRecord from an API response map
  factory ScanRecord.fromApiResponse({
    required String diplomaId,
    required Map<String, dynamic> response,
  }) {
    final diploma = response['diploma'] as Map<String, dynamic>?;
    final university = response['university'] as Map<String, dynamic>?;

    String status;
    final reason = response['reason'] as String? ?? 'error';
    if (response['valid'] == true) {
      status = 'authentic';
    } else {
      status = reason; // 'revoked', 'not_found', 'name_mismatch'
    }

    return ScanRecord(
      diplomaId: diplomaId,
      studentName: diploma?['student'] as String?,
      degree: diploma?['degree'] as String?,
      university: university?['name'] as String?,
      issuedAt: diploma?['issued_at'] as String?,
      status: status,
      reason: reason,
      message: response['message'] as String?,
      scannedAt: DateTime.now().toIso8601String(),
      rawResponse: jsonEncode(response),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'diplochain_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scan_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            diplomaId TEXT NOT NULL,
            studentName TEXT,
            degree TEXT,
            university TEXT,
            issuedAt TEXT,
            status TEXT NOT NULL,
            reason TEXT,
            message TEXT,
            scannedAt TEXT NOT NULL,
            rawResponse TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(ScanRecord record) async {
    final db = await database;
    return db.insert('scan_history', record.toMap()..remove('id'));
  }

  Future<List<ScanRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(
      'scan_history',
      orderBy: 'scannedAt DESC',
    );
    return maps.map(ScanRecord.fromMap).toList();
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete('scan_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    final db = await database;
    return db.delete('scan_history');
  }
}