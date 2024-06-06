#!/bin/bash
cat <<EOF | curl --data-binary @- http:/localhost:9091/metrics/job/some_job/instance/some_instance
# TYPE some_metric counter
some_metric{label="val1"} 42
# TYPE another_metric gauge
# HELP another_metric Just an example.
another_metric 2398.283
EOF


cat <<EOF | curl --data-binary @- http://localhost:9091/metrics/job/metricfire/instance/article
# TYPE some_metric gauge
some_metric_test 42
# TYPE awesomeness_total counter
# HELP awesomeness_total How awesome is this article.
awesomeness_total 99999999
EOF
