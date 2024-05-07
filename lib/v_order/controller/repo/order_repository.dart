part of '../index.dart';

class OrderRepository {
  static Future<OrderList> getOrdersByClient(
      [String codClient, bool showSuccess = false, bool showSuccessDialog = false]) async {
    if (codClient is String && codClient.isNotEmpty) {
      OrderList orders;
      await ApiService.fetch(
        Apis.getOrdersByClient(OrderModel.getOrderList(codClient)),
        verifyBasicToken: showSuccess,
        showSuccessDialog: showSuccessDialog,
        showLoading: showSuccess,
        onSuccess: (res) =>
            res.data is Map && res.data["entity"]["datalist"] is List
                ? orders = OrderList.fromJson(res.data["entity"])
                : null,
      );

      return orders;
    }
    return null;
  }
}
