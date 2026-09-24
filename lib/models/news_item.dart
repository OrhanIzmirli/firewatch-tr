class NewsItem {
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

  const NewsItem({
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
  });

  Map<String, dynamic> toJson() => {
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
      };

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
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
    );
  }
}
