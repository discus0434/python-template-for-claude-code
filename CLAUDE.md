---
title: CLAUDE.md
created_at: 2025-06-14
updated_at: 2025-06-26
# このプロパティは、Claude Codeが関連するドキュメントの更新を検知するために必要です。消去しないでください。
---

このファイルは、[Claude Code](https://www.anthropic.com/claude-code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクト概要

このプロジェクトは、Claude Codeでの開発に最適化されたPythonプロジェクトテンプレートです。
厳格な型チェック、自動化されたコード品質管理、CIに加えて、GitHub CLIを使用したGitHub操作をサポートします。
また、Claude Codeとの協働をサポートするためのドキュメントも提供します。

## 技術スタック

- **言語**: Python 3.12+
- **主要ツール**: uv (パッケージ管理), Ruff (リント・フォーマット), mypy (型チェック), pytest (テスト)
- **パッケージ管理**: uv
- **リンター/フォーマッター**: ruff
- **型チェッカー**: mypy (strict mode + PEP 695対応)
- **テストフレームワーク**: pytest + Hypothesis (プロパティベーステスト)
- **パフォーマンス**: pytest-benchmark (自動ベンチマーク)
- **自動化**: pre-commit, GitHub Actions

## プロジェクト全体の構造(デフォルト。必要に応じて更新してください)

```
project-root/
├── .github/                     # GitHub Actionsの設定ファイル
│   ├── workflows/               # CI/CD + ベンチマークワークフロー
│   │   ├── ci.yml               # メインCI（テスト・リント・型チェック）
│   │   └── benchmark.yml        # パフォーマンスベンチマーク
│   ├── dependabot.yml           # Dependabotの設定
│   ├── ISSUE_TEMPLATE/          # Issueテンプレート
│   └── PULL_REQUEST_TEMPLATE.md # Pull Requestテンプレート
├── template/                    # **重要**: Claude Codeのベストプラクティス・モデルコード
│   ├── src/
│   │   └── template_package/    # モデルパッケージの完全な実装例
│   │       ├── __init__.py      # パッケージエクスポートの例
│   │       ├── py.typed         # 型情報マーカーの例
│   │       ├── types.py         # 型定義のベストプラクティス
│   │       ├── core/
│   │       │   └── example.py   # クラス・関数実装の模範例
│   │       └── utils/
│   │           ├── helpers.py   # ユーティリティ関数の実装例
│   │           ├── logging_config.py # ロギング設定の実装例
│   │           └── profiling.py # パフォーマンス測定の実装例
│   └── tests/                   # テストコードの完全な実装例
│       ├── unit/                # 単体テスト
│       ├── property/            # プロパティベーステスト
│       ├── integration/         # 結合テスト
│       └── conftest.py          # pytestフィクスチャ
├── src/                         # 実際の開発用ディレクトリ
│       └── project_name/    # モデルパッケージの完全な実装例
│           └── （プロジェクト固有のパッケージを配置）
├── tests/                       # 実際のテスト用ディレクトリ
│   ├── unit/                    # 単体テスト
│   ├── property/                # プロパティベーステスト
│   ├── integration/             # 統合テスト
│   └── conftest.py              # pytest設定
├── docs/                        # ドキュメント
├── scripts/                     # ユーティリティスクリプト
├── pyproject.toml               # uv/ruff/mypyの設定ファイル
├── .gitignore                   # バージョン管理除外ファイル
├── .pre-commit-config.yaml      # pre-commitの設定ファイル
├── README.md                    # 人間向けのプロジェクトの説明
└── CLAUDE.md                    # このファイル
```

## 実装時の必須要件

**重要**: コードを書く際は、必ず以下のすべてを遵守してください：

### 0. 開発環境を確認して活用する

- 開発環境はuvで管理されています。すべてのPythonコマンドに `uv run` を前置し、新しい依存関係は `uv add` で追加してください。
- GitHub CLIがインストールされています。GitHub操作は `make pr` や `make issue` 、または `gh` コマンドを使用してください。
- pre-commitフックが設定されているほか、mypyやruff、pytestなどの厳格なガードレールが整備されています。こまめにmakeコマンドにあるチェックやフォーマットを実行し、コード品質を保証してください。
- 「よく使うコマンド」セクションにあるmakeコマンドとしたコマンド集は、この開発環境での開発を支援するためのコマンドが揃っています。積極的に活用してください。

### 1. コード品質を保証する

**コード品質保証のベストプラクティスは「コーディング規約」セクションを参照してください。**

コーディング後は必ず適切なmakeコマンドを実行してください。例えば、コーディング品質を保証するためのmakeコマンドは以下の通りです。

- `make format`: コードフォーマット
- `make lint`: リントチェック
- `make typecheck`: 型チェック（strict mode）
- `make test`: 全テスト実行
- まとめて実行: `make check-all`（format → lint → typecheck → test）

### 2. テストを実装する

**テスト実装のベストプラクティスは「テスト戦略」セクションを参照してください。**

新機能には必ず対応するテストを作成してください。

### 3. 適切なロギングを行う

**ロギングのベストプラクティスは「ロギング戦略」セクションを参照してください。**

このプロジェクトでは、すべてのコードに実行時のロギングを実装することを必須とします。これにより、開発・デバッグ時の問題追跡が容易になります。

### 4. パフォーマンスを測定する

**パフォーマンス測定のベストプラクティスは「パフォーマンス測定とベンチマーク」セクションを参照してください。**

重い処理を含む関数には適宜プロファイリングを実装し、パフォーマンスを測定することで実装のボトルネックが発見しやすいようにしてください。

### 5. 段階的実装アプローチを行う

- **インターフェース設計**: まずProtocolやABCでインターフェースを定義
- **テストファースト**: 実装前にテストを作成
- **段階的実装**: 最小限の実装→リファクタリング→最適化の順序

### 6. エビデンスベースで開発する

コード品質や性能に関する主張は、必ず測定可能な証拠に基づいて行ってください。

**禁止される曖昧な表現**:
- `best`, `optimal`, `faster`, `secure`, `better`, `improved`, `enhanced`, `always`, `never`, `guaranteed`, `perfect`, `flawless`

**推奨される具体的な表現**:
- `may`, `could`, `potentially`, `typically`, `often`, `sometimes`, `measured`, `documented`, `approximately`, `estimated`, `observed`, `reported`

**必須の証拠要件**:

1. **パフォーマンス**:
   - `benchmarks show`
   - `profiling indicates`
   - `measured at Xms`
   - `reduces time by X%`

2. **品質**:
   - `testing confirms`
   - `coverage increased to X%`
   - `complexity reduced from X to Y`
   - `metrics show`

3. **セキュリティ**:
   - `audit reveals`
   - `scan detected`
   - `OWASP compliant`
   - `CVE database shows`

4. **信頼性**:
   - `uptime of X%`
   - `error rate of X%`
   - `MTBF of X hours`
   - `recovery time of X seconds`

**エビデンスベースの主張テンプレート**:

```python
# パフォーマンスの主張
"Performance testing shows response time of 45ms, which is 25% lower than the baseline of 60ms"

# 品質の主張
"Code analysis reveals cyclomatic complexity of 5, indicating maintainable code structure"

# セキュリティの主張
"Security scan using bandit detected 0 issues, with no critical findings"
```

### 7. 開発効率化のためのテクニックを遵守する

#### コミュニケーション記法

開発の効率化のため、以下の記号体系を活用してください。

```yaml
記号体系:
  →: "leads to/flows to"  # 処理の流れ
  |: "separator/or"       # 区切り・選択
  &: "combine/and"        # 結合・並列
  :: "define/is"          # 定義
  »: "sequence/then"      # シーケンス
  @: "location/reference" # 場所・参照
```

例: `analyze→fix→test` = 分析してから修正し、その後テストする

#### 実行パターン

1. **並列処理** (独立したタスクは同時実行):
   - 適用条件: ファイル間の依存関係なし、リソース競合なし、順序依存なし
   - 例: 複数ファイルの読み込み、独立したテストの実行、並列ビルド

2. **バッチ処理** (類似操作をまとめて実行):
   - 適用条件: 同じ種類の操作、共通のリソース使用、効率化可能
   - 例: 複数ファイルのフォーマット、一括インポート修正、バッチテスト実行

3. **逐次処理** (順序を守って実行):
   - 適用条件: 依存関係あり、状態変更を伴う、トランザクション処理
   - 例: データベースマイグレーション、段階的リファクタリング、依存パッケージインストール

#### エラーリカバリー

1. **自動リトライ**:
   - 対象: 一時的なネットワークエラー、リソース競合、タイムアウト
   - 戦略: 指数バックオフ、最大3回まで、代替手段の試行

2. **フォールバック**:
   - パターン: primary（高速だが失敗する可能性）→ fallback（遅いが確実）
   - 例: 並列処理 → 逐次処理、キャッシュ → 再計算、最適化 → 基本実装

3. **状態復元**:
   - チェックポイント: 操作前の状態を保存、部分的な成功を記録、ロールバック可能
   - リカバリー: 最後の正常状態から再開、失敗した操作のみ再実行、代替アプローチの提案

#### 建設的フィードバックの提供

**フィードバックのトリガー**:
- 非効率なアプローチを検出
- セキュリティリスクを発見
- 過剰設計を認識
- 不適切な実践を確認

**アプローチ**:
- 直接的な表現 > 婉曲的な表現
- エビデンスベースの代替案 > 単なる批判
- 例: "より効率的な方法: X" | "セキュリティリスク: SQLインジェクション"

**条件分岐と並列ワークフロー**:
- 成功時: 次のステップへ自動進行
- 失敗時: エラーハンドリングとトラブルシューティング
- 警告時: 確認後続行またはスキップ
- 並列実行: セキュリティスキャン & 品質チェック & パフォーマンステスト

## `template/`ディレクトリにあるモデルケースの参照

`template/` ディレクトリには、Python開発のベストプラクティスを示すモデルコードが含まれています。実装時の参考として積極的に活用してください。

### モデルコード参照の推奨場面

1. **新しいクラスや関数を実装する際**
   - @template/src/project_name/core/example.py で適切な型ヒント、docstring、エラーハンドリングを確認
   - @template/src/project_name/types.py で型定義のパターンを確認

2. **ユーティリティ関数を作成する際**
   - @template/src/project_name/utils/helpers.py で関数の構造、エラー処理、ロギングを確認

3. **テストを書く際**
   - @template/tests/unit/ で単体テストの書き方を確認
   - @template/tests/property/ でプロパティベーステストの例を確認
   - @template/tests/conftest.py でフィクスチャの実装例を確認

4. **ロギングを実装する際**
   - @template/src/project_name/utils/logging_config.py で設定例を確認
   - 各モジュールでのロガー使用例を確認

新しいコードを書く際は、まず`template/`内の類似例を確認し、パターンを踏襲し、プロジェクト固有の要件に合わせて調整してください。
`template/`は削除せず、常に参照可能な状態を維持します。

## よく使うコマンド

### 基本的な開発コマンド（Makefile使用）

```bash
# 開発環境のセットアップ
make setup                  # 依存関係インストール + pre-commitフック設定など

# テスト実行
make test                   # 全テスト実行（単体・プロパティベース・統合）
make test-cov               # カバレッジ付きテスト実行
make test-unit              # 単体テストのみ実行
make test-property          # プロパティベーステストのみ実行

# コード品質チェック
make format                 # コードフォーマット
make lint                   # リントチェック（自動修正付き）
make typecheck              # 型チェック（strict mode）
make security               # セキュリティチェック（bandit）
make audit                  # 依存関係の脆弱性チェック（pip-audit）

# パフォーマンス測定
make benchmark              # ローカルベンチマーク実行

# 統合チェック
make check                  # format, lint, typecheck, testを順番に実行
make check-all              # pre-commitで全ファイルをチェック

# GitHub操作
make pr TITLE="タイトル" BODY="本文" [LABEL="ラベル"]      # PR作成（feature/masterブランチからは不可）
make pr-list                                                  # 開いているPRの一覧表示
make issue TITLE="タイトル" BODY="本文" [LABEL="ラベル"]   # イシュー作成
make issue-list                                               # 開いているイシューの一覧表示

# その他
make clean                  # キャッシュファイルの削除
make help                   # 利用可能なコマンド一覧

# 依存関係の追加
make sync                         # 全依存関係を同期
uv add package_name                # ランタイム依存関係
uv add --dev dev_package_name      # 開発依存関係
uv lock --upgrade                  # 依存関係を更新
```

## GitHubに関する規則

### ブランチ名の命名規則

- 機能追加: `feature/...`
- バグ修正: `fix/...`
- リファクタリング: `refactor/...`
- ドキュメント更新: `docs/...`
- テスト: `test/...`

### ラベル名の命名規則

- 機能追加: `enhancement`
- バグ修正: `bug`
- リファクタリング: `refactor`
- ドキュメント更新: `documentation`
- テスト: `test`

## コーディング規約

### ディレクトリ構成

パッケージとテストは `template/` 内の構造を踏襲します。コアロジックは必ず `src/project_name` 内に配置してください。

```
src/
├── project_name/
│   ├── core/
│   ├── utils/
│   ├── __init__.py
│   └── ...
├── tests/
│   ├── unit/
│   ├── property/
│   ├── integration/
│   └── conftest.py
├── docs/
...
```

### Python コーディングスタイル

- **型ヒント**: Python 3.12+ の型ヒントを必ず使用（mypy strict mode + PEP 695準拠）
- **Docstring**: NumPy形式のDocstringを使用
- **命名規則**:
  - クラス: PascalCase
  - 関数/変数: snake_case
  - 定数: UPPER_SNAKE_CASE
  - プライベート: 先頭に `_`
- **インポート順序**: 標準ライブラリ → サードパーティ → ローカル（ruffが自動整理）

### 型ヒントのベストプラクティス

@template/src/template_package/types.py を参照してください。

### エラーメッセージの原則

#### 1. 具体的で実用的
```python
# Bad
raise ValueError("Invalid input")

# Good
raise ValueError(
    f"Expected positive integer for 'count', got {count}. "
    f"Please provide a value greater than 0."
)
```

#### 2. コンテキストを提供
```python
try:
    result = process_data(data)
except ProcessingError as e:
    raise ProcessingError(
        f"Failed to process data from {source_file}: {e}"
    ) from e
```

#### 3. 解決策を提示
```python
if not config_file.exists():
    raise FileNotFoundError(
        f"Configuration file not found at {config_file}. "
        f"Create one by running: python -m {__package__}.init_config"
    )
```

### アンカーコメント

疑問点や改善点がある場合は、アンカーコメントを活用してください。

```python
# AIDEV-NOTE: このクラスは外部APIとの統合専用
# AIDEV-TODO: パフォーマンス最適化が必要（レスポンス時間>500ms）
# AIDEV-QUESTION: この実装でメモリリークの可能性は？
```

## テスト戦略

**t-wada流のテスト駆動開発（TDD）を徹底してください。**

### TDD （t-wada流）

#### 基本方針

- 🔴 Red: 失敗するテストを書く
- 🟢 Green: テストを通す最小限の実装
- 🔵 Refactor: リファクタリング
- 小さなステップで進める
- 仮実装（ベタ書き）から始める
- 三角測量で一般化する
- 明白な実装が分かる場合は直接実装してもOK
- テストリストを常に更新する
- 不安なところからテストを書く

#### TDDの実施手順

1. **TODOリストの作成**
   ```
   [ ] 実装したい機能をリストアップ
   [ ] 不安な部分、エッジケースも追加
   [ ] 最小単位に分解
   ```

2. **Red フェーズ**
   ```python
   # 1. 失敗するテストを書く
   def test_新機能が期待通り動作する():
       result = new_function(input_data)
       assert result == expected_output  # まだ実装していないので失敗
   ```

3. **Green フェーズ**
   ```python
   # 2. テストを通す最小限の実装
   def new_function(input_data):
       return expected_output  # 仮実装（ベタ書き）
   ```

4. **Refactor フェーズ**
   ```python
   # 3. リファクタリング（テストが通ることを確認しながら）
   def new_function(input_data):
       # 実際のロジックに置き換える
       processed = process_data(input_data)
       return format_output(processed)
   ```

#### 三角測量の例

```python
# Step 1: 最初のテスト（ベタ書きで通す）
def test_add_正の数():
    assert add(2, 3) == 5

def add(a, b):
    return 5  # 仮実装

# Step 2: 2つ目のテスト（一般化を促す）
def test_add_別の正の数():
    assert add(1, 4) == 5
    assert add(10, 20) == 30  # これで仮実装では通らない

def add(a, b):
    return a + b  # 一般化

# Step 3: エッジケースを追加
def test_add_負の数():
    assert add(-1, -2) == -3
    assert add(-5, 3) == -2
```

#### TDD実践時の注意点

1. **テストは1つずつ追加**
   - 一度に複数のテストを書かない
   - 各テストが失敗することを確認してから実装

2. **コミットのタイミング**
   - Red → Green: テストが通ったらコミット
   - Refactor: リファクタリング完了でコミット
   - 小さく頻繁にコミットする

3. **テストの粒度**
   - 最小単位でテストを書く
   - 1つのテストで1つの振る舞いをテスト
   - テスト名は日本語で意図を明確に

4. **リファクタリングの判断**
   - 重複コードがある
   - 可読性が低い
   - 設計原則（SOLID等）に違反
   - パフォーマンスの問題（測定してから）

5. **テストファーストの実践**
   - 必ず失敗するテストから書く
   - `make test`で失敗を確認
   - 最小限の実装でテストを通す

6. **段階的な実装**
   - TODOリストを1つずつ消化
   - 各ステップでテストが通ることを確認
   - リファクタリング時もテストを実行

### TDDサイクルの記録

実装時は以下のフォーマットでTDDサイクルを記録してください：

```markdown
## 機能: ユーザー認証システム

### TODOリスト
- [x] ユーザー名とパスワードで認証できる
- [x] 不正な認証情報でエラーを返す
- [ ] パスワードのハッシュ化
- [ ] セッション管理
- [ ] ログアウト機能

### サイクル1: 基本的な認証
🔴 Red: test_正常系_有効な認証情報でTrue()
🟢 Green: return True（仮実装）
🔵 Refactor: 実際の認証ロジックを実装

### サイクル2: エラーハンドリング
🔴 Red: test_異常系_無効な認証情報でFalse()
🟢 Green: if文で条件分岐
🔵 Refactor: エラーメッセージの改善
```

詳細は `template/tests/` にある実装を適宜参照してください。

### テストの種類

1. **単体テスト** ( @template/tests/unit/test_example.py などを参照 )
   - 関数・クラスの基本動作をテスト
   - 正常系・異常系・エッジケースもカバーする

2. **プロパティベーステスト** ( @template/tests/property/test_helpers_property.py などを参照 )
   - Hypothesisで様々な入力パターンを自動生成してテスト

3. **統合テスト** ( @template/tests/integration/test_example.py などを参照 )
   - コンポーネント間の連携

### テスト命名規約

```python
# 日本語で意図を明確に
def test_正常系_有効なデータで処理成功():
    """chunk_listが正しくチャンク化できることを確認。"""

 def test_異常系_不正なサイズでValueError():
    """チャンクサイズが0以下の場合、ValueErrorが発生することを確認。"""

def test_エッジケース_空リストで空結果():
    """空のリストをチャンク化すると空の結果が返されることを確認。"""
```

## ロギング戦略

### ロギング実装の必須要件

**TL;DR**

1. **各モジュールの冒頭で必ずロガーを実装**
2. **関数・メソッドの開始と終了時にログを出力**
3. **エラー処理時にログを出力し、exc_info=Trueを付けることでエラーの原因を追跡できるようにする**
4. **ログレベルの使い分け**
    - **DEBUG**: 詳細な実行フロー、引数、戻り値
    - **INFO**: 重要な処理の完了、状態変更
    - **WARNING**: 異常ではないが注意が必要な状況
    - **ERROR**: エラー発生時（必ずexc_info=Trueを付ける）

詳細は @template/src/template_package/utils/logging_config.py や @template/src/template_package/core/example.py にある実装を適宜参照してください。

### 開発時のロギング設定

```python
# コード実装時は必ずINFOモード、デバッグ時はDEBUGモードで開発
from project_name import setup_logging
setup_logging(level="INFO")

# または環境変数で設定
export LOG_LEVEL=INFO
```

### テスト時の設定

```python
# テスト実行時のログレベル制御
export TEST_LOG_LEVEL=INFO  # デフォルトはDEBUG

# 個別のテストでログレベルを変更
def test_with_custom_log_level(set_test_log_level):
    set_test_log_level("WARNING")
    # テスト実行
```

## パフォーマンス測定とベンチマーク

以下に適切なパフォーマンス測定の例を示します。
詳細は @template/src/template_package/utils/profiling.py を参照してください。

```python
from project_name.utils.profiling import profile, timeit, Timer, profile_context

# 関数デコレーター
@profile
def heavy_computation():
    return sum(i**2 for i in range(10000))

@timeit
def quick_function():
    return [i for i in range(1000)]

# コンテキストマネージャー
with Timer("Custom operation") as timer:
    result = process_large_dataset()
print(f"Took {timer.elapsed:.4f} seconds")

# 詳細プロファイリング
with profile_context(sort_by="cumulative", limit=10) as prof:
    complex_operation()
```

## CLAUDE.md自動更新トリガー

**重要**: 以下の状況でCLAUDE.mdの更新を検討してください：

### 変更ベースのトリガー
- 仕様の追加・変更があった場合
- 新しい依存関係の追加時
- プロジェクト構造の変更
- コーディング規約の更新

### 頻度ベースのトリガー

- **同じ質問が2回以上発生** → 即座にFAQとして追加
- **新しいエラーパターンを2回以上確認** → トラブルシューティングに追加

## トラブルシューティング

### pre-commitが失敗する場合

```bash
# キャッシュをクリア
uv run pre-commit clean
uv run pre-commit gc

# 再インストール
uv run pre-commit uninstall
uv run pre-commit install
```

### テスト失敗の調査

```bash
# 失敗したテストの詳細確認
make test-unit PYTEST_ARGS="-vvs -k test_name"

# デバッグモードで実行
export LOG_LEVEL=DEBUG
make test

# カバレッジ確認
make test-cov
```

### ...随時追記してください...

## FAQ

### Q: `make pr` が "Cannot create PR from main/master branch" エラーになる

新しいブランチを作成してから実行してください：
```bash
git checkout -b feature/your-feature-name
# 変更をコミット
git add .
git commit -m "Your commit message"
# PRを作成
make pr TITLE="PR Title" BODY="PR Description"
```

### Q: `make issue` が認証エラーになる

GitHub CLIの認証が必要です：
```bash
gh auth login
# ブラウザまたはトークンで認証を完了させてください
```

### ...随時追記してください...

## 詳細ガイドの参照

### カスタムガイドの追加

プロジェクト固有の要件に応じて、追加のカスタムガイドを`docs/` ディレクトリに作成できます。
例: フロントエンドプロジェクトのガイド(`docs/frontend-project-guide.md`), チーム固有のルール(`docs/team-specific-guide.md`)など
カスタムガイドを追加した場合は、必ずこのCLAUDE.mdにその概要を追加してください。
