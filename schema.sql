PRAGMA foreign_keys = ON;
-- PRAGMA(プラグマ）＝SQLiteの設定命令
-- foreign_keys = 外部キーを有効にするスイッチ。これをONにしないと繋がりチェックが効かないことがある。
-- 既にある場合は消して作り直す（学習用に便利）
DROP TABLE IF EXISTS answers; --DROP TABLE=テーブルを削除。IF EXISTS=もし存在していたら（無ければ無視）
DROP TABLE IF EXISTS choices;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS respondents;
DROP TABLE IF EXISTS surveys;
-- テーブルを作る
CREATE TABLE surveys (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT
);
	-- •	id INTEGER PRIMARY KEY AUTOINCREMENT
	-- •	id = 識別番号（identifier）
	-- •	INTEGER = 整数
	-- •	PRIMARY KEY = 主キー（その行を一意に決める列）
	-- •	AUTOINCREMENT = 自動で 1,2,3… と増える
	-- •	title TEXT NOT NULL
	-- •	title = タイトル
	-- •	TEXT = 文字列
	-- •	NOT NULL = 空（NULL）禁止 → タイトルは必須
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  survey_id INTEGER NOT NULL,
  text TEXT NOT NULL,
  allow_other INTEGER NOT NULL DEFAULT 0, -- 0/1
  FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
);

CREATE TABLE choices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id INTEGER NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- 回答者はアンケートごとに作る（同一アンケで同一ニックネームを禁止）
CREATE TABLE respondents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  survey_id INTEGER NOT NULL,
  nickname TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  UNIQUE (survey_id, nickname)
);

-- 回答：選択肢(choice_id) か その他(other_text) のどちらか（両方は不可）
CREATE TABLE answers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  survey_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  respondent_id INTEGER NOT NULL,
  choice_id INTEGER,
  other_text TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),

  FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  FOREIGN KEY (respondent_id) REFERENCES respondents(id) ON DELETE CASCADE,
  FOREIGN KEY (choice_id) REFERENCES choices(id) ON DELETE CASCADE,

  -- 同じ人が同じ質問に2回答えるのを禁止（=1人1回の基本ユニット）
  UNIQUE (question_id, respondent_id),

  -- choice_id と other_text の両方が入るのを禁止＆両方空も禁止
  CHECK (
    (choice_id IS NOT NULL AND other_text IS NULL)
    OR
    (choice_id IS NULL AND other_text IS NOT NULL)
  )
);