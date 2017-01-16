#!/bin/bash
###################
# Author:  wudi
# Mail: programmerwudi@gmail.com 
# Description: 
# Created Time: 2016-02-14 09:11:54
###################

$MOUNTDIR=?
$DISKNAME=?

sudo mount_ntfs -o rw,nobrowse $DISKNAME $MOUNTDIR

into mountdir

open mountdir



## UMOUNT

sudo umount $MOUNTDIR
