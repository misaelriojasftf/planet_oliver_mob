part of '../index.dart';

class HomeRepository {
  static const _idty = "home_repository";
  static void log(value) => Logger.log(_idty, [value]);

  static Future<bool> getCategories([bool showLoading = true]) async {
    final userClient = SessionService.getCodClient;
    return await ApiService.fetch(
      Apis.getCategories(CategoryModel.getCategories(userClient)),
      showSuccessDialog: false,
      showLoading: showLoading,
      onSuccessList: (dataList) =>
          CategoriesState().update(List<CategoryModel>.from(
        dataList.map((e) => CategoryModel.fromJson(e)),
      )),
    );
  }

  static Future<List<ProductModel>> getLocalProducts(LocalModel local) async {
    final userClient = SessionService.getCodClient;
    List<ProductModel> products = [];
    await ApiService.fetch(
      Apis.getProductsByLocal(local.getProductsRequest(userClient)),
      showSuccessDialog: false,
      showLoading: false,
      onSuccessList: (dataList) => products = List<ProductModel>.from(
        dataList.map((e) => ProductModel.fromJson(e)),
      ),
    );
    return products;
  }

  static Future<bool> getList([bool showLoading = false]) async {
    /// [FilterState - getValue] gets filter model[
    final filter = FilterState().getValue;

    log("CAN LOAD ${FilterState().canLoad}");

    /// [canLoad] verifies if user can get more elements
    if (!FilterState().canLoad) return false;

    /// [canLoad] verifies for [pull] request
    if (!FilterState().canLoad) _reset;

    return await ApiService.fetch(
      Apis.getElements(filter.toJson),
      showSuccessDialog: false,
      onError: (_) => FilterState().cantLoad,
      showLoading: showLoading ?? true,
      onSuccessList: (dataList) {
        FilterState().nextPage;

        /// [cantLoad] is used to set once values are empty
        if (dataList.isEmpty) FilterState().cantLoad;

        /// [isLocalFilter] to verify fill [LocalState]
        if (filter.isLocalFilter)
          LocalsState().addMore(List<LocalModel>.from(
              dataList.map((e) => LocalModel.fromJson(e))));

        /// [isProductFilter] to verify fill [ProductState]
        if (filter.isProductFilter)
          ProductState().addMore(List<ProductModel>.from(
              dataList.map((e) => ProductModel.fromJson(e))));
      },
    );
  }

  static get _reset {
    ProductState().clean;
    LocalsState().clean;
    FilterState().reset;
  }

  static get _cleanElements {
    ProductState().clean;
    LocalsState().clean;
  }
}
