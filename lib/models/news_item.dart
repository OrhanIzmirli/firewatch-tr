class NewsItem {
  final String contentType;
  final String actionUrl;
  final String eventStart;
  final String eventEnd;
  final String eventCity;
  final String eventLocation;
  final bool officialSource;
  final String id;
  final String title;
  final String source;
  final String sourceUrl;
  final String imageUrl;
  final String sourceLogoUrl;
  final String publishedAt;
  final String summary;
  final String category;
  final String relatedRegion;
  final int readMinutes;
  final bool isBreaking;
  final List<String> highlights;
  final List<String> paragraphs;

  /// Fire-event IDs the backend explicitly linked this article to: the
  /// strongest relatedness signal, checked before any region/title match.
  /// Empty from today's backend (see RelatedNewsTier.linked).
  final List<String> relatedFireIds;

  const NewsItem({
    this.contentType = 'fires',
    this.actionUrl = '',
    this.eventStart = '',
    this.eventEnd = '',
    this.eventCity = '',
    this.eventLocation = '',
    this.officialSource = false,
    required this.id,
    required this.title,
    required this.source,
    required this.sourceUrl,
    this.imageUrl = '',
    this.sourceLogoUrl = '',
    required this.publishedAt,
    required this.summary,
    required this.category,
    required this.relatedRegion,
    required this.readMinutes,
    required this.isBreaking,
    required this.highlights,
    required this.paragraphs,
    this.relatedFireIds = const [],
  });

  /// How long the backend's is_breaking flag is shown. The flag is set once,
  /// when the headline says "son dakika", and never cleared, so without an
  /// age limit a two-month-old story keeps its "breaking" badge.
  static const breakingWindow = Duration(hours: 6);

  /// Whether to show the "breaking" badge right now. An unparseable date is
  /// treated as not recent: the badge is a claim about time.
  bool isBreakingNow({DateTime? now}) {
    if (!isBreaking) return false;
    final published = DateTime.tryParse(publishedAt);
    if (published == null) return false;
    final age = (now ?? DateTime.now()).toUtc().difference(published.toUtc());
    return age <= breakingWindow;
  }

  Map<String, dynamic> toJson() => {
        'content_type': contentType,
        'action_url': actionUrl,
        'event_start': eventStart,
        'event_end': eventEnd,
        'event_city': eventCity,
        'event_location': eventLocation,
        'official_source': officialSource,
        'id': id,
        'title': title,
        'source': source,
        'source_url': sourceUrl,
        'image_url': imageUrl,
        'source_logo_url': sourceLogoUrl,
        'published_at': publishedAt,
        'summary': summary,
        'category': category,
        'related_region': relatedRegion,
        'read_minutes': readMinutes,
        'is_breaking': isBreaking,
        'highlights': highlights,
        'paragraphs': paragraphs,
        'related_fire_ids': relatedFireIds,
      };

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      contentType: json['content_type']?.toString() ?? 'fires',
      actionUrl: json['action_url']?.toString() ?? '',
      eventStart: json['event_start']?.toString() ?? '',
      eventEnd: json['event_end']?.toString() ?? '',
      eventCity: json['event_city']?.toString() ?? '',
      eventLocation: json['event_location']?.toString() ?? '',
      officialSource: json['official_source'] == true,
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      source: json['source'] ?? 'Bilinmiyor',
      sourceUrl: json['source_url'] ?? '',
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['thumbnail'] ?? '').toString(),
      sourceLogoUrl: (json['source_logo_url'] ?? json['sourceLogoUrl'] ?? '').toString(),
      publishedAt: json['published_at'] ?? '',
      summary: json['summary'] ?? '',
      category: json['category'] ?? 'News',
      relatedRegion: json['related_region'] ?? 'Türkiye',
      readMinutes: json['read_minutes'] ?? 5,
      isBreaking: json['is_breaking'] ?? false,
      highlights: List<String>.from(
        json['highlights'] is String
            ? [json['highlights']]
            : json['highlights'] ?? [],
      ),
      paragraphs: List<String>.from(
        json['paragraphs'] is String
            ? [json['paragraphs']]
            : json['paragraphs'] ?? [],
      ),
      relatedFireIds: [
        for (final id in (json['related_fire_ids'] as List? ?? const []))
          if (id != null) id.toString(),
      ],
    );
  }

  /// Whether this item was published within [window] of [now]. False when
  /// the date is missing or unparseable — "today's headline" must not be
  /// claimed for an item we cannot date.
  bool publishedWithin(Duration window, {DateTime? now}) {
    final published = DateTime.tryParse(publishedAt);
    if (published == null) return false;
    final age = (now ?? DateTime.now()).difference(published);
    return age <= window; // a future date (clock skew) counts as fresh
  }
}
