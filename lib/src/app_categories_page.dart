part of 'app.dart';

class _CategoriesPage extends StatefulWidget {
  const _CategoriesPage({required this.controller});

  final RadioAppController controller;

  @override
  State<_CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<_CategoriesPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<FavoriteCategory> _categories;
  bool _didLocalizeDefaultCategory = false;

  @override
  void initState() {
    super.initState();
    final categories = widget.controller.favoriteCategories.isEmpty
        ? const <FavoriteCategory>[
            FavoriteCategory(id: 'category-0-favorites', name: 'Favorites'),
          ]
        : widget.controller.favoriteCategories;
    _categories = List<FavoriteCategory>.from(categories, growable: true);
    _controllers = categories
        .map((category) => TextEditingController(text: category.name))
        .toList(growable: true);
    _focusNodes = List<FocusNode>.generate(
      categories.length,
      (_) => FocusNode(),
      growable: true,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLocalizeDefaultCategory) {
      return;
    }
    _didLocalizeDefaultCategory = true;
    for (var index = 0; index < _categories.length; index += 1) {
      if (_categories[index].name.trim() == 'Favorites') {
        _controllers[index].text = context.l10n.favorites;
      }
    }
  }

  void _addCategory() {
    setState(() {
      _categories.add(
        FavoriteCategory(
          id: 'category-${DateTime.now().microsecondsSinceEpoch}-${_categories.length}',
          name: '',
        ),
      );
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.last.requestFocus();
      }
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _categories.removeAt(index);
      _controllers.removeAt(index).dispose();
      _focusNodes.removeAt(index).dispose();
    });
  }

  Future<void> _saveAndClose() async {
    final values = List<FavoriteCategory>.generate(_controllers.length, (
      index,
    ) {
      final originalName = _categories[index].name.trim();
      final editedName = _controllers[index].text.trim();
      return _categories[index].copyWith(
        name:
            originalName == 'Favorites' && editedName == context.l10n.favorites
            ? 'Favorites'
            : editedName,
      );
    }, growable: false);
    await widget.controller.setFavoriteCategoryItems(values);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Shell(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.categories,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _saveAndClose,
                    child: Text(context.l10n.done),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.categoriesDescription,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _mutedTextColor(context),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List<Widget>.generate(_controllers.length, (
                              index,
                            ) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _controllers.length - 1
                                      ? 0
                                      : 12,
                                ),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textInputAction:
                                      index == _controllers.length - 1
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: index == 0
                                        ? context.l10n.favorites
                                        : context.l10n.newCategory,
                                    suffixIcon: IconButton(
                                      onPressed: () => _removeCategory(index),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                      tooltip: context.l10n.removeCategory,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _addCategory,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(context.l10n.addCategory),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
