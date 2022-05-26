eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa.1
git add .
git commit -a -m "Commit"
git push origin master
