set -e

cd ${TIMECARD_HOME:-$HOME/.timecard}

mutator=
msg=
case "$1" in
  in|out|comment)
    mutator=t
    msg="clock $*"
    ;;
  edit)
    mutator=t
    ;;
esac

if test -n "$mutator"; then
  git pull -q
fi

TIMECARD=timecard timecard "$@"

if test -n "$mutator"; then
  git add timecard
  git commit -q ${msg:+-m "$msg"} -- timecard
  git push -q
fi
