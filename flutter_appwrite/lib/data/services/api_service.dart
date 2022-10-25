import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:easy_one/data/model/addData_model.dart';
import 'package:easy_one/data/model/user_model.dart';

import 'package:easy_one/res/constant.dart';

class ApiService {
  static ApiService _instance;

  Client _client;
  Account _account;
  Databases _db;
  Storage _storage;

  ApiService._internal() {
    _client = Client(endPoint: AppConstant.endPoint)
        .setProject(AppConstant.projectid)
        .setSelfSigned();
    _account = Account(_client);
    _db = Databases(_client);
    _storage = Storage(_client);
  }

  static ApiService get instance {
    if (_instance == null) {
      _instance = ApiService._internal();
    }
    return _instance;
  }

  Future login({String email, String password}) {
    return _account.createEmailSession(email: email, password: password);
  }

  Future signup({String name, String email, String password}) {
    return _account.create(
        userId: ID.unique(), name: name, email: email, password: password);
  }

  Future updateanylogin({String email, String password}) {
    return _account.updateEmail(email: email, password: password);
  }

  Future logout() {
    return _account.deleteSession(sessionId: 'current');
  }

  Future<User> getUser() async {
    final res = await _account.get();
    return User.fromMap(res.toMap());
  }

  Future<AddData> getAddData({
    AddData addData,
  }) async {
    final res = await _db.createDocument(
      databaseId: AppConstant.database,
      collectionId: AppConstant.collection,
      documentId: ID.unique(),
      data: addData.toMap(),
    );
    return AddData.fromMap(res.data);
  }

  Future<List<AddData>> insertData() async {
    final res = await _db.listDocuments(
      databaseId: AppConstant.database,
      collectionId: AppConstant.collection,
    );
    return res.documents.map((e) => AddData.fromMap(e.data)).toList();
  }

  Future deleteData({String documentId}) async {
    return await _db.deleteDocument(
      databaseId: AppConstant.database,
      collectionId: AppConstant.collection,
      documentId: documentId,
    );
  }

  Future<AddData> editData({
    String documentId,
    AddData addData,
  }) async {
    final res = await _db.updateDocument(
      databaseId: AppConstant.database,
      collectionId: AppConstant.collection,
      documentId: documentId,
      data: addData.toMap(),
    );

    return AddData.fromMap(res.data);
  }

  Future<Map<String, dynamic>> uploadPicture(
    InputFile file,
  ) async {
    var res = await _storage.createFile(
      bucketId: AppConstant.bucket,
      fileId: ID.unique(),
      file: file,
    );
    return res.toMap();
  }

  Future<Map<String, dynamic>> updatePrefs(Map<String, dynamic> prefs) async {
    final res = await _account.updatePrefs(prefs: prefs);
    return res.toMap();
  }

  Future<Uint8List> getProfile(String fileId) async {
    final res = await _storage.getFilePreview(
      bucketId: AppConstant.bucket,
      fileId: fileId,
    );
    return res;
  }
}
