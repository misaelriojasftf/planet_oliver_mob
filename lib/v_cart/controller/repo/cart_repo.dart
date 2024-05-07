part of '../index.dart';

class CartRepository {
  static const _idty = "cart_repository";
  static void log(value) => Logger.log(_idty, [value]);

  static Future<bool> sendPayment2(OrderModel order) => ApiService.fetch(
        Apis.processOrderClient(OrderModel.getOrder(order)),
        showSuccessDialog: false,
        onSuccessList: (dataList) =>
            CategoriesState().update(List<CategoryModel>.from(
          dataList.map((e) => CategoryModel.fromJson(e)),
        )),
      );
  
    static Future<HeaderResponseModel> sendPayment(OrderModel order) async {
    HeaderResponseModel headerResponseModel;
      await ApiService.fetch(
        Apis.processOrderClient(OrderModel.getOrder(order)),
        showSuccessDialog: false,
        onSuccessList: (dataList) =>
            CategoriesState().update(List<CategoryModel>.from(
              dataList.map((e) => CategoryModel.fromJson(e)),
            )),
        onSuccess: (res) =>
        res.data is Map && res.data["result"] is Map
            ? headerResponseModel = HeaderResponseModel.fromJson(res.data["result"])
            : null,
      );
      return headerResponseModel;
    }
}
