# shellcheck shell=bash
# Claude Code rate-limit usage: 5-hour and 7-day windows.
#
# Reads the cache that ~/.claude/abtop-statusline.sh writes on every status-line
# render, so this costs no API call and stays fresh while a Claude session runs.
# Claude Code hands the status line a `rate_limits` object; that script persists it.

TMUX_POWERLINE_SEG_CLAUDE_USAGE_DATA_FILE_DEFAULT="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/abtop-rate-limits.json"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_SYMBOL_DEFAULT="✳"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_DEFAULT="50"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_DEFAULT="80"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_OK_COLOUR_DEFAULT="114"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_COLOUR_DEFAULT="221"
TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_COLOUR_DEFAULT="203"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Where the rate-limit cache lives.
export TMUX_POWERLINE_SEG_CLAUDE_USAGE_DATA_FILE="${TMUX_POWERLINE_SEG_CLAUDE_USAGE_DATA_FILE_DEFAULT}"
# Leading symbol.
export TMUX_POWERLINE_SEG_CLAUDE_USAGE_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_USAGE_SYMBOL_DEFAULT}"
# Percent at which a window turns yellow / red.
export TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN="${TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_DEFAULT}"
export TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT="${TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_DEFAULT}"
EORC
	echo "$rccontents"
}

__claude_usage_colour() {
	if [ "$1" -ge "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_DEFAULT}" ]; then
		echo "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_COLOUR:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_CRIT_COLOUR_DEFAULT}"
	elif [ "$1" -ge "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_DEFAULT}" ]; then
		echo "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_COLOUR:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_WARN_COLOUR_DEFAULT}"
	else
		echo "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_OK_COLOUR:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_OK_COLOUR_DEFAULT}"
	fi
}

run_segment() {
	local file="${TMUX_POWERLINE_SEG_CLAUDE_USAGE_DATA_FILE:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_DATA_FILE_DEFAULT}"
	[ -r "$file" ] || return 1
	command -v jq >/dev/null 2>&1 || return 1

	local vals pct5 res5 pct7 res7 now base
	vals=$(jq -r '[(.five_hour.used_percentage // 0 | round), (.five_hour.resets_at // 0 | floor),
	               (.seven_day.used_percentage // 0 | round), (.seven_day.resets_at // 0 | floor)] | @tsv' \
	       "$file" 2>/dev/null) || return 1
	[ -n "$vals" ] || return 1
	IFS=$'\t' read -r pct5 res5 pct7 res7 <<<"$vals"

	# A window past its reset time has already rolled over, so a stale cache
	# should read 0 rather than reporting last week's number as current.
	now=$(date +%s)
	[ "${res5:-0}" -gt 0 ] && [ "$now" -ge "$res5" ] && pct5=0
	[ "${res7:-0}" -gt 0 ] && [ "$now" -ge "$res7" ] && pct7=0

	base="#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
	printf '%s%s %s5h %s%%%s %s7d %s%%%s' \
		"$base" "${TMUX_POWERLINE_SEG_CLAUDE_USAGE_SYMBOL:-$TMUX_POWERLINE_SEG_CLAUDE_USAGE_SYMBOL_DEFAULT}" \
		"#[fg=$(__claude_usage_colour "$pct5")]" "$pct5" \
		"$base" \
		"#[fg=$(__claude_usage_colour "$pct7")]" "$pct7" \
		"$base"
	return 0
}
