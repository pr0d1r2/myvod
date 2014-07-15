#!/bin/sh -e

# To add this as a git hook:
# $ ln -s ../../misc/pre-commit.sh .git/hooks/pre-commit

case $NO_TEST in
  "")
    ;;
  *)
    echo
    echo "Skipping tests as NO_TEST is set. To not skip tests please do: unset NO_TEST"
    echo
    sleep 1
    exit 0
    ;;
esac

bundle exec rspec || exit $?
