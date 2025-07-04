#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
PYTHON_VERSION="3.12"

# Detect shell and set rc_file
rc_file="~/.bashrc"
if [[ "$SHELL" == "/bin/zsh" ]]; then
    rc_file=~/.zshrc
elif [[ "$SHELL" == "/bin/bash" ]]; then
    rc_file=~/.bashrc
elif [[ "$SHELL" == "/bin/fish" ]]; then
    rc_file=~/.config/fish/config.fish
else
    print_error "Failed to detect shell. Please set rc_file manually."
fi

# Functions
print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if uv is installed
check_uv() {
    if ! command -v uv &> /dev/null; then
        print_error "uv is not installed."
        echo "Install it with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
}

check_npm() {
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed."
        # if macos, use nodebrew
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_step "Use nodebrew to install Node.js"
            if ! command -v nodebrew &> /dev/null; then
                print_step "Install nodebrew"
                brew install nodebrew
                echo "export PATH=$HOME/.nodebrew/current/bin:$PATH" >> $rc_file
                source $rc_file
            fi
            nodebrew install stable
            nodebrew use stable
            print_success "Node.js installed"
        elif [[ "$OSTYPE" == "linux"* ]]; then
            print_step "Use n to install Node.js"
            if ! command -v n &> /dev/null; then
                print_step "Install n"
                sudo apt update
                sudo apt install -y nodejs npm
                sudo npm install n -g
                n stable
                sudo apt purge -y nodejs npm
                sudo apt autoremove -y
            fi
            n stable
            print_success "Node.js installed"
        else
            print_error "Unsupported OS. Please install Node.js manually."
        fi
        exit 1
    fi
}

check_github_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "gh is not installed."
        print_step "Install gh"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install gh
            gh auth login
        elif [[ "$OSTYPE" == "linux"* ]]; then
            type -p curl >/dev/null || sudo apt install curl -y
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y \
            && gh auth login
        fi
        print_success "gh installed"
    fi
}

check_play_command() {
    if ! command -v play &> /dev/null; then
        print_warning "play command is not available. Installing sox for Claude Code hooks..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_step "Installing sox on macOS..."
            brew install sox
        elif [[ "$OSTYPE" == "linux"* ]]; then
            print_step "Installing sox on Linux..."
            sudo apt update
            sudo apt install -y sox
        else
            print_warning "Unsupported OS for sox installation. Please install sox manually for Claude Code hooks."
            return
        fi
        if command -v play &> /dev/null; then
            print_success "play command installed successfully"
        else
            print_warning "Failed to install play command. Claude Code hooks may not work properly."
        fi
    else
        print_success "play command already available"
    fi
}

check_claude_code() {
    print_step "Installing Claude Code..."
    npm i -g @anthropic-ai/claude-code
    print_success "Claude Code installed"
    print_step "Checking Claude Code..."
    claude --version
    print_success "Claude Code checked"
}

check_gemini_cli() {
    print_step "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    print_success "Gemini CLI installed"
    print_step "Checking Gemini CLI..."
    gemini --version
    print_success "Gemini CLI checked"
}

# Get project name from user
get_project_name() {
    echo "Current directory: $(pwd)"
    echo -n "Enter your project name (default: $DEFAULT_PROJECT_NAME): "
    read -r PROJECT_NAME

    if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME=$DEFAULT_PROJECT_NAME
    fi

    # Validate project name (Python package naming rules)
    if ! echo "$PROJECT_NAME" | grep -qE '^[a-z][a-z0-9_]*$'; then
        print_error "Invalid project name. Use lowercase letters, numbers, and underscores only."
        print_error "Must start with a letter."
        exit 1
    fi

    echo "Project name: $PROJECT_NAME"
}

# Update project name in all files
update_project_name() {
    print_step "Updating project name to '$PROJECT_NAME'..."

    # Use the Python script if it exists
    if [ -f "scripts/update_project_name.py" ]; then
        python scripts/update_project_name.py "$PROJECT_NAME"
    else
        # Fallback to manual replacement
        # Update in specific files
        for file in pyproject.toml README.md; do
            if [ -f "$file" ]; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    sed -i '' "s/project_name/$PROJECT_NAME/g" "$file"
                    sed -i '' "s/project-name/${PROJECT_NAME//_/-}/g" "$file"
                else
                    # Linux
                    sed -i "s/project_name/$PROJECT_NAME/g" "$file"
                    sed -i "s/project-name/${PROJECT_NAME//_/-}/g" "$file"
                fi
            fi
        done

        # Rename directory
        if [ -d "src/project_name" ]; then
            mv "src/project_name" "src/$PROJECT_NAME"
        fi
    fi

    print_success "Project name updated"
}

# Setup Python environment
setup_python() {
    print_step "Setting up Python environment..."

    # Pin Python version
    uv python pin $PYTHON_VERSION
    print_success "Python $PYTHON_VERSION pinned"

    # Install dependencies
    print_step "Installing dependencies..."
    uv sync --all-extras
    print_success "Dependencies installed"
}

# Setup pre-commit
setup_precommit() {
    print_step "Setting up pre-commit hooks..."

    uv run pre-commit install
    uv run pre-commit install --hook-type commit-msg

    # Run pre-commit on all files to ensure everything is set up
    print_step "Running initial pre-commit checks..."
    uv run pre-commit run --all-files || true

    print_success "Pre-commit hooks installed"
}

# Initialize git if needed
init_git() {
    if [ ! -d ".git" ]; then
        print_step "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit from python-claude-template"
        print_success "Git repository initialized"
    else
        print_success "Git repository already exists"
    fi
}

# Run initial tests
run_tests() {
    print_step "Running initial tests..."

    if uv run pytest tests/ -v; then
        print_success "All tests passed!"
    else
        print_warning "Some tests failed. This is expected for a new project."
    fi
}

# Main setup flow
main() {
    echo "🚀 Python Claude Template Setup"
    echo "==============================="
    echo

    # Check prerequisites
    check_uv
    check_npm
    check_claude_code
    check_gemini_cli
    check_github_cli
    check_play_command

    # Rename project if needed
    if [ -d "src/project_name" ]; then
        get_project_name
        echo
        update_project_name
    fi

    # Perform setup
    setup_python
    setup_precommit
    init_git
    run_tests

    echo
    echo "✨ Setup complete!"
    echo
    echo "Next steps:"
    echo "1. Authorize Claude Code and Gemini CLI"
    echo "2. Initialize project via `/initialize-project` via Claude Code"
    echo "3. Set up branch protection (optional):"
    echo "   gh repo view --web  # Open in browser to configure"
    echo "4. Start coding! 🎉"
    echo
    echo "Useful commands:"
    echo "  make test              # Run tests"
    echo "  make format            # Format code"
    echo "  make lint              # Lint code"
    echo "  make typecheck         # Type check"
    echo "  make check             # Run all checks"
    echo "  make help              # Show all available commands"
    echo "  uv add <package>       # Add a dependency"
    echo "  make pr                # Create pull request"
    echo "  make issue-bug         # Create bug report"
    echo "  make issue-feature     # Create feature request"
    echo "  make issue-claude      # Create Claude Code collaboration issue"
    echo "  make issue             # Create issue (template selection)"
    echo
}

# Run main function
main
