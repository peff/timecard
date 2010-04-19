set -e

cd ${TIMECARD_HOME:-$HOME/.timecard}

mutator=
case "$1" in
  in|out|comment|edit)
    mutator=t
    ;;
esac

if test -n "$mutator"; then
  git pull -q
fi

TIMECARD=timecard timecard "$@"

if test -n "$mutator"; then
  git add -A
  git commit -q -m "clock $*"
  git push -q
fi
