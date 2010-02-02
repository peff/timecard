set -e

cd ${TIMECARD_HOME:-$HOME/.timecard}

mutator() {
  case "$1" in
    in|out|comment|edit) return 0 ;;
    *) return 1 ;;
  esac
}

if mutator "$@"; then
  git pull -q
fi

TIMECARD=timecard timecard "$@"

if mutator "$@"; then
  git add -A
  git commit -q -m "clock $*"
  git push -q
fi
