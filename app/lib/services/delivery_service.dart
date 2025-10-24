import 'dart:convert';
import 'package:app/models/delivery.dart';
import 'package:app/config/api_constants.dart';
import 'package:app/utils/request_helper.dart';
import 'package:http/http.dart' as http;

/// Service class for handling delivery-related API calls
class DeliveryService {
  /// Get all deliveries for a specific user
  static Future<List<Delivery>> getUserDeliveries(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiConstants.withDynamicSegment(ApiRoute.userDeliveries, userId),
            ),
            headers: buildHeaders(),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> deliveriesJson = responseData['data'] ?? [];

        return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
      } else {
        throw 'ไม่สามารถโหลดข้อมูลการส่งสินค้าได้';
      }
    } catch (e) {
      if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
        rethrow;
      }
      throw 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${e.toString()}';
    }
  }

  // Comming soon...
  
  // /// Create a new delivery
  // static Future<Delivery> createDelivery(
  //   Map<String, dynamic> deliveryData,
  // ) async {
  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('${ApiConstants.baseUrl}/deliveries'),
  //           headers: buildHeaders(),
  //           body: json.encode(deliveryData),
  //         )
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  //           },
  //         );

  //     if (response.statusCode == 201) {
  //       final responseData = json.decode(response.body);
  //       return Delivery.fromJson(responseData['data']);
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw errorData['message'] ?? 'ไม่สามารถสร้างรายการส่งสินค้าได้';
  //     }
  //   } catch (e) {
  //     if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
  //       rethrow;
  //     }
  //     throw 'เกิดข้อผิดพลาดในการสร้างรายการส่งสินค้า: ${e.toString()}';
  //   }
  // }

  // /// Update delivery status
  // static Future<Delivery> updateDeliveryStatus(
  //   String deliveryId,
  //   String status,
  // ) async {
  //   try {
  //     final response = await http
  //         .patch(
  //           Uri.parse('${ApiConstants.baseUrl}/deliveries/$deliveryId/status'),
  //           headers: buildHeaders(),
  //           body: json.encode({'status': status}),
  //         )
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  //           },
  //         );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       return Delivery.fromJson(responseData['data']);
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw errorData['message'] ?? 'ไม่สามารถอัปเดตสถานะได้';
  //     }
  //   } catch (e) {
  //     if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
  //       rethrow;
  //     }
  //     throw 'เกิดข้อผิดพลาดในการอัปเดตสถานะ: ${e.toString()}';
  //   }
  // }

  // /// Get delivery by ID
  // static Future<Delivery> getDeliveryById(String deliveryId) async {
  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse('${ApiConstants.baseUrl}/deliveries/$deliveryId'),
  //           headers: buildHeaders(),
  //         )
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  //           },
  //         );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       return Delivery.fromJson(responseData['data']);
  //     } else {
  //       throw 'ไม่พบข้อมูลการส่งสินค้า';
  //     }
  //   } catch (e) {
  //     if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
  //       rethrow;
  //     }
  //     throw 'เกิดข้อผิดพลาดในการโหลดข้อมูลการส่งสินค้า: ${e.toString()}';
  //   }
  // }

  // /// Cancel delivery
  // static Future<void> cancelDelivery(String deliveryId, String reason) async {
  //   try {
  //     final response = await http
  //         .patch(
  //           Uri.parse('${ApiConstants.baseUrl}/deliveries/$deliveryId/cancel'),
  //           headers: buildHeaders(),
  //           body: json.encode({'reason': reason}),
  //         )
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  //           },
  //         );

  //     if (response.statusCode != 200) {
  //       final errorData = json.decode(response.body);
  //       throw errorData['message'] ?? 'ไม่สามารถยกเลิกรายการส่งสินค้าได้';
  //     }
  //   } catch (e) {
  //     if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
  //       rethrow;
  //     }
  //     throw 'เกิดข้อผิดพลาดในการยกเลิกรายการส่งสินค้า: ${e.toString()}';
  //   }
  // }

  // /// Get delivery history for user
  // static Future<List<Delivery>> getDeliveryHistory(
  //   String userId, {
  //   int page = 1,
  //   int limit = 20,
  // }) async {
  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse(
  //             '${ApiConstants.baseUrl}/deliveries/user/$userId/history?page=$page&limit=$limit',
  //           ),
  //           headers: buildHeaders(),
  //         )
  //         .timeout(
  //           const Duration(seconds: 30),
  //           onTimeout: () {
  //             throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  //           },
  //         );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       final List<dynamic> deliveriesJson = responseData['data'] ?? [];

  //       return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
  //     } else {
  //       throw 'ไม่สามารถโหลดประวัติการส่งสินค้าได้';
  //     }
  //   } catch (e) {
  //     if (e.toString().contains('การเชื่อมต่อหมดเวลา')) {
  //       rethrow;
  //     }
  //     throw 'เกิดข้อผิดพลาดในการโหลดประวัติ: ${e.toString()}';
  //   }
  // }
}
