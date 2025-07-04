.PHONY: help test test-cov test-unit test-property test-integration format lint typecheck security audit check check-all benchmark profile setup pr issue pr-list issue-list clean

# デフォルトターゲット
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@echo "  setup        - セットアップ（依存関係インストール、pre-commit設定）"
	@echo "  sync         - 全依存関係を同期"
	@echo "  test         - 全テスト実行（単体・プロパティ・統合）"
	@echo "  test-cov     - カバレッジ付きテスト実行"
	@echo "  test-unit    - 単体テストのみ実行"
	@echo "  test-property - プロパティベーステストのみ実行"
	@echo "  test-integration - 統合テストのみ実行"
	@echo "  format       - コードフォーマット（ruff format）"
	@echo "  lint         - リントチェック（ruff check --fix）"
	@echo "  typecheck    - 型チェック（mypy）"
	@echo "  security     - セキュリティチェック（bandit）"
	@echo "  audit        - 依存関係の脆弱性チェック（pip-audit）"
	@echo "  benchmark    - パフォーマンスベンチマーク実行"
	@echo "  check        - format, lint, typecheck, testを順番に実行"
	@echo "  check-all    - pre-commitで全ファイルをチェック"
	@echo "  pr           - PR作成 (TITLE=\"タイトル\" BODY=\"本文またはファイルパス\" [LABEL=\"ラベル\"])"
	@echo "  pr-list      - 開いているPRの一覧表示"
	@echo "  issue        - イシュー作成 (TITLE=\"タイトル\" BODY=\"本文またはファイルパス\" [LABEL=\"ラベル\"])"
	@echo "  issue-list   - 開いているイシューの一覧表示"
	@echo "  clean        - キャッシュファイルの削除"

# セットアップ
setup:
	chmod +x scripts/setup.sh && ./scripts/setup.sh

sync:
	uv sync --all-extras

# テスト関連
test:
	uv run pytest

test-cov:
	uv run pytest --cov=src --cov-report=html --cov-report=term

test-unit:
	uv run pytest tests/unit/ -v

test-property:
	uv run pytest tests/property/ -v

test-integration:
	uv run pytest tests/integration/ -v

# コード品質チェック
format:
	uv run ruff format . --config=pyproject.toml

lint:
	uv run ruff check . --fix --config=pyproject.toml

typecheck:
	uv run mypy src/ --strict

security:
	uv run bandit -r src/

audit:
	uv run pip-audit

# パフォーマンス測定
benchmark:
	@echo "Running performance benchmarks..."
	@if [ -f benchmark_suite.py ]; then \
		uv run pytest benchmark_suite.py --benchmark-only --benchmark-autosave; \
	else \
		echo "Creating benchmark suite..."; \
		echo 'import pytest\nfrom project_name.utils.helpers import chunk_list\n\ndef test_chunk_list_benchmark(benchmark):\n    data = list(range(1000))\n    result = benchmark(chunk_list, data, 10)\n    assert len(result) == 100' > benchmark_suite.py; \
		uv add --dev pytest-benchmark; \
		uv run pytest benchmark_suite.py --benchmark-only --benchmark-autosave; \
	fi

# 統合チェック
check: format lint typecheck test

check-all:
	uv run pre-commit run --all-files

# GitHub操作
pr:
	@if [ -z "$(TITLE)" ]; then \
		echo "Error: TITLE is required. Usage: make pr TITLE=\"タイトル\" BODY=\"本文\" [LABEL=\"ラベル\"]"; \
		exit 1; \
	fi
	@if [ -z "$(BODY)" ]; then \
		echo "Error: BODY is required. Usage: make pr TITLE=\"タイトル\" BODY=\"本文\" [LABEL=\"ラベル\"]"; \
		exit 1; \
	fi
	@# 現在のブランチを確認
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT_BRANCH" = "main" ] || [ "$$CURRENT_BRANCH" = "master" ]; then \
		echo "Error: Cannot create PR from main/master branch."; \
		echo "Please create a new branch first:"; \
		echo "  git checkout -b feature/your-feature-name"; \
		exit 1; \
	fi
	@# 変更がステージングされているか確認
	@if ! git diff --cached --quiet; then \
		echo "Warning: You have staged changes. Consider committing them first."; \
	fi
	@# 変更がコミットされていない場合の警告
	@if ! git diff --quiet; then \
		echo "Warning: You have uncommitted changes."; \
	fi
	@# ファイルを使って本文を渡すか、簡単な本文の場合は直接渡す
	@if [ -f "$(BODY)" ]; then \
		echo "Using file content for PR body: $(BODY)"; \
		if [ -n "$(LABEL)" ]; then \
			gh pr create --title "$(TITLE)" --body-file "$(BODY)" --label "$(LABEL)"; \
		else \
			gh pr create --title "$(TITLE)" --body-file "$(BODY)"; \
		fi; \
	else \
		if [ -n "$(LABEL)" ]; then \
			gh pr create --title "$(TITLE)" --body "$(BODY)" --label "$(LABEL)"; \
		else \
			gh pr create --title "$(TITLE)" --body "$(BODY)"; \
		fi; \
	fi

issue:
	@if [ -z "$(TITLE)" ]; then \
		echo "Error: TITLE is required. Usage: make issue TITLE=\"タイトル\" BODY=\"本文\" [LABEL=\"ラベル\"]"; \
		exit 1; \
	fi
	@if [ -z "$(BODY)" ]; then \
		echo "Error: BODY is required. Usage: make issue TITLE=\"タイトル\" BODY=\"本文\" [LABEL=\"ラベル\"]"; \
		exit 1; \
	fi
	@# GitHub CLI が利用可能か確認
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "Error: GitHub CLI (gh) is not installed."; \
		echo "Please install it first: https://cli.github.com/"; \
		exit 1; \
	fi
	@# 認証状態を確認
	@if ! gh auth status >/dev/null 2>&1; then \
		echo "Error: Not authenticated with GitHub."; \
		echo "Please run: gh auth login"; \
		exit 1; \
	fi
	@# ファイルを使って本文を渡すか、簡単な本文の場合は直接渡す
	@if [ -f "$(BODY)" ]; then \
		echo "Using file content for issue body: $(BODY)"; \
		if [ -n "$(LABEL)" ]; then \
			gh issue create --title "$(TITLE)" --body-file "$(BODY)" --label "$(LABEL)"; \
		else \
			gh issue create --title "$(TITLE)" --body-file "$(BODY)"; \
		fi; \
	else \
		if [ -n "$(LABEL)" ]; then \
			gh issue create --title "$(TITLE)" --body "$(BODY)" --label "$(LABEL)"; \
		else \
			gh issue create --title "$(TITLE)" --body "$(BODY)"; \
		fi; \
	fi

# PRとイシューの一覧表示
pr-list:
	@echo "=== Open Pull Requests ==="
	@gh pr list --state open || echo "No open pull requests found."

issue-list:
	@echo "=== Open Issues ==="
	@gh issue list --state open || echo "No open issues found."

# クリーンアップ
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".mypy_cache" -exec rm -rf {} +
	find . -type d -name ".ruff_cache" -exec rm -rf {} +
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type f -name ".coverage" -delete
