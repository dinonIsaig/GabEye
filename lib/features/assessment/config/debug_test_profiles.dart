class DebugTestProfile {
  final String label;
  final List<int> arrangedCaps; 

  const DebugTestProfile({required this.label, required this.arrangedCaps});
}

const List<DebugTestProfile> debugTestProfiles = [
  DebugTestProfile(
    label: 'Normal',
    arrangedCaps: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
  ),
  DebugTestProfile(
    label: 'Protan — Moderate',
    arrangedCaps: [1, 14, 15, 13, 2, 5, 6, 7, 9, 8, 10, 12, 11, 4, 3],
  ),
  DebugTestProfile(
    label: 'Protan — Strong',
    arrangedCaps: [15, 1, 14, 2, 13, 3, 12, 4, 5, 6, 10, 11, 9, 8, 7],
  ),
  DebugTestProfile(
    label: 'Deutan — Moderate',
    arrangedCaps: [1, 2, 13, 14, 15, 3, 4, 12, 5, 6, 7, 8, 10, 9, 11],
  ),
  DebugTestProfile(
    label: 'Deutan — Strong',
    arrangedCaps: [1, 15, 2, 14, 3, 13, 5, 11, 7, 12, 4, 10, 6, 9, 8],
  ),
  DebugTestProfile(
    label: 'Tritan — Moderate',
    arrangedCaps: [3, 1, 2, 5, 4, 6, 8, 9, 11, 13, 10, 12, 14, 7, 15],
  ),
  DebugTestProfile(
    label: 'Tritan — Strong',
    arrangedCaps: [6, 1, 4, 3, 2, 5, 14, 9, 11, 10, 13, 7, 15, 8, 12],
  ),
  DebugTestProfile(
    label: 'Random — Moderate',
    arrangedCaps: [14, 5, 3, 1, 2, 4, 6, 9, 10, 12, 11, 15, 13, 7, 8],
  ),
  DebugTestProfile(
    label: 'Random — Strong',
    arrangedCaps: [8, 3, 9, 2, 10, 4, 13, 11, 5, 12, 1, 14, 6, 15, 7],
  ),
  DebugTestProfile(
    label: 'Unclassified',
    arrangedCaps: [3, 1, 2, 5, 4, 6, 7, 8, 9, 13, 10, 12, 14, 11, 15],
  ),
];
