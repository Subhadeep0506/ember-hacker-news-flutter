import 'package:flutter/material.dart';

import '../components/ember_vote_pill.dart';
import 'ember_preview.dart';

@EmberPreview(name: 'EmberVotePill — default', group: 'Engagement')
Widget emberVotePillPreview() {
  return const EmberVotePill(score: 142);
}

@EmberPreview(name: 'EmberVotePill — upvoted', group: 'Engagement')
Widget emberVotePillUpvotedPreview() {
  return const EmberVotePill(score: 143, isUpvoted: true);
}

@EmberPreview(name: 'EmberVotePill — loading', group: 'Engagement')
Widget emberVotePillLoadingPreview() {
  return const EmberVotePill(score: 142, isLoading: true);
}

@EmberPreview(name: 'EmberVotePill — row', group: 'Engagement')
Widget emberVotePillRowPreview() {
  return const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EmberVotePill(score: 42),
      SizedBox(width: 12),
      EmberVotePill(score: 256, isUpvoted: true),
      SizedBox(width: 12),
      EmberVotePill(score: 1024, isLoading: true),
    ],
  );
}
