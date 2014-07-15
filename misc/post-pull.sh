#!/bin/sh

# To add this as a git hook:
# $ ln -s ../../misc/post-pull.sh .git/hooks/post-merge

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

cd `dirname $0`/..

. $HOME/.secret_shell_aliases

case `which bundle` in
  $HOME/.rvm/bin/bundle | "")
    gem install bundler
    ;;
esac

(bi_force || bundle install) || exit $?
bundle exec rake db:create
bundle exec rake db:migrate || exit $?
bundle exec rake db:test:clone || exit $?
./misc/pre-commit.sh || exit $?
