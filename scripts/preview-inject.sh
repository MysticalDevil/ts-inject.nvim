#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANG=""
INJECT="sql"
JUMP_LINE=""
LIST=0

# ---------------------------------------------------------------------------
# Fixture mapping
# ---------------------------------------------------------------------------
declare -A FIXTURES=(
	[c]="basic.c"
	[cpp]="basic.cpp"
	[cs]="basic.cs"
	[csharp]="basic.cs"
	[elixir]="basic.ex"
	[ex]="basic.ex"
	[go]="basic.go"
	[java]="basic.java"
	[javascript]="basic.js"
	[js]="basic.js"
	[kotlin]="basic.kt"
	[kt]="basic.kt"
	[lua]="basic.lua"
	[perl]="basic.pl"
	[php]="basic.php"
	[pl]="basic.pl"
	[python]="basic.py"
	[py]="basic.py"
	[ruby]="basic.rb"
	[rust]="basic.rs"
	[rs]="basic.rs"
	[scala]="basic.scala"
	[sh]="basic.sh"
	[bash]="basic.sh"
	[typescript]="basic.ts"
	[ts]="basic.ts"
	[xml]="basic.xml"
	[zig]="basic.zig"
)

# ---------------------------------------------------------------------------
# Preset jump positions for interesting injection regions
# ---------------------------------------------------------------------------
declare -A JUMP_LINES=(
	["c:asm"]="113"
	["c:sql"]="119"
	["go:graphql"]="27"
	["go:sql"]="15"
	["java:sql"]="75"
	["javascript:graphql"]="71"
	["javascript:sql"]="60"
	["python:graphql"]="51"
	["python:sql"]="36"
	["rust:graphql"]="65"
	["rust:sql"]="3"
	["typescript:graphql"]="71"
	["typescript:sql"]="60"
)

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
	cat << 'HELP'
Usage: preview-inject.sh [OPTIONS]

Preview Tree-sitter injection highlights in ts-inject.nvim fixture files.

Options:
  -l, --lang <host>       Host language to open (required unless --list)
  -i, --inject <lang>     Target injection language (default: sql)
  --line <n>              Override auto-detected jump line
  --list                  List available languages and injection types
  -h, --help              Show this help

Examples:
  preview-inject.sh --lang rust
  preview-inject.sh --lang javascript --inject graphql
  preview-inject.sh --lang ts --inject sql --line 80
  preview-inject.sh --list
HELP
}

list_languages() {
	printf "${BLUE}Available languages:${NC}\n"
	for key in "${!FIXTURES[@]}"; do
		printf "  %-12s -> %s\n" "$key" "${FIXTURES[$key]}"
	done | sort

	printf "\n${BLUE}Supported injection types:${NC}\n"
	printf "  sql, graphql, asm\n"

	printf "\n${BLUE}Preset jump lines:${NC}\n"
	for key in "${!JUMP_LINES[@]}"; do
		printf "  %-28s -> line %s\n" "$key" "${JUMP_LINES[$key]}"
	done | sort
}

resolve_lang() {
	local input="$1"
	local canonical=""

	# Exact match
	if [[ -n "${FIXTURES[$input]+x}" ]]; then
		canonical="$input"
	fi

	# Try lowercase
	if [[ -z "$canonical" ]]; then
		local lower="${input,,}"
		if [[ -n "${FIXTURES[$lower]+x}" ]]; then
			canonical="$lower"
		fi
	fi

	echo "$canonical"
}

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
	case "$1" in
		-l|--lang)
			LANG="$2"
			shift 2
			;;
		-i|--inject)
			INJECT="$2"
			shift 2
			;;
		--line)
			JUMP_LINE="$2"
			shift 2
			;;
		--list)
			LIST=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo -e "${RED}Unknown option: $1${NC}"
			echo "Use -h for help"
			exit 1
			;;
	esac
done

if [[ "$LIST" -eq 1 ]]; then
	list_languages
	exit 0
fi

if [[ -z "$LANG" ]]; then
	echo -e "${RED}Error: --lang is required${NC}"
	echo "Use --list to see available languages, or -h for help"
	exit 1
fi

CANONICAL=$(resolve_lang "$LANG")

if [[ -z "$CANONICAL" ]]; then
	echo -e "${RED}Unknown language: $LANG${NC}"
	echo "Use --list to see available languages"
	exit 1
fi

FILE="$PROJECT_ROOT/tests/fixtures/${FIXTURES[$CANONICAL]}"

if [[ ! -f "$FILE" ]]; then
	echo -e "${RED}Fixture not found: $FILE${NC}"
	exit 1
fi

# ---------------------------------------------------------------------------
# Determine jump line
# ---------------------------------------------------------------------------
if [[ -z "$JUMP_LINE" ]]; then
	KEY="${CANONICAL}:${INJECT}"
	JUMP_LINE="${JUMP_LINES[$KEY]-}"
fi

# ---------------------------------------------------------------------------
# Check parser availability and offer to install
# ---------------------------------------------------------------------------
check_parser() {
	local p="$1"
	local ok
	ok=$(nvim --headless -u NONE -i NONE \
		--cmd "lua ok = pcall(vim.treesitter.language.add, '$p'); print(ok and 'OK' or 'MISSING')" \
		--cmd 'qa!' 2>&1)
	if [[ "$ok" != "OK" ]]; then
		echo -e "${YELLOW}Warning: Tree-sitter parser '$p' is not installed.${NC}"
		if command -v nvim &>/dev/null && nvim --headless -c 'lua print(pcall(require, "tree-sitter-manager"))' -c 'qa!' 2>&1 | grep -q true; then
			echo -e "  Run: ${BLUE}:TSMInstall $p${NC}"
		else
			echo -e "  Install the '$p' parser (e.g. via nvim-treesitter or tree-sitter-manager)"
		fi
	fi
}

check_parser "$CANONICAL"
check_parser "$INJECT"

# ---------------------------------------------------------------------------
# Launch
# ---------------------------------------------------------------------------
echo -e "${GREEN}Opening${NC} $FILE"
echo -e "  host:      ${BLUE}$CANONICAL${NC}"
echo -e "  inject:    ${BLUE}$INJECT${NC}"
[[ -n "$JUMP_LINE" ]] && echo -e "  jump:      ${BLUE}line $JUMP_LINE${NC}"

setup_lua="vim.opt.runtimepath:prepend('$PROJECT_ROOT'); for k in pairs(package.loaded) do if k:match('^ts_inject') then package.loaded[k] = nil end end; require('ts_inject').setup({ enable = { ['$CANONICAL'] = true } }); vim.cmd('edit')"

if [[ -n "$JUMP_LINE" ]]; then
	exec nvim "$FILE" \
		-c "lua $setup_lua" \
		-c "TSInjectDebug $INJECT" \
		-c "normal! ${JUMP_LINE}G"
else
	exec nvim "$FILE" \
		-c "lua $setup_lua" \
		-c "TSInjectDebug $INJECT"
fi
