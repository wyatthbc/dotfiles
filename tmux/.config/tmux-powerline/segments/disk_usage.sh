# shellcheck shell=bash
# User override of the bundled disk_usage segment.
#
# The bundled segment runs `df /` and prints column 5. On macOS APFS `/` is the
# sealed, read-only *system* volume (~12Gi of OS files, ~7% of the container),
# so it reports a number that never moves and says nothing about free space.
# Real user data lives on /System/Volumes/Data -- set the filesystem in config.sh.
#
# Output mirrors the mem field of tmux_mem_cpu_load ("20/24GB") for consistency:
#   󰋊 271/460G 64%

if [ -d /System/Volumes/Data ]; then _disk_default=/System/Volumes/Data; else _disk_default=/; fi
TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM="${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM:-$_disk_default}"
TMUX_POWERLINE_SEG_DISK_USAGE_GLYPH="${TMUX_POWERLINE_SEG_DISK_USAGE_GLYPH:-󰋊}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Filesystem to report. On macOS use the Data volume, not "/".
export TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM="${TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM}"
# Leading glyph.
export TMUX_POWERLINE_SEG_DISK_USAGE_GLYPH="${TMUX_POWERLINE_SEG_DISK_USAGE_GLYPH}"
EORC
	echo "$rccontents"
}

run_segment() {
	local used size pct
	# df -h columns (macOS): 1=fs 2=size 3=used 4=avail 5=capacity
	read -r used size pct < <(df -h "$TMUX_POWERLINE_SEG_DISK_USAGE_FILESYSTEM" 2>/dev/null |
		awk 'NR==2 {print $3, $2, $5}')
	[ -z "$pct" ] && return 1
	used="${used%i}"   # 271Gi -> 271G
	size="${size%i}"
	printf '%s %s/%s %s\n' "$TMUX_POWERLINE_SEG_DISK_USAGE_GLYPH" "$used" "$size" "$pct"
	return 0
}
