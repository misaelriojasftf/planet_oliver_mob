import 'dart:async';

import 'package:appclientes/shared/common.dart';
import 'package:appclientes/shared/constants/index.dart';
import 'package:flutter/material.dart';

/// return true is refresh success
///
/// return false or null is fail
typedef Future<bool> FutureCallBack();

class Pager extends StatefulWidget {
  static DelegateBuilder<LoadMoreDelegate> buildDelegate =
      () => DefaultLoadMoreDelegate();
  static DelegateBuilder<LoadMoreTextBuilder> buildTextBuilder =
      () => DefaultLoadMoreTextBuilder.general;

  /// Only support [ListView],[SliverList]
  final Widget child;

  /// return true is refresh success
  ///
  /// return false or null is fail
  final FutureCallBack onLoadMore;

  /// if [isFinish] is true, then loadMoreWidget status is [LoadMoreStatus.nomore].
  final bool isFinish;

  /// see [LoadMoreDelegate]
  final LoadMoreDelegate delegate;

  /// see [LoadMoreTextBuilder]
  final LoadMoreTextBuilder textBuilder;

  /// when [whenEmptyLoad] is true, and when listView children length is 0,or the itemCount is 0,not build loadMoreWidget
  final bool whenEmptyLoad;

  /// when [tag] is not empty it will show the widget for empty
  final String tag;

  /// when [onEmpty] is avaialble will be displayed in empty cases
  final Widget Function(String) onEmpty;

  final bool isEmpty;

  const Pager(
      {Key key,
      @required this.child,
      @required this.onLoadMore,
      this.textBuilder,
      this.isFinish = false,
      this.delegate,
      this.tag,
      this.whenEmptyLoad = true,
      this.onEmpty,
      this.isEmpty})
      : super(key: key);

  @override
  _LoadMoreState createState() => _LoadMoreState();
}

class _LoadMoreState extends State<Pager> {
  Widget get child => widget.child;

  LoadMoreDelegate get loadMoreDelegate =>
      widget.delegate ?? Pager.buildDelegate();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onLoadMore == null) {
      return child;
    }
    if (child is ListView) {
      return _buildListView(child);
    }
    if (child is SliverList) {
      return _buildSliverList(child);
    }
    return child;
  }

  /// if call the method, then the future is not null
  /// so, return a listview and  item count + 1
  Widget _buildListView(ListView listView) {
    var delegate = listView.childrenDelegate;
    outer:
    if (delegate is SliverChildBuilderDelegate) {
      SliverChildBuilderDelegate delegate = listView.childrenDelegate;
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      var viewCount = delegate.estimatedChildCount + 1;
      IndexedWidgetBuilder builder = (context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index);
      };

      return ListView.builder(
        itemBuilder: builder,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
        itemCount: viewCount,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
      );
    } else if (delegate is SliverChildListDelegate) {
      SliverChildListDelegate delegate = listView.childrenDelegate;

      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }

      delegate.children.add(_buildLoadMoreView());
      return ListView(
        children: delegate.children,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
      );
    }
    return listView;
  }

  Widget _buildSliverList(SliverList list) {
    final delegate = list.delegate;
    if (delegate == null) {
      return list;
    }

    if (delegate is SliverChildListDelegate) {
      return SliverList(
        delegate: null,
      );
    }

    outer:
    if (delegate is SliverChildBuilderDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      final viewCount = delegate.estimatedChildCount + 1;
      IndexedWidgetBuilder builder = (context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index);
      };

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          builder,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          childCount: viewCount,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    outer:
    if (delegate is SliverChildListDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      delegate.children.add(_buildLoadMoreView());
      return SliverList(
        delegate: SliverChildListDelegate(
          delegate.children,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    return list;
  }

  LoadMoreStatus status = LoadMoreStatus.idle;

  Widget _buildLoadMoreView() {
    if (widget.isFinish == true) {
      this.status = LoadMoreStatus.nomore;
    } else {
      if (this.status == LoadMoreStatus.nomore) {
        this.status = LoadMoreStatus.idle;
      }
    }
    return NotificationListener<_RetryNotify>(
      child: NotificationListener<_BuildNotify>(
        child: DefaultLoadMoreView(
          status: status,
          delegate: loadMoreDelegate,
          textBuilder: widget.textBuilder ?? Pager.buildTextBuilder(),
          onEmpty: widget.onEmpty,
          tag: widget.tag,
          isEmpty: widget.isEmpty,
        ),
        onNotification: _onLoadMoreBuild,
      ),
      onNotification: _onRetry,
    );
  }

  bool _onLoadMoreBuild(_BuildNotify notification) {
    //判断状态，触发对应的操作
    if (status == LoadMoreStatus.loading) {
      return false;
    }
    if (status == LoadMoreStatus.nomore) {
      return false;
    }
    if (status == LoadMoreStatus.fail) {
      return false;
    }
    if (status == LoadMoreStatus.idle) {
      // 切换状态为加载中，并且触发回调
      loadMore();
    }
    return false;
  }

  void _updateStatus(LoadMoreStatus status) {
    if (mounted) setState(() => this.status = status);
  }

  bool _onRetry(_RetryNotify notification) {
    loadMore();
    return false;
  }

  void loadMore() {
    _updateStatus(LoadMoreStatus.loading);
    widget.onLoadMore().then((v) {
      if (v == true) {
        // 成功，切换状态为空闲
        _updateStatus(LoadMoreStatus.idle);
      } else {
        // 失败，切换状态为失�����
        _updateStatus(LoadMoreStatus.fail);
      }
    });
  }
}

enum LoadMoreStatus {
  /// 空闲中，表示当前等待加载
  ///
  /// wait for loading
  idle,

  /// 刷新中，不应该继续加载，等待future返回
  ///
  /// the view is loading
  loading,

  /// 刷新失败，刷新失败，这时需要点击才能刷新
  ///
  /// loading fail, need tap view to loading
  fail,

  /// 没有更多，没有更多数据了，这个状态不触发任何条件
  ///
  /// not have more data
  nomore,
}

class DefaultLoadMoreView extends StatefulWidget {
  final LoadMoreStatus status;
  final LoadMoreDelegate delegate;
  final LoadMoreTextBuilder textBuilder;
  final Widget Function(String) onEmpty;
  final String tag;
  final bool isEmpty;
  const DefaultLoadMoreView({
    Key key,
    this.status = LoadMoreStatus.idle,
    @required this.delegate,
    @required this.textBuilder,
    this.onEmpty,
    this.tag,
    this.isEmpty,
  }) : super(key: key);

  @override
  DefaultLoadMoreViewState createState() => DefaultLoadMoreViewState();
}

const _defaultLoadMoreHeight = 80.0;
const _loadmoreIndicatorSize = 33.0;
const _loadMoreDelay = 16;

class DefaultLoadMoreViewState extends State<DefaultLoadMoreView> {
  LoadMoreDelegate get delegate => widget.delegate;

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMoreStatus.fail ||
            widget.status == LoadMoreStatus.idle) {
          _RetryNotify().dispatch(context);
        }
      },
      child: Container(
        // height: delegate.widgetHeight(widget.status),
        alignment: Alignment.center,
        child: delegate.buildChild(
          widget.status,
          builder: widget.textBuilder,
          onEmpty: widget.onEmpty,
          tag: widget.tag,
          isEmpty: widget.isEmpty,
        ),
      ),
    );
  }

  void notify() async {
    var delay = max(delegate.loadMoreDelay(), Duration(milliseconds: 16));
    await Future.delayed(delay);
    if (widget.status == LoadMoreStatus.idle) {
      _BuildNotify().dispatch(context);
    }
  }

  Duration max(Duration duration, Duration duration2) {
    if (duration > duration2) {
      return duration;
    }
    return duration2;
  }
}

class _BuildNotify extends Notification {}

class _RetryNotify extends Notification {}

typedef T DelegateBuilder<T>();

/// loadmore widget properties
abstract class LoadMoreDelegate {
  static DelegateBuilder<LoadMoreDelegate> buildWidget =
      () => DefaultLoadMoreDelegate();

  const LoadMoreDelegate();

  /// the loadmore widget height
  double widgetHeight(LoadMoreStatus status) => _defaultLoadMoreHeight;

  /// build loadmore delay
  Duration loadMoreDelay() => Duration(milliseconds: _loadMoreDelay);

  Widget buildChild(
    LoadMoreStatus status, {
    LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.general,
    String tag,
    Widget Function(String) onEmpty,
    bool isEmpty,
  });
}

class DefaultLoadMoreDelegate extends LoadMoreDelegate {
  const DefaultLoadMoreDelegate();

  @override
  Widget buildChild(
    LoadMoreStatus status, {
    LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.general,
    String tag,
    Widget Function(String) onEmpty,
    bool isEmpty,
  }) {
    // String text = builder(status);
    if (status == LoadMoreStatus.fail && isEmpty) {
      return Container(child: onEmpty(tag) ?? null);
    }
    // if (status == LoadMoreStatus.idle) {
    //   return drawText(text);
    // }
    if (status == LoadMoreStatus.loading || status == LoadMoreStatus.idle) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInset.top(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _loadmoreIndicatorSize,
              height: _loadmoreIndicatorSize,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(AppColors.yellow),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: drawText(text),
            // ),
          ],
        ),
      );
    }
    // if (status == LoadMoreStatus.nomore) {
    //   return drawText(text);
    // }

    // return drawText(text);
    return Container();
  }
}

typedef String LoadMoreTextBuilder(LoadMoreStatus status);

String _buildGeneralText(LoadMoreStatus status) {
  String text;
  switch (status) {
    case LoadMoreStatus.fail:
      text = "Al parecer no hay mas elementos, pull para recargar";
      break;
    case LoadMoreStatus.idle:
      text = "esperando por carga";
      break;
    case LoadMoreStatus.loading:
      text = "cargando, espere un momento";
      break;
    case LoadMoreStatus.nomore:
      text = "no hay mas elementos";
      break;
    default:
      text = "";
  }
  return text;
}

class DefaultLoadMoreTextBuilder {
  static const LoadMoreTextBuilder general = _buildGeneralText;
}

Widget drawText(String text) {
  return Texts.blackBold(text, fontSize: 12);
}
