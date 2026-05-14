import 'package:sqflite/sqflite.dart';

final class RssDbPersistence {
  const RssDbPersistence._();

  static Future<void> ensureTables(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS rss_feeds (
  id TEXT PRIMARY KEY,
  feed_url TEXT NOT NULL UNIQUE,
  site_url TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  icon_url TEXT NOT NULL DEFAULT '',
  etag TEXT NOT NULL DEFAULT '',
  last_modified TEXT NOT NULL DEFAULT '',
  last_fetch_time INTEGER,
  last_success_time INTEGER,
  last_error TEXT,
  created_time INTEGER NOT NULL,
  updated_time INTEGER NOT NULL
);
''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS rss_articles (
  id TEXT PRIMARY KEY,
  feed_id TEXT NOT NULL,
  guid TEXT NOT NULL DEFAULT '',
  link TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  author TEXT NOT NULL DEFAULT '',
  summary_html TEXT NOT NULL DEFAULT '',
  content_html TEXT NOT NULL DEFAULT '',
  lead_image_url TEXT NOT NULL DEFAULT '',
  published_time INTEGER,
  fetched_time INTEGER NOT NULL,
  read_state TEXT NOT NULL DEFAULT 'unread',
  saved_memo_uid TEXT,
  created_time INTEGER NOT NULL,
  updated_time INTEGER NOT NULL,
  FOREIGN KEY (feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (saved_memo_uid) REFERENCES memos(uid) ON DELETE SET NULL ON UPDATE CASCADE
);
''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS collection_rss_sources (
  collection_id TEXT NOT NULL,
  feed_id TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_time INTEGER NOT NULL,
  updated_time INTEGER NOT NULL,
  PRIMARY KEY (collection_id, feed_id),
  FOREIGN KEY (collection_id) REFERENCES memo_collections(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (feed_id) REFERENCES rss_feeds(id) ON DELETE CASCADE ON UPDATE CASCADE
);
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rss_feeds_feed_url ON rss_feeds(feed_url);',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_rss_articles_feed_guid ON rss_articles(feed_id, guid) WHERE guid <> \'\';',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_rss_articles_feed_link ON rss_articles(feed_id, link) WHERE link <> \'\';',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rss_articles_feed_time ON rss_articles(feed_id, published_time DESC, fetched_time DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_rss_articles_read_state ON rss_articles(read_state, updated_time DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_collection_rss_sources_collection_order ON collection_rss_sources(collection_id, sort_order ASC, created_time ASC);',
    );
  }
}
