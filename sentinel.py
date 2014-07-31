# Uploadur: Uploads OSX Screenshots to Imgur.
# Copyright (C) 2014  Tassilo Selover-Stephan

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Contact Tassilo@selover.net for any questions

import os, time, pyimgur, urllib2, subprocess

import threading

def runLoop(e,menu):
  global run
  menu.changeIcon('icon-grey')
  menu.statusitem.setEnabled_(False)

  try:
    startup()
    print "Monitoring " + tempPath + "..."
    oldCount = len(os.listdir(tempPath))
    menu.changeIcon(menu.default_icon)
  except Exception, e:
    menu.notification.notify('Uploadur', "Error: " + str(e))
    print e
    run = False
    menu.r.cancel()
    menu.r = threading.Timer(5, menu.restart)
    menu.r.start()
    menu.changeIcon('icon-error')

  menu.statusitem.setEnabled_(True)

  while run:
    files = listScreenshots(tempPath)
    if len(files) > oldCount:
      try:
        print files[0] + " found. Uploading..."
        uploadWrapper(files[0], menu)
      except Exception, e:
        print str(e)
        menu.notification.notify('Uploadur', "Upload failed: " + str(e))
        menu.changeIcon(menu.default_icon)
    oldCount = len(files)
    time.sleep(2)

def uploadWrapper(image, menu):
  imagePath = tempPath+"/"+image
  imageArchivePath = archivePath+"/"+image
  menu.changeIcon('icon-dl')
  if internet_on():
    result = upload(imagePath, titleText)
    if result:
      print "Upload successful: " + result.link + "..."
      menu.copyText(result.link)
      menu.updateCurrentImage(imagePath)
      manageFile(image,imagePath,imageArchivePath)
      menu.changeIcon(menu.default_icon)
      menu.infoItem.setEnabled_(True)
      menu.infoItem.setTitle_('Last Upload')
      menu.URL = result.link
      menu.notification.notify('Uploadur', "Uploaded to " + result.link, result.link)
  else:
    menu.notification.notify('Uploadur', "Upload failed: no internet connection.")
    menu.changeIcon(menu.default_icon)

def upload(path, title):
  if album and user:
    print "Uploading to album: " + album.title + "..."
    return session.upload_image(path, title = title, album=album)
  elif user:
    print "Uploading to user: " + user.name + "..."
    return session.upload_image(path, title = title)
  else:
    print "Uploading anonymously..."
    return session.upload_image(path, title = title)

def manageFile(image,imagePath,imageArchivePath):
  if postUpload == 0:
    os.rename(imagePath,imageArchivePath)
    print "Moved " + image + " to " + imageArchivePath + "..."
  elif postUpload == 1:
    os.remove(imagePath)
    print "Removed " + image + "..."
  elif postUpload == 2:
    print "Did nothing with " + image + "..."

def startup():
  global session
  global user
  global album

  user = None
  album = None

  if not os.path.isdir(tempPath):
    os.mkdir(tempPath)
  if not os.path.isdir(archivePath):
    os.mkdir(archivePath)

  currentPath = os.popen("defaults read com.apple.screencapture location").read().rstrip()
  if currentPath != tempPath:
    os.system("defaults write com.apple.screencapture location " + tempPath)
    os.system("killall SystemUIServer")

  session = pyimgur.Imgur(clientID,clientSecret)
  if refreshToken is not '':
    session.refresh_token = refreshToken
    session.refresh_access_token()
    user = session.get_user("me")
    print "User '" + user.name + "' logged in..."

  if albumID is not '':
    album = session.get_album(albumID)
    print "Found " + album.privacy + " album of title '" + album.title + "' and ID '" + album.id + "'..."

def internet_on():
  try:
      response=urllib2.urlopen('http://74.125.228.100',timeout=1)
      return True
  except urllib2.URLError as err: pass
  return False


def listScreenshots(path):
    reply = os.popen('ls -t ' + path + ' | grep "Screen Shot"')
    result = reply.read()
    return result.split("\n")
