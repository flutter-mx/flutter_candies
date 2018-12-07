import 'dart:async';

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:loading_more_list/indicator_widget.dart';
import 'package:loading_more_list/refresh_base.dart';

abstract class LoadingMoreBase<T> extends ListBase<T>
    with _LoadingMoreBloc<T>, RefreshBase {
  var _array = <T>[];

  @override
  T operator [](int index) {
    // TODO: implement []
    return _array[index];
  }

  @override
  void operator []=(int index, T value) {
    // TODO: implement []=
    _array[index] = value;
  }

  bool get hasMore => true;
  bool isLoading = false;

  //do not change this in out side
  IndicatorStatus indicatorStatus = IndicatorStatus.None;

  @protected
  @mustCallSuper
  Future<bool> loadMore() async {
    var preStatus = indicatorStatus;
    indicatorStatus = IndicatorStatus.LoadingMoreBusying;
    if (preStatus != indicatorStatus) {
      onStateChanged(this);
    }
    return await _innerloadData();
  }

  Future<bool> _innerloadData() async {
    if (isLoading || !hasMore) return true;
    // TODO: implement loadMore

    isLoading = true;
    var isSuccess = await loadData();
    isLoading = false;
    if (isSuccess) {
      indicatorStatus = IndicatorStatus.None;
      if (this.length == 0) indicatorStatus = IndicatorStatus.Empty;
    } else {
      indicatorStatus = IndicatorStatus.Error;
    }
    onStateChanged(this);
    return isSuccess;
  }

  @protected
  Future<bool> loadData();

  @override
  @protected
  @mustCallSuper
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    // TODO: implement OnRefresh
    if (clearBeforeRequest) this.clear();
    var preStatus = indicatorStatus;
    indicatorStatus = IndicatorStatus.FullScreenBusying;
    if (preStatus != indicatorStatus) {
      onStateChanged(this);
    }
    return await _innerloadData();
  }

  @override
  @protected
  @mustCallSuper
  Future<bool> errorRefresh() async {
    // TODO: implement OnRefresh
    if (this.length == 0) return await refresh(false);
    return await loadMore();
  }

  @override
  int get length => _array.length;
  set length(int newLength) => _array.length = newLength;

  @override
  @protected
  @mustCallSuper
  void onStateChanged(LoadingMoreBase<T> source) {
    // TODO: implement notice
    super.onStateChanged(source);
  }
}

class _LoadingMoreBloc<T> {
  final _rebuild = new StreamController<LoadingMoreBase<T>>.broadcast();
  Stream<LoadingMoreBase<T>> get rebuild => _rebuild.stream;

  void onStateChanged(LoadingMoreBase<T> source) {
    if (!_rebuild.isClosed) _rebuild.sink.add(source);
  }

  void dispose() {
    _rebuild.close();
  }
}
