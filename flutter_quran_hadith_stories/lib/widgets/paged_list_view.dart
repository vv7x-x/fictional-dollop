import 'package:flutter/material.dart';

typedef PageLoader<T> = Future<List<T>> Function(int offset, int limit);

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class PagedListView<T> extends StatefulWidget {
  final PageLoader<T> pageLoader;
  final ItemBuilder<T> itemBuilder;
  final int pageSize;
  final EdgeInsets padding;

  const PagedListView({
    super.key,
    required this.pageLoader,
    required this.itemBuilder,
    this.pageSize = 30,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final List<T> _items = [];
  final ScrollController _controller = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final next = await widget.pageLoader(_items.length, widget.pageSize);
      setState(() {
        _items.addAll(next);
        _hasMore = next.length == widget.pageSize;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _items.clear();
          _hasMore = true;
        });
        await _loadMore();
      },
      child: ListView.builder(
        controller: _controller,
        padding: widget.padding,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index < _items.length) {
            return widget.itemBuilder(context, _items[index], index);
          }
          if (_error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('حدث خطأ: $_error')),
            );
          }
          if (!_hasMore) {
            return const SizedBox(height: 80);
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}