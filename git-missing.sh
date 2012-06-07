#!/bin/bash
#
# git-missing.sh: show missing commits between branches
#
# Copyright (C) 2012 Paul Harris <paulharris@computer.org>
#
if [ $# -eq 0 ]; then
    set -- -h
fi
OPTS_SPEC="\
git missing [options] <commit>
--
d             show debug messages
oneline       show oneline log messages
p,patch         show patch
"
eval "$(echo "$OPTS_SPEC" | git rev-parse --parseopt -- "$@" || echo exit $?)"

PATH=$PATH:$(git --exec-path)
. git-sh-setup

debug=
log_opts=""

debug()
{
	if [ -n "$debug" ]; then
		echo "$@" >&2
	fi
}

assert()
{
	if "$@"; then
		:
	else
		die "assertion failed: " "$@"
	fi
}


#echo "Options: $*"

while [ $# -gt 0 ]; do
	opt="$1"
	shift
	case "$opt" in
		-d) debug=1 ;;
		--) break ;;
		*) log_opts="${log_opts} $opt" ;;
	esac
done

branch="$1"

debug "branch: {$branch}"
debug "log_opts: {$log_opts}"
debug "debug: {$debug}"
debug

if [ -z "$branch" ]; then
	die "You must provide the commit."
fi

debug "OUR: git log ${log_opts} $branch:HEAD"

(
echo "You have these extra commits:"
echo "------------------------------------------------------------"
git log --color=always ${log_opts} $branch..HEAD
echo
echo
echo
echo "You are missing these commits:"
echo "------------------------------------------------------------"
git log --color=always ${log_opts} HEAD..$branch
) | less -r
