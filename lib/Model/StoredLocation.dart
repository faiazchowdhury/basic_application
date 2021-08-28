class StoredLocation {
  static double _currentLat, _currentLong;
  static String _searchedName, _currentName;

  static get currentLat => _currentLat;
  static get currentLong => _currentLong;
  static get searchName => _searchedName;
  static get currenthName => _currentName;

  static set setLat(response) => _currentLat = response;
  static set setLong(response) => _currentLong = response;
  static set setName(response) => _searchedName = response;
  static set setCurrentName(response) => _currentName = response;
}
