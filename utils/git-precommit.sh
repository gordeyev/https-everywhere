#!/bin/sh
#
#   utils/precommit.sh hook script of https-everywhere.
#
#   Author: Jonathan Davies <jpdavs@gmail.com>
#

echo "$(date -R): Stashing unrelated changes in Git..."
git stash -q --keep-index

# Only run tests if our rulesets have been changed.
RULESET_PATTERN="src/chrome/content/rules/"
if [ ! $(git diff --cached --name-only | grep "$RULESET_PATTERN") ]; then
    echo "$(date -R): Skipping tests, no changes in $RULESET_PATTERN."
    exit 0
else
    echo "$(date -R): Running tests:"
    ./utils/trivial-validate.py src/chrome/content/rules > /dev/null
    RESULT=$?

    if [ $RESULT -eq 1 ]; then
        echo "$(date -R): Failure encountered during ruleset validation."
    fi
fi

echo "$(date -R): Reverting Git stash..."
git stash pop -q

exit $RESULT
