#!/bin/bash
set -e

source scripts/travis_env.sh

if [[ ${TRAVIS_SECURE_ENV_VARS} = true ]]; then
  if [ ${TRAVIS_PULL_REQUEST} != false ]; then
    echo -e "\e[31mDeploying app to pull request\e[0m"
    curl -u m-kuhn:${GITHUB_API_TOKEN} -X POST --data '{"body": "Uploaded test apks for\n - [**armv7**](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7.apk)\n - [arm64_v8a](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-arm64_v8a.apk)\n - [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86.apk)\n - [x86_64](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86_64.apk)"}' https://api.github.com/repos/opengisch/QField/issues/${TRAVIS_PULL_REQUEST}/comments
  elif [[ -n ${TRAVIS_TAG} ]]; then
    echo -e "\e[93;1mStarting to deploy a new release\e[0m"
    openssl aes-256-cbc -K $encrypted_play_upload_key -iv $encrypted_play_upload_iv -in .ci/play_developer.p12.enc -out .ci/play_developer.p12 -d
    echo -e "\e[93m * Collecting apks to upload...\e[0m"
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-armv7.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-armv7.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-arm64_v8a.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-arm64_v8a.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-x86.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-x86.apk
    curl -L -s -S -o /tmp/qfield-${TRAVIS_TAG}-x86_64.apk https://download.opengis.ch/qfield/ci-builds/qfield-dev-${UPLOAD_ARTIFACT_ID}-${TRAVIS_COMMIT}-x86_64.apk

    echo -e "\e[93m * Deploying app to github release...\e[0m"
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-armv7.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-x86.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-arm64_v8a.apk ${TRAVIS_TAG}
    ./scripts/upload_release_asset.py /tmp/qfield-${TRAVIS_TAG}-x86_64.apk ${TRAVIS_TAG}

    echo -e "\e[93m * Deploying app to google play (beta)...\e[0m"
    ./scripts/basic_upload_apks_service_account.py ch.opengis.qfield /tmp/qfield-${TRAVIS_TAG}-armv7.apk /tmp/qfield-${TRAVIS_TAG}-x86.apk /tmp/qfield-${TRAVIS_TAG}-arm64_v8a.apk /tmp/qfield-${TRAVIS_TAG}-x86_64.apk

  elif [[ ${TRAVIS_BRANCH} = master ]]; then
    # we are on a standard commit on master branch
    curl -u m-kuhn:${GITHUB_API_TOKEN} -X POST --data '{"body": "Uploaded test apks for\n - [**armv7**](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-armv7.apk)\n - [arm64_v8a](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-arm64_v8a.apk)\n - [x86](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86.apk)\n - [x86_64](https://download.opengis.ch/qfield/ci-builds/qfield-dev-'${UPLOAD_ARTIFACT_ID}'-'${TRAVIS_COMMIT}'-x86_64.apk)"}' https://api.github.com/repos/opengisch/QField/commits/${TRAVIS_COMMIT}/comments
  fi
fi
