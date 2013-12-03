#!/bin/bash
# Git Sandbox Demo
# Tony Nowatzki
# 12/2/2013

skip_through=-1

if [ "$#" -eq 1 ]; then
  skip_through=$1
fi

if [ "$#" -ge 2 ]; then
  echo "usage: $0 [Lesson Number]"
  exit
fi



ps_str="$(tput setaf 1)--------------------------------------------------------------------------------$(tput sgr0)"

pause() {
  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p $ps_str
  else
    echo $ps_str
  fi
}

cecho() {
#echo -en '\E[47;34m'"\033[1mE\033[0m" 
  tput setaf 4
  echo -e "$@"
  tput sgr0
}

important_point=0
ipoint() {
  ipoint_count=$((ipoint_count + 1))
  tput setaf 5
  echo -e "$ipoint_count. $@"
  tput sgr0
}

defgit() {
#echo -en '\E[47;34m'"\033[1mE\033[0m" 
  tput setaf 3
  echo -ne "$1"
  tput setaf 4
  echo -e "$2"
  tput sgr0
}



runFastCmd() {
  dir=$1
  cd $dir
  shift
  echo "($dir) >>>" "$@"
  "$@"
  cd - &> /dev/null
}


runCmd() {
  dir=$1
  cd $dir
  shift
#  echo "($dir) >>>" $@
  asdf="\"$@\""
  tput setaf 3

  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p  "($dir) >>> $asdf  $(tput sgr0)"
  else
    echo "($dir) >>> $asdf  $(tput sgr0)"
  fi

  "$@"
  cd - &> /dev/null
}


showFiles() {
  cd $1
  for i in *; do
    tput setaf 4
    echo -n "File: "
    tput sgr0
    echo -n $i
    tput setaf 4
    echo  ", contents:"
    tput sgr0
    cat $i
  done
  cd - &> /dev/null
}

lesson_count=-1

lesson() {
  lesson_count=$((lesson_count + 1))
  if [ "$skip_through" -le "$lesson_count" ]; then
    read -p $ps_str
  else
    echo $ps_str
  fi
  tput setaf 1
  echo "   LESSON " $lesson_count ": " $@
  tput sgr0
  echo $ps_str
}

commit_n() {
  cd $1  
  echo `git log | grep commit | sed -n $2p | cut -d" " -f2 | cut -c1-7`
  cd - &> /dev/null
}


echo $ps_str
cecho "# Welcome to Git Sandbox Demo"
cecho "# This tutorial will teach you how to \"git\""
cecho "# It will not teach all of git's cool features, but by the end, you should"
cecho "# be able to be a \"competent\" git user for a simple workflow"
cecho "# Inside is a bunch of different lessons, and you can skip to a particular "
cecho "# Lesson by calling: $0 [Lesson Number]"
cecho "# When paused, press [Enter] to continue."
pause

cecho "# First, A note of warning: If you are afraid to use git, remember this:"
cecho "# There are only a few git commands which completely delete erase a commit."
cecho "# (None of which will be taught in this demo.)  If you think you've lost something,"
cecho "# DON'T PANIC.  Though it may be painful, anything which has ever been committed"
cecho "# can be retrieved."
cecho "# Lets Begin!"

pause

cecho "# All git commands that we run will be dispalayed on the screen, and run by You!"
cecho "# Try this one out, the directory is in ():"
runCmd . ls -al
cecho "# Look at all those cool files you have!"
pause

cecho "# First, I will need to delete directories:solo, repo.git, alice, bob."
cecho "# (just in case this isn't your first time)"
cecho "# Press control-C now if you don't want to do this!"

runCmd . rm -rf solo repo.git alice bob

lesson Your first repo

cecho "# Lets start off with a simple use case."
cecho "# One of git's great features is that it does not require a central repository."
cecho "# Any directory can become a git directory, and we can use git to do"
cecho "# local revision control."
cecho "# I've create some sample files in the \"solo\" diretory:"

mkdir -p solo
echo "Some random text " > solo/file1.txt
echo "More random text" > solo/file2.txt
echo -n "" > solo/executable.bin

#runFastCmd solo ls

showFiles solo

pause
cecho "# We can turn this into a git repository by running your first git command:"
runCmd solo git init

cecho "# Right now, git isn't keeping track of any of your files."
cecho "# To track files, we can run:"

runCmd solo git add file1.txt file2.txt

cecho "# Now these files are tracked."
cecho "Lets create our first commit:"
runCmd solo git commit -m "Initial Commit"

cecho "# Our files are now in the repository. Phew, doesn't that feel better?"
cecho "# Notice how we did not put any executable files in the repository"
cecho "# This is generally good practice.  Generated/Temporary files should"
cecho "# not go in the repository, and large files should probably stay out too."

lesson "# The stages of a file in git"

cecho "# Files in git can be in one of four stages:"
cecho "# 1. Untracked: The file is not kept track of by git"
cecho "# 2. Modified, Unstaged: The file is modified since the last commit"
cecho "# 3. Modified, Staged: The modified file is staged for commit"
cecho "# 4. Committed: The file is committed/unchaed since last commit"
cecho "# Stage 3 is a unique feature to git.  The staged state allows the developer"
cecho "# To pick and choose files and changes that should comprise a single commit"
pause

cecho "# Moving between states is a matter of running different git commands"
cecho "# These are summarized below:"
cecho ""

d="\xE2\x86\x93"
cecho "# Untracked -----------"
cecho "#                     |  $(tput setaf 3) git add $(tput setaf 4)"
cecho "# Mod. Unstaged       |"     
cecho "#   $d  $(tput setaf 3)git add$(tput setaf 4)        |"
cecho "# Mod. Staged <--------"
cecho "#   $d  $(tput setaf 3)git commit$(tput setaf 4)"
cecho "# Committed"
cecho "" 

cecho " Notice how the command add command is used for both staging and tracking files."
pause


cecho "# Now we're going to demonstrate the different stages by making changes to the files."
cecho "# I've already done this, Should we check what changes i've made?"
echo "...another random line" >> solo/file1.txt
echo "...another random line" >> solo/file2.txt
runCmd solo git diff --color

cecho "# This command shows the difference between files in the modified/unstanged state,"
cecho "# versus files in the modified/staged state."
cecho "# As you can see, i've added the text \"...another random line\" to both files"
pause

cecho "# Lets check what state all of the files are in right now. We can do that by running:"
runCmd solo git status

cecho "# Right now, we have one untracked file, and two modififed files"
pause

cecho "# Now lets stage the changes that we made to file1.txt"
runCmd solo git add file1.txt
runCmd solo git status

cecho "# The status of file1.txt is now staged.  We can see the actual"
cecho "# staged changes by using the --cached flag on diff:"
runCmd solo git diff --cached --color


cecho "# And now lets commit them"
runCmd solo git commit -m "Committing Changes to file1"

runCmd solo git status
cecho "# Now, only file2.txt is in the modified/unstaged state"
pause

cecho "# If we don't want to go through the trouble of staging and comitting files,"
cecho "# We can use use the \"-a\" flag to stage and commit all modified files"

cecho ""
cecho "# Untracked"
cecho "#"
cecho "# Mod. Unstaged -------"     
cecho "#   $d  $(tput setaf 3)git add$(tput setaf 4)        |"
cecho "# Mod. Staged         |  $(tput setaf 3) git commit -a$(tput setaf 4)"
cecho "#   $d  $(tput setaf 3)git commit$(tput setaf 4)     |"
cecho "# Committed <---------"
cecho "" 

cecho "# Lets try this out now:"
runCmd solo git commit -am "Committing Changes to file2"
runCmd solo git status
cecho "# Now we have no changes left to commit"

lesson "Viewing History, and Going back in Time"

cecho "# The git log contains the history of all commits, try it out:"
runCmd solo git log --color
cecho "# You should see our three different commits, the author, and the date changed."
cecho "# Also notice the \"hash,\" this is what names a particular commit uniquely."
pause

cecho "# We can see what the differences between commits using the hash identifiers,"
cecho "# and we only have to use the first four digits of the hash, if we are lazy."
cecho "# Lets diff our last two commits:"



last_commit=`commit_n solo 1`
second_last_commit=`commit_n solo 2`
third_last_commit=`commit_n solo 3`

runCmd solo git diff --color $second_last_commit $last_commit
cecho "# notice how just file2 was modified"
pause

cecho "# now lets try diffing the first and last commits"
runCmd solo git diff --color $third_last_commit $last_commit
cecho "# and now both files are modified, exactly what we would expect."
pause

cecho "# Lets say we don't like the final commit: we don't want the changes"
cecho "# that we made to file 2."
cecho "# There are various ways to \"undo\" changes in git, re-write history, and delete"
cecho "# all traces of an embarassing commit. Lets not get ahead of ourselves"
cecho "# The simplest way to undo changes is to apply the inverse patch, known"
cecho "# in git as a \"revert\""
cecho "# Lets revert back to our very first commit, where each file only had one line"
cecho "# Right now our files contain"

showFiles solo

runCmd solo git revert HEAD...$third_last_commit --no-commit
cecho "# Here, the ... specifies a range of commits,"
cecho "# and HEAD is just a shortcut for the latest commit."
cecho "# Now lets check what's in our files"

showFiles solo

cecho "# Cool huh? Since we specified no-commit, lets make sure we commit this change:"
runCmd solo git commit -am "Reverted to $third_last_commit"

cecho "# and our log says:"
runCmd solo git log


lesson "Branches and Merging"

cecho "# You can create a new branch named \"experiment\" by simply running:"
runCmd solo git branch experiment

cecho "# The branch we created is based off the current branch we are on."
cecho "# The branches you have can be listed with:"
runCmd solo git branch

cecho "# Here, the branch you are on is marked with a \"*\""
cecho "# You can switch branches with:"

runCmd solo git checkout experiment

cecho "# While you weren't looking, I've committed different changes to both branches."

## behind the scenes adding of commits
cd solo
echo "a minor change" >> file2.txt
git commit -am "experimental change" &> /dev/null

git checkout master &> /dev/null
echo "a minor change" >> file1.txt
git commit -am "change to master" &> /dev/null

git checkout experiment &> /dev/null
cd ..
#done

cecho "# Lets see what I did:"
runCmd solo git log  --graph --oneline --decorate --all --color
cecho "# First, you should see diverging branches."
cecho "# Second, notice the \"HEAD\" keyword, which refers to the current commit you are"
cecho "# working off of.  HEAD usually refers to the commit which is the latest in the " 
cecho "# current branch.  Switching branches will change the head pointer."
pause

cecho "# Lets say I want to continue to make changes on the experimental branch, but I also"
cecho "# want to keep up-to-date with master.  I can run the following:"

runCmd solo git merge master -m "merging master changes"
runCmd solo git log  --graph --oneline --decorate --all --color

cecho "# Cool huh?  The experiment branch was automatically merged in with master,"
cecho "# because there was no conficts.  Lets add some more commits, and try again."
cecho "# (again, I'll do this behind the scenes)"

## behind the scenes adding of commits
cd solo
echo "a minor change 2" >> file2.txt
git commit -am "experimental change 2" &> /dev/null

git checkout master &> /dev/null
echo "a minor change 2" >> file1.txt
git commit -am "change to master 2" &> /dev/null

git checkout experiment &> /dev/null
cd ..
#done

runCmd solo git log  --graph --oneline --decorate --all --color

cecho "# OK.  This time the graph is a little harder to understand. But it's ascii after"
cecho "# all.  What you should see is that each branch, master and experimental, has one"
cecho "# additional commit."
pause

cecho "# Lets prepare to merge the experimental changes back into master."
cecho "# First, lets merge in the master changes to the experimental branch."

runCmd solo git merge master -m "merging master changes 2"
runCmd solo git log  --graph --oneline --decorate --all --color

cecho "# Once we are convinced there are no bugs, lets merge the experiment branch"
cecho "# back into the master branch"

runCmd solo git checkout master
runCmd solo git merge experiment -m "merging experiment to master"
runCmd solo git log  --graph --oneline --decorate --all --color

cecho "# YAY! All of our branches are matched up, and we are all happy."
cecho "# One subtle point is that there is no commit for the last merge."
cecho "# That's because no merging actually happened, the only thing that"
cecho "# changed was which commit the master branch pointed to"
pause

cecho "# At this point, since we don't want the experiment branch anymore,"
cecho "# lets just delete it"

runCmd solo git branch -d experiment

cecho "# presto, it's gone!"

lesson "Branching and Conflict Resolution"

cecho "# The previous examples shows what happens when changes on separate branches"
cecho "# did not iterfere.  There were no conflicts.  Though branches should generally"
cecho "# be about separate ideas, there's no gaurantee that they won't both change"
cecho "# the same part of the same files.  Git does it's best to automatically merege"
cecho "# changes, but of course it is not always successful."
pause

cecho "# We will now explore a similar scenario as the example in the previous lesson, but"
cecho "# this time there will be a conflict!"
cecho "# Again, i've done some commits behind the scenes, as you can see:"


## behind the scenes adding of commits
cd solo
git branch experiment

echo "a conflicting change in master branch" >> file1.txt
git commit -am "change to file1 in master" &> /dev/null

git checkout experiment &> /dev/null
echo "a conflicting change in experiment branch" >> file1.txt
git commit -am "change to file1 in experiment" &> /dev/null

git checkout master &> /dev/null
cd ..
#done

runCmd solo git log  --graph --oneline --decorate --all --color

cecho "# so far so good, right?"
cecho "# lets try to merge experiment back to master."

runCmd solo git merge experiment -m "nothing can go wrong, right?"

cecho "# oh no. you can't be serious?  What is our status:"

runCmd solo git status 

cecho "# Notice how there's a new category \"Unmerged Paths\"."
cecho "# Those are conflicting files that we need to take care of."
cecho "# Lets check out what's in the files:"

showFiles solo

cecho "# Automatic merging has failed, but git has helped us out by leaving"
cecho "# the un-merged regions, with markers, inside the conflicting file"
cecho "# Between the $(tput sgr0)<<<<<<< ========= $(tput setaf 4) symbols is the version of the conflicting"
cecho "# region from the master branch"
cecho "# Between the $(tput sgr0)========= >>>>>>> $(tput setaf 4) symbols is the version of the conflicting"
cecho "# region from the experimental branch"

pause

cecho "# In order to fix this, we need to manually fix-up what we actually want to"
cecho "# appear in the files.  Since this is a non-interactive demo, I'll take care"
cecho "# of this for you behind the scenes.  Here are the results:"

cd solo
#git checkout HEAD^ file1.txt
#echo "a conflicting changed, that's not been fixed" >> file1.txt

echo "Some random text" > file1.txt
echo "a minor change" >> file1.txt
echo "a minor change2" >> file1.txt
echo "a conflicting change, that's been fixed-up" >> file1.txt
cd ..

showFiles solo

cecho "# lets check the status again:"
runCmd solo git status
cecho "# ... even after fixing the file, the status is still unmerged."
cecho "# We need to \"add\" the file to mark it as good."

runCmd solo git add file1.txt
runCmd solo git status
cecho "# Now our merge is ready for commit!."

runCmd solo git commit -am "Merging Conflict"
runCmd solo git log  --graph --oneline --decorate --all --color
cecho "# Now our branches are merged safe and sound."
pause

cecho "Lets review some commands and important points:"

cecho  ""
cecho  "Git Commands:"
defgit "git init [dir]          " "creates an empty repository"
defgit "         --bare         " "makes a repo with no working directory"
defgit "git add  [file]         " "Stages (and possibly begins tracking) file."
defgit "git commit -m \"msg\"   " "Commits staged files to repo."
defgit "git log --color         " "Shows the log of commits."
defgit "        --graph --oneline --decorate --all --color  " "Show Commit tree."
defgit "git status              " "Display the current status of all files."
defgit "git diff --color        " "Shows current uncommitted changes"
defgit "         --cached       " "Shows current staged changes"
defgit "         [rev1] [rev2]  " "Shows differences between rev1 and rev2"
defgit "git branch [br_name]    " "creates a new branch br-name from the current branch."
defgit "                    -d  " "delete this branch"
defgit "git checkout [br_name]  " "Switch to br_name branch."
defgit "git merge [br_name]     " "merge br_name into current branch."
defgit "git revert HEAD...[desired_commit] --no-commit  " "reverts changes up to desired commit"

pause

cecho  ""
cecho  "Some important points:"

ipoint "Files can be in four basic states: 
        Untracked, Unstaged, Staged, Committed."
ipoint "If possible, commit all files before performing any git action.
        If a commit of a file exists, it can be recovered!"
ipoint "Do not put temporary/generated/large files in the repository."
ipoint "In project branches, try to stay up to date with the master.
        This will help prevent conflicts as branches evolve."

pause

cecho "# CERTIFICATION: GIT SOLO USER"
cecho "# If you understood the above commands,"
cecho "# and you have taken the above advice to heart," 
cecho "# you are hereby certified to be a git solo user."
cecho "# To get your sharing certification, keep going!"

lesson Sharing with a Centralized Repository
cecho "# So far we been working in a local repository only,"
cecho "# but sharing is probably the most important part of version control."
cecho "# Git supports MANY different forms of version control workflows, raninging"
cecho "# from no-sharing, peer-to-peer sharing, and clustered hierarchies, etc..."
cecho "# This tutorial will present ONE possibility: a centeralized group repository"
pause

cecho "# One of the nice things about git is that the branch abstraction is used for"
cecho "# sharing among repositories as well.  There are only a few more commands to"
cecho "# learn in order to do sharing.  (of course, there are endless other git commands : )"
pause

cecho "# Lets begin by creating the repo:"
runCmd . git init --bare repo.git

cecho "# Here, the init command creates a new repository, and the --bare flag means"
cecho "# that there is no working directory.  This simplifies the management of the"
cecho "# central repository."
pause

cecho "# Both alice and bob want to work on this project, so they will each \"clone\""
cecho "# from repo.git"

runCmd . git clone repo.git alice
cecho "# Yes, we cloned an empty repository.  So what?"
runCmd . git clone repo.git bob

cecho "# Cloning exactly means to create a copy of the repository.  It also sets things"
cecho "# up so that the source of the clone is the default origin for communication/sharing"
pause

cecho "# Behind the scenes I pushed our git repository from the solo directory into"
cecho "# our new central repository repo.git. (If you're really interested, you can"
cecho "# edit the script to see what I did, it's not too complicated  : )"

cd solo
git push ../repo.git master &> /dev/null
cd ..

cecho "# Lets have alice and bob get the new changes.  To attempt to put the latest copy"
cecho "# in the current directory, we can run a \"pull\" command."
runCmd alice git pull
runCmd bob git pull

cecho "# \"Pull\" synchronizes the "
cecho "# Cool. Lets check on one of them, to make sure we got the old files"
runCmd alice git log  --graph --oneline --decorate --all --color
cecho "# And.... all is well."
cecho "# Cool. Lets check on one of them, to make sure we got the old files"
pause

cecho "# Alice and bob agree that the master branch will be shared, and they will"
cecho "# use local branches only as necessary, at least for the time being."
cecho "# Alice starts by making a change, right in the master branch."
cecho "# lets see what she did."

echo "ALICE'S CHANGE 1" >> alice/file2.txt
showFiles alice

cecho "# Alice commits her change to her local repo like"
runCmd alice git commit -am "alice's first commit"

cecho "# Remember, the \"a\" flag automatically stages all modified files."
pause

cecho "# now Alice makes another change:"

cecho "# now Alice makes another change:"
echo "ALICE'S CHANGE 2" >> alice/file2.txt
showFiles alice
cecho "# and she makes sure to commit again."
runCmd alice git commit -am "alice's second commit"

pause

cecho "# Right now, if Bob were to \"pull\" changes from the main repo"
cecho "# guess what would happen:"

runCmd bob git pull

cecho "# ... Nothing, that's what. Bob doesn't see the changes."
cecho "# The reason is that the central repository, repo.git, was not given"
cecho "# the latest set of changes yet. Alice needs to \"push\" the changes there."
cecho ""
cecho "# To synchronize the changes, we first \"pull\" to make sure everything"
cecho "# is up to date, then we \"push\" our changes:"

runCmd alice git pull
runCmd alice git push

cecho "# Now bob can get the changes"
runCmd bob git pull
runCmd bob git log  --graph --oneline --decorate --all --color

cecho "# TADA!  So it wasn't so hard to share after all."
pause


#cecho "# And new she makes a change."
#echo "ALICE'S COOL NEW FEATURE!!!!" >> alice/file1.txt
#showFiles alice
#cecho "# and she commit's it."



cecho ""
cecho "# Lets review the commands from the last lessons, and important points:"

cecho ""
defgit "git init [dir]          " "creates an empty repository"
defgit "         --bare         " "makes a repo with no working directory"
defgit "git clone [orig_repo]   " "Creates new repository, with remote set to orig_repo"
defgit "git pull                " "Bring local branches up-to-date with remote branches."
defgit "git push                " "Push local commits up to remote repository."

pause
cecho ""
cecho "Some Important Points:"
ipoint "Pulling is like merging, but with remote instead of local branches."
ipoint "Just as with merging local branches, make sure to commit before pulling.
        If the merge fails, its best to have a commit point to go back to."
ipoint "Pull in changes from the remote repository before pushing.
        This keeps repositories synchronized better."


pause

cecho "# CERTIFICATION: GIT NOVICE USER"
cecho "# If you understood the above commands,"
cecho "# and you have taken the above advice to heart," 
cecho "# you are hereby certified to be a git novice user."
cecho "# To get your advanced certification, keep going!"

lesson Advanced Topic A: Undoing Things
lesson Advanced Topic B: Rebase
lesson Advanced Topic C: Advanced Sharing
cecho "# Another cool thing that might help out when working together is having"
cecho "# shared branches for specific topics, like adding a new feature."
cecho "# Alice can do this pretty simply, first she creates a branch."

runCmd alice git branch cool_feature
cecho "# Alice switches to this branch:"
runCmd alice git checkout cool_feature

cecho "# If alice tries to push now, nothing will happen"
runCmd alice git push
cecho "# This is because the branch isn't being tracked on the remote repo."

cecho "# Passing the -u flag will help:"
runCmd alice git push -u origin cool_feature
cecho "# Here \"origin\" is the location of the repo, which was setup automatically"
cecho "# when we did the original clone.  There are easy ways to modify this if necessary."

cecho "# To get this branch, bob just has to pull, and checkout"
runCmd bob git pull
runCmd bob git checkout cool_feature
runCmd bob git branch

lesson Advanced Topic D: What can go wrong


cecho "# CERTIFICATION: GIT ADEPT USER"
cecho "# If you understood the above commands,"
cecho "# and you have taken the above advice to heart," 
cecho "# you are hereby certified to be a git adept user."
cecho "# To become an expert ... you have to use git"
cecho "# a lot more than this simple script can show."

pause

cecho "# I hope you have enjoyed this git sandbox demo, and"
cecho "# wish you luck in your adventures with git."
cecho "# -- Tony Nowatzki, Vertical Research Group, December 2013"
cecho "#    tjn@cs.wisc.edu"
