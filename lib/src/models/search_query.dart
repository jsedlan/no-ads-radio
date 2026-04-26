enum StationOrdering {
  clickCount('clickcount', 'Most clicked'),
  votes('votes', 'Top voted'),
  random('random', 'Random'),
  name('name', 'Name');

  const StationOrdering(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class StationSearchQuery {
  const StationSearchQuery({
    this.name = '',
    this.countryCode = '',
    this.language = '',
    this.tag = '',
    this.ordering = StationOrdering.clickCount,
  });

  final String name;
  final String countryCode;
  final String language;
  final String tag;
  final StationOrdering ordering;

  bool get isEmpty =>
      name.trim().isEmpty &&
      countryCode.trim().isEmpty &&
      language.trim().isEmpty &&
      tag.trim().isEmpty;
}
