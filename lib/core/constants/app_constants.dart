/// Developer: Coach: Danilo
class AppConstants {
  AppConstants._();

  static const String appName = 'TouchlineHQ';
  static const String developerCredit = 'Developer: Coach: Danilo';

  static const List<String> positions = [
    'GK',
    'CB', 'LB', 'RB', 'LWB', 'RWB',
    'CDM', 'CM', 'CAM', 'LM', 'RM',
    'LW', 'RW', 'CF', 'ST',
  ];

  static const List<String> positionGroups = ['GK', 'DEF', 'MID', 'FWD'];

  static const List<String> formations = [
    '4-3-3', '4-4-2', '4-2-3-1', '3-5-2', '5-3-2', '4-1-4-1',
  ];

  static const List<String> quickFilters = [
    'Wonderkid',
    'Hidden Gem',
    'Real Face',
    'Free Agent',
  ];
}

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const search = '/search';
  static const squadBuilder = '/squad-builder';
  static const tacticalRoom = '/tactical-room';
}
