# /troubleshoot - 体系的なデバッグ

**目的**: 問題の根本原因を特定し、エビデンスベースの解決策を提供

## 概要

`/troubleshoot`コマンドは、エラーや不具合を体系的に分析し、段階的な解決アプローチを提供します。

## 使用方法

```bash
/troubleshoot [オプション] [対象/エラーメッセージ]
```

## オプション

### --fix
問題の自動修正を試行：
- 一般的なエラーパターンの認識
- 安全な修正の自動適用
- 修正前後の動作確認
- ロールバック機能

### --prod
本番環境の問題に対応：
- 最小限の変更で修正
- ダウンタイムの最小化
- 緊急パッチの作成
- ロールバック計画の提供

### --deep
深い分析を実行：
- スタックトレースの完全解析
- 関連コードの調査
- 依存関係の追跡
- 過去の類似問題の検索

### --interactive
対話的なデバッグ：
- ステップバイステップの調査
- 仮説の検証
- 部分的な修正の試行
- フィードバックループ

## デバッグプロセス

### 1. 問題の特定
```yaml
症状の収集:
  - エラーメッセージ
  - 発生条件
  - 影響範囲
  - 再現手順
```

### 2. 原因分析
```yaml
分析手法:
  - スタックトレース解析
  - ログファイル調査
  - 環境差分の確認
  - タイミング問題の検証
```

### 3. 仮説立案
```yaml
仮説の優先順位:
  1. 最も可能性が高い原因
  2. 最も影響が大きい原因
  3. 最も修正が簡単な原因
```

### 4. 解決策の実装
```yaml
修正アプローチ:
  - 最小限の変更
  - 段階的な適用
  - 副作用の確認
  - テストの追加
```

## 一般的な問題パターン

### 型エラー
```python
# 問題
TypeError: unsupported operand type(s) for +: 'int' and 'str'
```

```yaml
# 診断
- 型の不一致を検出
- 変数の型を追跡
- 型変換の必要性を特定

# 解決策
- 明示的な型変換
- 型ヒントの追加
- バリデーションの実装
```

### インポートエラー
```python
# 問題
ModuleNotFoundError: No module named 'package_name'
```

```yaml
# 診断
- パッケージの存在確認
- インストール状態の確認
- パスの問題を調査

# 解決策
- uv add package_name
- PYTHONPATH の修正
- 仮想環境の確認
```

### パフォーマンス問題
```python
# 問題
API response time exceeds 1000ms
```

```yaml
# 診断
- ボトルネックの特定
- クエリの分析
- メモリ使用量の確認

# 解決策
- クエリの最適化
- キャッシングの実装
- 非同期処理の導入
```

## 実行例

### 基本的な使用
```bash
# エラーメッセージから診断
/troubleshoot "TypeError: 'NoneType' object is not subscriptable"

# 特定ファイルの問題を調査
/troubleshoot --deep src/auth/login.py

# 本番環境の緊急対応
/troubleshoot --prod --fix "500 Internal Server Error"
```

### 高度な使用
```bash
# 対話的デバッグセッション
/troubleshoot --interactive --deep

# パフォーマンス問題の調査
/troubleshoot "Slow query performance" --perf
```

## 出力形式

```yaml
診断レポート:
  問題: [エラーの概要]
  重大度: CRITICAL|HIGH|MEDIUM|LOW
  影響範囲: [影響を受ける機能]

根本原因:
  原因: [特定された原因]
  証拠: [原因を裏付けるデータ]
  場所: [ファイル:行番号]

解決策:
  推奨アプローチ: [最適な解決方法]
  実装手順:
    1. [具体的なステップ]
    2. [次のステップ]

  代替案:
    - [別の解決方法]
    - [回避策]

検証方法:
  - [修正を確認するテスト]
  - [回帰テスト]

予防策:
  - [同様の問題を防ぐ方法]
  - [監視の追加]
```

## デバッグ戦略

### Five Whys (なぜなぜ分析)
```yaml
症状: APIがタイムアウトする
なぜ1: レスポンスに5秒以上かかる
なぜ2: データベースクエリが遅い
なぜ3: インデックスが不足している
なぜ4: 大量データ投入時に作成されなかった
なぜ5: マイグレーションスクリプトの不備

根本原因: マイグレーションプロセスの改善が必要
```

### 二分探索デバッグ
```yaml
手法: 問題の範囲を半分ずつ絞り込む
1. 全体の中間点でテスト
2. 問題がある側を特定
3. その範囲の中間点でテスト
4. 問題箇所を特定するまで繰り返し
```

## 既存ツールとの連携

- `make test`: テストによる問題の再現
- `make typecheck`: 型関連の問題確認
- `uv run python -m pdb`: Pythonデバッガーの使用
- `git bisect`: 問題が導入されたコミットの特定

## ベストプラクティス

1. **証拠の収集**: 推測ではなくデータに基づく
2. **再現性の確保**: 問題を確実に再現できる手順を確立
3. **段階的アプローチ**: 大きな変更より小さな修正を積み重ねる
4. **テストの追加**: 修正と同時に回帰テストを作成
5. **ドキュメント化**: 問題と解決策を記録

## 注意事項

- `--fix`オプションは慎重に使用してください
- 本番環境では必ずバックアップを取得してから実行
- 原因が特定できない場合は、より詳細なログを有効化
- パフォーマンス問題は必ず計測してから対処
