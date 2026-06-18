#!/bin/sh

function has_version() {
    echo $1 | sed -n 's/\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)/\1/p'
}

version=$(has_version $(rat-scratch get --meta=./.rsmeta version))
if [ -z "$version" ]; then
    echo "Need a version in the format major.minor.revision (e.g., 1.0.0)"
    exit 1
fi

has_pending_changes=$(git status --porcelain)

if [ ! -z "$has_pending_changes" ]; then
    echo "Cannot package release when current directory has pending changes!"
    exit 1
fi

tag="$(rat-scratch get --meta=./rsmeta name)-v${version}"

set -e

git fetch
git checkout main
git pull
git tag "$tag"
git push origin tag "$tag"

set +e

zip_file="$(git describe --tags --abbrev=0).zip"
tar_file="$(git describe --tags --abbrev=0).tar.gz"

rm -r build lib
rat-scratch build --meta=./.rsmeta
mv build/* build/$(rat-scratch get --meta=./rsmeta name)

pushd ./build

cp -r ../.rsmeta ../LICENSE ../README.md .
zip -r "../$zip_file" .
tar -czvf "../$tar_file" .

popd

gh release create --draft --verify-tag -t "$(rat-scratch get --meta=./rsmeta name) v${version}" "$tag" "./$zip_file" "./$tar_file"
