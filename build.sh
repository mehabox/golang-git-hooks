#!/bin/bash
OLD_IFS=$IFS
IFS=
LINTER_VER="v1.27.0"

cat <<-EOF > ./hooks.sh
#!/bin/bash
VER="$LINTER_VER"

if ! [ -x "\$(command -v golangci-lint)" ]; then
  echo "Installing golangci-lint \${VER}"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "\$(go env GOPATH)/bin" "\$VER"
else
  echo "golangci-lint is installed..."
fi

echo "Installing hooks"
mkdir ./git-hooks 2>/dev/null

EOF

# collecting all of the files in the src dir
for d in "./src/"*
do
   file=$(basename $d);
   contents=$(cat $d)
   template=$(echo -e |cat <<-EOF
cat <<- F > ./git-hooks/$file
$contents
F

EOF
)
  echo $template| sed 's/\$/\\$/g' >> ./hooks.sh
done


cat <<-EOF >> ./hooks.sh

chmod a+x ./git-hooks/pre-commit
git config core.hooksPath git-hooks/

if [ "\$(grep -R git-hooks ./.gitignore|wc -l)" -eq 0 ]; then
  echo -e "\n#golang-git-hooks\ngit-hooks/" >> .gitignore
  echo "hooks.sh" >> .gitignore
fi

echo -e "All done!\n"

EOF

IFS=$OLD_IFS