import 'dart:async';

import 'package:appclientes/shared/common.dart';
import 'package:appclientes/shared/components/app_button_switch/switch_option.dart';
import 'package:appclientes/v_card/content/card_registered.dart';
import 'package:appclientes/v_card/controller/index.dart';
import 'package:appclientes/v_cart/content/build_events.dart';
import 'package:appclientes/v_cart/controller/state/order_type_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'content/build_delivery.dart';
import 'content/build_product.dart';
import 'content/build_tip.dart';
import 'content/delivery_options.dart';
import 'controller/index.dart';

class BuyView extends StatefulWidget {
  final Function callback;
  BuyView({this.callback});

  @override
  _BuyViewState createState() => _BuyViewState();
}

class _BuyViewState extends State<BuyView> {
  ORDER_TYPE orderType;
  ORDER_AVAILABLE orderAvailable = ORDER_AVAILABLE.ALL;
  StreamSubscription cartSubscription;
  num tip = 0;
  CardModel _cardToPay;

  @override
  Widget build(BuildContext context) {
    return AppViews.common(
      text: "Finaliza tu Compra",
      back: widget.callback,
      child: ListView(
        children: [
          _buildSaleCard,
          if (CartEvents.hasToken)
            CardRegistered(
              type: CARD_REGISTER.CART,
              selectedCard: onSelectCard,
            ),
          _buildButton
        ],
      ),
    );
  }

  AppCard get _buildSaleCard {
    return AppCard(
      buildOpen: true,
      title: "CARRITO DE COMPRAS",
      paddingH: 0,
      child: Column(
        children: [
          _buildProducts,
          Column(
            children: [
              if (ORDER_TYPE.DELIVERY == orderType) _buildDeliveryAmount,
              CartRender(child: () {
                final items = CartState().getValue.length;
                tip = 0;
                if (items > 0) {
                  tip = CartState()
                      .getTipIndex(); // ?? AppParams.tipIndexDefault;
                  return RowDeliveryInfo(
                      child: BuildTip(
                    onTipChange: addTip,
                    initial: tip,
                  ));
                }
              }),
            ],
          ),
          _buildTotal,
        ],
      ),
    );
  }

  Widget get _buildButton {
    return CartRender(
      child: () => Container(
        padding: EdgeInset.vertical(25.0),
        alignment: Alignment.center,
        child: Buttons.yellow(
          "Pagar",
          disable: CartEvents.isCartEmpty(),
          onClick: () => CartEvents.doPay(
            orderType,
            getSelectedCard(),//_cardToPay,
          ),
        ),
      ),
    );
  }

  Widget get _buildTotal {
    return EdgeInset.appPadding(
      vertical: 20.0,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Texts.blackBold("Total:".toUpperCase(), fontSize: 16),
            CartRender(
              child: () => Column(
                children: [
                  Texts.black(realPrice,
                      decoration: TextDecoration.lineThrough, fontSize: 13),
                  Texts.blackBold(totalSale, fontSize: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildProducts {
    return Column(
      children: [
        EdgeInset.appPadding(
            child: BuildSwitchOptions(
          onSwitch: onSwitchOrderType,
          available: orderAvailable,
          orderType: orderType,
        )),
        if (ORDER_TYPE.PICKUP == orderType) DeliveryOption(),
        EdgeInset.appPadding(
          child: CartRender(
            child: () {
              final list = CartState().getValue;
              return Column(
                children: [
                  for (CartItemModel item in list)
                    ItemBuy(
                      item: item,
                      sum: (_) => CartState().sum(_),
                      rest: (_) => CartState().rest(_),
                      onRemove: (_) => CartEvents.remove(_),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get _buildDeliveryAmount {
    return CartRender(
      child: () {
        final delivery = CartState().deliveryString;
        return RowDeliveryInfo(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Texts.blackBold("Domicilio:", fontSize: 16),
              Texts.blackBold(delivery, fontSize: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    initOrderType();
    checkAvailability(CartState().getValue);
    cartSubscription =
        CartState().getEvents.listen((event) => checkAvailability(event));
  }

  @override
  void dispose() {
    cartSubscription.cancel();
    super.dispose();
  }

  void initOrderType() {
    if (CartState().getValue.length > 0) {
      orderType = OrderTypeState().getValue;
    } else {
      orderType = ORDER_TYPE.DELIVERY;
    }
    // if (mounted) setState(() {});
  }

  void saveOrderType(ORDER_TYPE orderType) {
    if (CartState().getValue.length > 0) {
      OrderTypeState().update(orderType);
    }
  }

  void checkAvailability(List<CartItemModel> event) {
    if (event is List && event.isNotEmpty) {
      final _orderAvailable = event.first.orderAvailable;
      if (mounted)
        setState(() {
          orderAvailable = _orderAvailable;
        });
      onChangeOrderAvailable(orderAvailable);
    }
  }

  void onChangeOrderAvailable(ORDER_AVAILABLE value) {
    switch (value) {
      case ORDER_AVAILABLE.DELIVERY:
        saveOrderType(ORDER_TYPE.DELIVERY);
        orderType = ORDER_TYPE.DELIVERY;
        break;
      case ORDER_AVAILABLE.PICKUP:
        saveOrderType(ORDER_TYPE.PICKUP);
        orderType = ORDER_TYPE.PICKUP;
        break;
      default:
        if (mounted) setState(() {});
    }
  }

  void onSwitchOrderType(ORDER_TYPE newType) {
    saveOrderType(newType);
    if (mounted) setState(() => orderType = newType);
  }

  void addTip(num number) => setState(() => tip = number);

  //void onSelectCard(CardModel card) => setState(() => _cardToPay = card);
  
  void onSelectCard(CardModel card) {
    //_cardToPay = CartState().getCardModel();
  }

  CardModel getSelectedCard(){
    return  CartState().getCardModel();
  }

  get totalAmount {
    if (CartState().getValue.length == 0) return 0;
    if (orderType == ORDER_TYPE.DELIVERY)
      return (CartState().total + CartState().delivery + CartState().getTip());
    return (CartState().total + CartState().getTip());
  }

  get realTotal {
    if (CartState().getValue.length == 0) return 0;
    if (orderType == ORDER_TYPE.DELIVERY) {
      if (CartState().realPrice == 0) return 0;
      return (CartState().realPrice +
          CartState().delivery +
          CartState().getTip());
    }
    return (CartState().realPrice + CartState().getTip());
  }

  String get totalSale => realTotal == 0 ? "0" : CartEvents.toCOP(totalAmount);
  String get realPrice => realTotal == 0 ? "" : CartEvents.toCOP(realTotal);
}
