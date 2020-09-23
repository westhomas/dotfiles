#!/bin/bash

# Piping fswatch Output to Another Process
#  Very often you wish to not only receive an event, but react to it.  The simplest way to do it is piping fswatch output to another process.
#  Since in Unix and Unix-like file system file names may potentially contain any character but NUL (\0) and the path separator (/), fswatch
#  has a specific mode of operation when its output must be piped to another process.  When the [-0] option is used, fswatch will use the NUL
#  character as record separator, thus allowing any other character to appear in a path.  This is important because many commands and shell
#  builtins (such as read) split words and lines by default using the characters in $IFS, which by default contains characters which may be
#  present (although rarely) in a file name, resulting in a wrong event path being received and processed.
# 
#  Probably the simplest way to pipe fswatch to another program in order to respond to an event is using xargs:
# 
#        $ fswatch -0 [opts] [paths] | xargs -0 -n 1 -I {} [command]
# 
#  -       fswatch -0 will split records using the NUL character.
# 
#  -       xargs -0 will split records using the NUL character. This is required to correctly match impedance with fswatch.
# 
#  -       xargs -n 1 will invoke command every record.  If you want to do it every x records, then use xargs -n x.
# 
#  -       xargs -I {} will substitute occurrences of {} in command with the parsed argument.  If the command you are running does not need
#          the event path name, just delete this option.  If you prefer using another replacement string, substitute {} with yours.


SYNC_PATH=$1
SYNC_DEST_HOST=$2
DEST_PATH=$3

fswatch -0 -or ${SYNC_PATH} | xargs -0 -n 1 -I {} -- rsync -av --delete ${SYNC_PATH} ${SYNC_DEST_HOST}:${DEST_PATH}