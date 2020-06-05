#!/bin/bash
VER="v1.27.0"

if ! [ -x "$(command -v golangci-lint)" ]; then
  echo "Installing golangci-lint ${VER}"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" "$VER"
else
  echo "golangci-lint is installed..."
fi

echo "Installing hooks"
mkdir ./git-hooks 2>/dev/null

# library file
cat <<-EOF > ./git-hooks/lib.sh
#!/bin/bash

function echoWhiteBold {
  echo -e "\e[1;37m\${1}\e[0m"
}

function echoWarning {
  echo -e "\e[1;33m\${1}\e[0m"
}

function echoSuccess {
  echo -e "\e[1;37;42m\${1}\e[0m"
}

function echoError {
  echo -e "\e[1;31m\${1}\e[0m"
}
EOF

# pre-commit hook
cat <<- EOF > ./git-hooks/pre-commit
#/bin/bash
source ./git-hooks/lib.sh
LINTERS=\$(cat <<-LIST
gofmt,deadcode,gocritic,goimports,nolintlint,govet,goconst,dogsled,errcheck,bodyclose,\\
gochecknoinits,gosec,gosimple,ineffassign,rowserrcheck,scopelint,staticcheck,stylecheck,gomnd,typecheck
LIST
)
echoWarning "\nTesting with go linters\n"
golangci-lint run --no-config --max-issues-per-linter=0 --max-same-issues=0 --tests=false --exclude="mnd: Magic number:.*<(operation|assign)> detected" --disable-all=true -E "\$LINTERS"
if [ \$? -eq 0 ]; then
  echoSuccess "👍 Everything is good 👍"
  echo -e "\n"
  exit 0
else
  echoWhiteBold "\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
  echoError "⚠ Please fix the issues above before commiting ⚠️"
  exit 1
fi
EOF

# adding hooks to .gitignore
chmod a+x ./git-hooks/pre-commit
git config core.hooksPath git-hooks/

if [ "$(grep -R git-hooks ./.gitignore|wc -l)" -eq 0 ]; then
  echo -e "\ngit-hooks/" >> .gitignore
  echo "hooks.sh" >> .gitignore
fi

echo -e "All done!\n"
