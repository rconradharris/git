#!/bin/sh
#
# Copyright (c) 2012 Felipe Contreras
#

if test -n "$BASH" && test -z "$POSIXLY_CORRECT"; then
	# we are in full-on bash mode
	true
elif type bash >/dev/null 2>&1; then
	# execute in full-on bash mode
	unset POSIXLY_CORRECT
	exec bash "$0" "$@"
else
	echo '1..0 #SKIP skipping bash completion tests; bash not available'
	exit 0
fi

test_description='test bash completion'

. ./test-lib.sh

complete ()
{
	# do nothing
	return 0
}

. "$GIT_BUILD_DIR/contrib/completion/git-completion.bash"

_get_comp_words_by_ref ()
{
	while [ $# -gt 0 ]; do
		case "$1" in
		cur)
			cur=${_words[_cword]}
			;;
		prev)
			prev=${_words[_cword-1]}
			;;
		words)
			words=("${_words[@]}")
			;;
		cword)
			cword=$_cword
			;;
		esac
		shift
	done
}

print_comp ()
{
	local IFS=$'\n'
	echo "${COMPREPLY[*]}" > out
}

run_completion ()
{
	local -a COMPREPLY _words
	local _cword
	_words=( $1 )
	(( _cword = ${#_words[@]} - 1 ))
	_git && print_comp
}

test_completion ()
{
	test $# -gt 1 && echo "$2" > expected
	run_completion "$@" &&
	test_cmp expected out
}

test_expect_success 'basic' '
	run_completion "git \"\"" &&
	# built-in
	grep -q "^add \$" out &&
	# script
	grep -q "^filter-branch \$" out &&
	# plumbing
	! grep -q "^ls-files \$" out

	run_completion "git f" &&
	! grep -q -v "^f" out
'

test_expect_success 'double dash "git" itself' '
	sed -e "s/Z$//" >expected <<-\EOF &&
	--paginate Z
	--no-pager Z
	--git-dir=
	--bare Z
	--version Z
	--exec-path Z
	--html-path Z
	--work-tree=
	--namespace=
	--help Z
	EOF
	test_completion "git --"
'

test_expect_success 'double dash "git checkout"' '
	sed -e "s/Z$//" >expected <<-\EOF &&
	--quiet Z
	--ours Z
	--theirs Z
	--track Z
	--no-track Z
	--merge Z
	--conflict=
	--orphan Z
	--patch Z
	EOF
	test_completion "git checkout --"
'

test_done
