# Directory tree:
# config			contains project-specific configuration options
# info/			keeps a global exclude file for ignored patterns that you don�t want to track in a .gitignore file
# hooks/			contains client- or server-side hook scripts

# objects/		stores all the content for your database (object database)
# refs/			stores pointers into commit objects in objects/ (branches, tags, remotes ...)
# HEAD			points to currently checked out branch
# index			where Git stores staging area information


# Blob objects

git init								                        # init clean .git directory 
echo "test content" | git hash-object -w --stdin			    # store some data in an object file
git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4		# display stored content (Passing -p to cat-file instructs to figure out the type, then display it appropriately)
echo "version 1" > test.txt						                # create data file
git hash-object -w test.txt						                # store file content in an object file
echo "version 2" > test.txt						                # change file content
git hash-object -w test.txt						                # store new file content in an object file
rm test.txt								                        # remove file
git cat-file -p 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a > test.txt	    # restore file
cat test.txt								                    # check content of file
git cat-file -t 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a	    # display object type 'blob'

# Only data/content is stored in blob object, not file name.
# Tree objects store mode, type and filename of other objects

git update-index --add --cacheinfo 100644 83baae61804e65cc73a7201a7252750c76066a30 test.txt	    # add the 1st version of the test.txt file to a new staging area
                                                                                                # pass the --add option because the file doesn’t yet exist in your staging area
                                                                                                # pass --cacheinfo because file isn’t in your directory but is in your database.
                                                                                                # Then specify the mode, SHA-1, and filename
git write-tree											        # write the staging area out to a tree object
git cat-file -p d8329fc1cc938780ffdd9f94e0d364e0ea74f579		# display tree object
git cat file -t d8329fc1cc938780ffdd9f94e0d364e0ea74f579		# display object type 'tree'
echo "new file" > new.txt									    # create new file
git update-index --add --cacheinfo 100644 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a test.txt     # add the 2nd version of the test.txt file to a new staging area
git update-index --add new.txt									# add new file to staging area
git write-tree											        # write the staging area out to a tree object
git cat-file -p 0155eb4229851634a0f03eb265b69f5a2d56f341		# display tree object
git read-tree --prefix=bak d8329fc1cc938780ffdd9f94e0d364e0ea74f579		    # read 1st tree object into staging area
git write-tree											        # write the staging area out to a tree object
git cat-file -p 3c4e9cd789d88d8d89c1073707c3585e41b0e614		# display tree object

# blob and tree objects don�t have any information about who saved the "snapshots", when they were saved, or why they were saved.

# Commit objects

echo 'First commit' | git commit-tree d8329f				    # create commit object of 1st tree object (0645a94921492dcb21f2fe7c621f2b456a1818ac)
echo 'Second commit' | git commit-tree 0155eb -p 0645a94		# create commit object of 2nd tree object, 1st commit object as parent (a466f97be75448407c3f2dd46867665bfe6a5081)
echo 'Third commit' | git commit-tree 3c4e9c -p a466f97			# create commit object of 3rd tree object, 2nd commit object as parent (d4dce94d872e260bc7290dd6add4f17e1af9dede)
git cat-file -p d4dce94d872e260bc7290dd6add4f17e1af9dede		# display commit object

# The format of a commit object: it specifies the top-level tree for the snapshot of the project at that point;
# the parent commits if any;
# the author/committer information (which uses your user.name and user.email configuration settings and a timestamp);
# a blank line, and then the commit message.

git log --stat d4dce9							# display commit log history from 3rd commit

# This is essentially what Git does when you run the git add and git commit commands � it stores
# blobs for the files that have changed, updates the index, writes out trees, and writes commit
# objects that reference the top-level trees and the commits that came immediately before them.
# These three main Git objects — the blob, the tree, and the commit — are initially stored as separate files in your .git/objects directory.

# Object storage

# Git first constructs a header which starts by identifying the type of object. Git adds a space followed by the size in bytes of the content, and adding a final null byte
# Git concatenates the header and the data and then calculates the SHA-1 checksum. ( eg. "blob 16\u0000what is up, doc?" -> bd9dbf5aae1a3862dd1526723246b20206e5fc37 )
# Git then compresses the content ("blob 16\u0000what is up, doc?") with zlib.
# Git then writes the zlib-deflated content to an object file in .git/objects (folder name is first 2 characters of SHA-1) (file name is last 38 characters of SHA-1)

# All objects are all stored the same way in Git, just with different types (blob, commit, tree).


# Git references
# References or refs in Git is a simple name that stores an SHA-1 value. References are stored in .git/refs

echo d4dce94d872e260bc7290dd6add4f17e1af9dede > .git/refs/heads/master		# manually store reference 'master' for latest commit
git update-ref refs/heads/master d4dce94d872e260bc7290dd6add4f17e1af9dede	# git safe command to do the same
git log --pretty=oneline master							                    # display commit log history from master reference
git update-ref refs/heads/test a466f97						                # create brach 'test' at 2nd commit
git log --oneline test								                        # display commit log history from 'test' branch

# A branch in Git is simply a pointer/reference to the head commit of a line of work.

# When you run commands like git branch <branch>, Git basically runs that update-ref command to add
# the SHA-1 of the last commit of the branch you�re on into whatever new reference you want to create.

# The HEAD file is a symbolic reference to the branch you�re currently on. By symbolic reference,
# we mean that unlike a normal reference, it contains a pointer to another reference.

cat .git/HEAD					            # display HEAD file content -> "ref: refs/heads/master"
git checkout test				            # switch to 'test' branch
cat .git/HEAD					            # display HEAD file content -> "ref: refs/heads/test"
git symbolic-ref HEAD				        # git command to read value of HEAD
git symbolic-ref HEAD refs/heads/master		# low level command to switch branch
cat .git/HEAD					            # display HEAD file content -> "ref: refs/heads/master"

# When you run git commit, it creates the commit object, specifying the parent of that commit object to be
# whatever SHA-1 value the reference in HEAD points to and updates that SHA-1 value to the new commit object.


# Tags
# A tag object is similar to a commit object (contains a tagger, a date, a message and a pointer.), except it generally points to a commit rather than a tree.
# A tag object is like a branch reference, but it never moves � it always points to the same commit but gives it a friendlier name.

git update-ref refs/tags/v1.0 a466f97be75448407c3f2dd46867665bfe6a5081		# make lightweight tag of 2nd commit - a lightweight tag is just a reference to a commit
cat .git/refs/tags/v1.0								                        # display content (direct reference to commit) -> "a466f97be75448407c3f2dd46867665bfe6a5081"
git tag -a v1.1 d4dce94d872e260bc7290dd6add4f17e1af9dede -m 'Test tag'		# make annotated tag of 3rd commit - annotated tag is a reference to a tag object
cat .git/refs/tags/v1.1								                        # display content (referrence to new tag object) -> "5ce7e8437fd432f222d5386352187bf3f2870b65"
git cat-file -p 5ce7e8437fd432f222d5386352187bf3f2870b65			        # display tag object data


git remote add origin https://github.com/HybridChild/git_TestPrj.git		# add a remote reference called origin
git push origin master								                        # push master branch to remote reference
cat .git/refs/remotes/origin/master						                    # display content of remote reference 'origin'

# Notice that a tag doesn’t need to point to a commit; you can tag any Git object.


# Remotes

git remote add origin https://github.com/HybridChild/git_TestPrj.git        # Add a remote called origin
git push origin master                                                      # push master branch to the remote

# Remote references differ from branches (refs/heads references) mainly in that they’re considered read-only.
# You can git checkout to one, but Git won’t symbolically reference HEAD to one, so you’ll never update it with a commit command.
# Git manages them as bookmarks to the last known state of where those branches were on those servers.


# Packfiles

curl https://raw.githubusercontent.com/mojombo/grit/master/lib/grit/repo.rb > repo.rb	# fetch some "large" file
git add repo.rb										                                    # add file to staging area
git commit -m 'Create repo.rb'								                            # commit changes
git cat-file -p master^{tree}								                            # display resulting tree
git cat-file -s 033b4468fa6b2a9547a70d88d1bbe8bf3f9ed0d5				                # see how large the repo.rb file is -> 22044 (blob object compressed to 8K byte)
echo '# testing' >> repo.rb								                                # modify repo.rb a bit
git commit -am 'Modified repo.rb a bit'							                        # commit change
git cat-file -p master^{tree}								                            # display resulting tree -> repo.rb got new blob object
git cat-file -s b042a60ef7dff760008df33cee372b945b6e884e				                # see how large the repo.rb file is -> 22054 (blob object compressed to 8K byte)

# The initial format in which Git saves objects on disk is called a �loose� object format.
# Occasionally Git packs up several of these objects into a single binary file called a
# �packfile� in order to save space and be more efficient.
# You can manually ask Git to pack up the objects by calling the git gc command

find .git/objects -type f           # display all object files
git gc								# garbage collect
find .git/objects -type f           # display all object files (The objects that remain are the blobs that aren’t pointed to by any commit)

# The packfile is a single file containing the contents of all the objects that were removed from your filesystem.
# The index is a file that contains offsets into that packfile so you can quickly seek to a specific object.
# Although the objects on disk before you ran the gc command were collectively about 15K in size, the new packfile is only 7K.

git verify-pack -v .git/objects/pack/pack-a0174c012a4391cf277157a6332ac36607cc8299.idx      # see what was packed up


# The Refspec
git remote add origin https://github.com/HybridChild/git_TestPrj.git
# Running this command adds a section to your repository’s .git/config file, specifying the name of the remote (origin)
# the URL of the remote repository and the refspec to be used for fetching

# [remote "origin"]
#     url = https://github.com/HybridChild/git_TestPrj.git
#     fetch = +refs/heads/*:refs/remotes/origin/*

# refspec format: fetch = +(optional)<src>:<dst>
# <src> the pattern for references on the remote side
# <dst> where those references will be tracked locally

# If there is a master branch on the server, you can access the log of that branch locally
git log origin/master
git log remotes/origin/master
git log refs/remote/origin/master

# If you want to do a one-time only fetch of the master branch on the remote down to origin/mymaster locally
git fetch origin master:remotes/origin/mymaster

# To create a branch in a namespace/directory
git push origin master:refs/heads/namespace/master
# Automate this by adding the following line in your config file: push = refs/heads/master:refs/heads/namespace/master

# You can also use the refspec to delete references from the remote server
git push origin :testBranch                 # the refspec is <src>:<dst>, by leaving off the <src> part, this basically says to make the topic branch on the remote nothing, which deletes it.
git push origin --delete testBranch         # newer syntax to do the same


# Mainteinance
find .git/refs -type f
git gc                          # The other thing gc will do is pack up your references into a single file; packed-refs
cat .git/packed-refs

# Data recovery
git reset --hard f0c4067054b80a33bf6cfdcf37284832be267267		# Move master branch to earlier commit, effectively losing all newer commits
git reflog								# Git silently records the HEAD to reflog every it changes. (commit, branch, git update-ref)
git log -g								# To see the same information in a much more useful way.
git branch recover-branch 284ec26d79b91b628080f3ba17b47ed238d938fb	# Find the newest commit reference and create branch

