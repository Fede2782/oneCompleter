#/bin/bash
rm *.zip
version="$(grep '^version=' module.prop  | cut -d= -f2)"
zip -r9 "oneCompleter-$version-online.zip" . -x build.sh update.json README.md CHANGELOG.md LICENSE ".git/*" ".github/*" "img/*"
#zip --delete "oneCompleter-$version-online.zip" ".git/*" || true
#zip --delete "oneCompleter-$version-online.zip" ".github/*" || true
#zip --delete "oneCompleter-$version-online.zip" "img/*" || true

