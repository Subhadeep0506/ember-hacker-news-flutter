class Comment {
  final int id;
  final String? by;
  final int? time;
  final String? text;
  final int? parent;
  final bool dead;
  final bool deleted;
  final List<Comment> children;

  const Comment({
    required this.id,
    this.by,
    this.time,
    this.text,
    this.parent,
    this.dead = false,
    this.deleted = false,
    this.children = const [],
  });

  int get totalChildCount {
    var count = children.length;
    for (final child in children) {
      count += child.totalChildCount;
    }
    return count;
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] as List<dynamic>?;
    return Comment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      by: json['by'] as String? ?? json['author'] as String?,
      time: (json['time'] as num?)?.toInt(),
      text: json['text'] as String?,
      parent: (json['parent'] as num?)?.toInt(),
      dead: json['dead'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      // Dead/deleted comments are kept in the tree so the "Show dead & deleted"
      // setting can decide their visibility at render time (see flattenComments).
      children:
          rawChildren
              ?.whereType<Map<String, dynamic>>()
              .map((c) => Comment.fromJson(c))
              .where((c) => c.id != 0)
              .toList() ??
          const [],
    );
  }
}
