class ListOfHistory {
  static List<String>? _currentName, _docId, _searchedName, _distance;

  static get searchedNameList => _searchedName;
  static get currentNameList => _currentName;
  static get distanceList => _distance;
  static get docIdList => _docId;

  static set setSearchedNameList(response) => _searchedName = response;
  static set setCurrentNameList(response) => _currentName = response;
  static set setDistanceList(response) => _distance = response;
  static set setDocId(response) => _docId = response;
}
