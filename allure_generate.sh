#!/bin/bash
#MIT License
#
#Copyright (c) 2021 Aleksandr Kotlyar
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
echo "Start allure_generate.sh"

results=$1
if [[ $1 == '' ]]; then
  results=allure-results
fi

ROOT=$2
if [[ $2 == '' ]]; then
  ROOT=allure
fi
mkdir -p $ROOT

report=$(date +%F_%A_%H-%M-%S)
build=$(date +%s%3)

tee >executor.json <<EOF
{
  "name":"HUMAN RUN",
  "type":"",
  "reportName":"",
  "reportUrl":"/${report}/",
  "buildUrl":"${report}",
  "buildName":"",
  "buildOrder":"${build}"
}
EOF

mv ./executor.json ./"${results}"

echo "Copy last history"
cp -r ./${ROOT}/history ./"${results}" || echo "This is the first report - no history yet"
echo "Generating allure-report into ./${ROOT}/"
allure generate "${results}" -o ./${ROOT}/"${report}"
echo "Rewrite last history with latest history"
rm -rf ./${ROOT}/history
cp -r ./${ROOT}/"${report}"/history ./${ROOT}/history
echo "Clean allure-results"
rm -rf ${results}

echo "Start Generating indexes..."

OUTPUT="$ROOT/index.html"

echo "<UL>" >"$OUTPUT"
for filepath in $(find "$ROOT" -maxdepth 1 -mindepth 1 -type d | sort); do
  path=$(basename "$filepath")
  echo "    <LI><a href=\"/$path\">$path</a></LI>" >>"$OUTPUT"
done
echo "</UL>" >>"$OUTPUT"
echo "Finish Generating indexes."

echo "Finish allure_generate.sh"
