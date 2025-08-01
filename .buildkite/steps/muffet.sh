#!/usr/bin/env sh

set -e

apk add jq

touch annotation.md

# We need to wait until rails has started before running muffet as otherwise it will error out
# and the test will appear to have failed without having run. The time to wait is hard to
# predict, and furthermore, some paths take longer to be be ready than others. The path in this
# loop was chosen after some non-systematic observations. So it does not guarantee that the
# server will be ready. But it seems to work well in practice.
#
while ! wget --spider -S http://app:3000/docs/agent/v3/hooks;
  do echo 💎🛤️🦥 Rails is still starting;
  sleep 0.5;
done
echo 💎🛤️🚆 Rails has started running

# If muffet fails, we want to process the results instead of quitting immediately.
#
set +e
/muffet http://app:3000/docs \
  --include="/docs/" \
  --exclude="https://github.com/buildkite/docs/" \
  --exclude="buildkite.com/docs" \
  --max-connections=10 \
  --buffer-size=8192 \
  --format=json \
  > muffet-results.json

muffet_exit_code=$?
set -e

# We want to see muffet's output in its natural habitat (the build log) in case
# something goes wrong, e.g. the output is not valid JSON for some reason, or we
# hit a bug in the annotation-making code below.
#
cat muffet-results.json

if [ "0" = "$muffet_exit_code" ]; then
    echo "Muffet found no problems :sunglasses:"
else
    # Use jq to transform JSON output from muffet into a Markdown table.
    #
    # This place is not a place of honor. No highly esteemed deed is
    # commemorated here. Nothing valued is here.
    #
    # This is some of the worst and most advanced jq I have ever written.
    #
    # DuckDB would do this job far more easily, but it's not available in the
    # Alpine container image where this script gets executed during CI, and I'm
    # already awash with yak hair. If you find yourself able to swap this out
    # for DuckDB (or any other tool that would do the job more elegantly), I
    # encourage you to do so.
    #
    # -- @lucaswilric, July 2025
    #
    #shellcheck disable=SC2016
    jq_query='. |
    map(.page = (.url | sub("https?:\/\/[^\/]+"; ""))) |
    map(.links_str = (.links | map("| "+.url+" | "+.error+" |") | join("\n"))) |
    map("In `"+.page+"`:\n\n| Link | Status |\n|--|--|\n"+.links_str) | .[]'

    {
        echo "## Muffet found broken links"
        echo
    } >> annotation.md

    < muffet-results.json jq -r "$jq_query" >> annotation.md

    if [ -n "$(which buildkite-agent)" ]; then
        buildkite-agent annotate --style=error --context=muffet <annotation.md
    else
        cat annotation.md
    fi

    exit $muffet_exit_code
fi
