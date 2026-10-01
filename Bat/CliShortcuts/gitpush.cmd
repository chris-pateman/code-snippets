@echo off
echo ------------------Git Pull------------------
git pull
echo ------------------Git Status------------------
git status
echo ------------------GIT ADD ALL------------------
git add .
echo ------------------COMMIT------------------
git commit -m"%~1"
echo ------------------GIT PUSH------------------
git push
echo ------------------GIT COMPLETED------------------
