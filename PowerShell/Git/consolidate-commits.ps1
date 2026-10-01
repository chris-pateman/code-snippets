
git reset --soft HEAD~20 
git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"