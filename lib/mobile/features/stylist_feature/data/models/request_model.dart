import 'package:doloooki/mobile/features/stylist_feature/data/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String userId;
  final String stylistId;
  final String stylistName;
  final String title;
  final String request;
  final String status;
  final Timestamp createdAt;
  final int looksCount;
  final List<String> fullBodyImages;
  final List<String> portraitImages;
  
  RequestModel({
    required this.id,
    required this.userId,
    required this.stylistId,
    required this.stylistName,
    required this.title,
    required this.request,
    required this.status,
    required this.createdAt,
    required this.looksCount,
    required this.fullBodyImages,
    required this.portraitImages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'title': title,
      'request': request,
      'status': status,
      'createdAt': createdAt,
      'looksCount': looksCount,
      'fullBodyImages': fullBodyImages,
      'portraitImages': portraitImages,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RequestModel(
      id: documentId,
      userId: map['userId'] ?? '',
      stylistId: map['stylistId'] ?? '',
      stylistName: map['stylistName'] ?? '',
      title: map['title'] ?? '',
      request: map['request'] ?? '',
      status: map['status'] ?? 'В процессе',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      looksCount: map['looksCount'] ?? 1,
      fullBodyImages: List<String>.from(map['fullBodyImages'] ?? []),
      portraitImages: List<String>.from(map['portraitImages'] ?? []),
    );
  }

  RequestModel copyWith({
    String? id,
    String? userId,
    String? stylistId,
    String? stylistName,
    String? title,
    String? request,
    String? status,
    Timestamp? createdAt,
    int? looksCount,
    List<String>? fullBodyImages,
    List<String>? portraitImages,
  }) {
    return RequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      title: title ?? this.title,
      request: request ?? this.request,
      status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      looksCount: looksCount ?? this.looksCount,
      fullBodyImages: fullBodyImages ?? this.fullBodyImages,
      portraitImages: portraitImages ?? this.portraitImages,
    );
  }
}