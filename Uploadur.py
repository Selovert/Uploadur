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

import objc, threading, os, subprocess, pickle, sentinel, urllib, urllib2, json
from alert import alert
from Cocoa import *
from Foundation import *
from AppKit import *
from PyObjCTools import AppHelper
from distutils.version import LooseVersion


### Configs ###
# version number
version = NSBundle.mainBundle().objectForInfoDictionaryKey_("CFBundleShortVersionString")
shouldUpgrade = False
upgradeChecked = False
# All our icons and states of those icons
status_images = {
    'icon'       :'uploadur',
    'icon-dl'    :'uploadur-dl',
    'icon-grey'  :'uploadur-grey',
    'icon-error' :'uploadur-error',
    'icon-alert' :'uploadur-alert'
}
# Original Screenshot path
sentinel.tempPath = os.path.expanduser('~/Pictures/Screenshots')
# Final Screenshot Resting Place (archives)
sentinel.archivePath = os.path.expanduser('~/Pictures/Screenshots/Uploaded')
# Imgur Client ID
sentinel.clientID = "f3908f78693871e"
# Imgur Client Secret
sentinel.clientSecret = "80b84cf7f60dfe76c844e34b54075130158a1081"
# Client Refresh Token
sentinel.refreshToken = ''
# Album to save screenshots in:
sentinel.albumName = ''
# Album ID
sentinel.albumID = ''
# Privacy of the Imgur album
sentinel.albumIsPrivate = False
# Title text of uploaded screenshots
sentinel.titleText = "Uploaded using Uploadur"
# Action to take after uploading the image
sentinel.postUpload = 0
# Settings file path
settingsPath = os.path.expanduser('~/.uploadur')
# start on login
autoStart = 0
# development mode
devMode = False

class SettingsWindow(NSWindowController):
    debugButton = objc.IBOutlet()
    tempPathBox = objc.IBOutlet()
    archivePathBox = objc.IBOutlet()
    archivePathButton = objc.IBOutlet()
    archivePathLabel = objc.IBOutlet()
    accountBox = objc.IBOutlet()
    authorizeLabel = objc.IBOutlet()
    authorizeButton = objc.IBOutlet()
    albumBox = objc.IBOutlet()
    logoutButton = objc.IBOutlet()
    albumLabel = objc.IBOutlet()
    loginCheckBox = objc.IBOutlet()
    moveRadio = objc.IBOutlet()
    deleteRadio = objc.IBOutlet()
    nothingRadio = objc.IBOutlet()
    albumPrivacyCheckBox = objc.IBOutlet()
    titleBox = objc.IBOutlet()

    def windowDidLoad(self):
        NSWindowController.windowDidLoad(self)
        self.updateDisplay()
        self.checkUser()

        if devMode:
            self.debugButton.setTransparent_(False)

    @objc.IBAction
    def tempOpen_(self, sender):
        p = self.openFile()
        if p:
            sentinel.tempPath = p
            self.tempPathBox.setStringValue_(sentinel.tempPath)


    @objc.IBAction
    def archiveOpen_(self, sender):
        p = self.openFile()
        if p:
            sentinel.archivePath = p
            self.archivePathBox.setStringValue_(sentinel.archivePath)

    @objc.IBAction
    def authenticate_(self, sender):
        authUrl = sentinel.session.authorization_url('pin')
        subprocess.Popen(['open', authUrl])
        self.logout()

    @objc.IBAction
    def authorize_(self, sender):
        pin = pasteText()
        try:
            sentinel.session.exchange_pin(pin)
            sentinel.refreshToken = sentinel.session.refresh_token
            sentinel.user = sentinel.session.get_user("me")
            self.checkUser()
            alert('Uploadur','Successfully logged in as ' + sentinel.user.name)
        except Exception, e:
            print str(e)
            alert('Uploadur',"Failed to log in.\nMake sure you've copied your PIN to the clipboard!")
            self.accountBox.setStringValue_("Authentication Error")

    @objc.IBAction
    def apply_(self,sender):
        self.saveSettings()
        self.close()
        delegate.restart()

    @objc.IBAction
    def logout_(self,sender):
        self.logout()

    @objc.IBAction
    def manageLogin_(self,sender):
        if self.loginCheckBox.state() is 1:
            self.manageLogin('add')
            alert('Uploadur', 'To enable running Uploadur at login, check the "Uploadur" entry in the list of login items.')
        elif self.loginCheckBox.state() is 0:
            self.manageLogin('remove')

    @objc.IBAction
    def enableArchive_(self,sender):
        self.archivePathBox.setEnabled_(True)
        self.archivePathButton.setEnabled_(True)
        self.archivePathLabel.setTextColor_(NSColor.controlTextColor())

    @objc.IBAction
    def disableArchive_(self,sender):
        self.archivePathBox.setEnabled_(False)
        self.archivePathButton.setEnabled_(False)
        self.archivePathLabel.setTextColor_(NSColor.disabledControlTextColor())

    @objc.IBAction
    def debug_(self,sender):
        pass
        print autoStart
        print self.loginCheckBox.state()

    def logout(self):
        sentinel.refreshToken = ''
        sentinel.user = None
        sentinel.album = None
        sentinel.albumName = ''
        sentinel.albumID = ''
        self.updateDisplay()
        self.accountBox.setStringValue_("Not logged in...")
        self.authorizeButton.setEnabled_(True)
        self.authorizeLabel.setTextColor_(NSColor.controlTextColor())
        self.albumBox.setEnabled_(False)
        self.albumLabel.setTextColor_(NSColor.disabledControlTextColor())
        self.albumPrivacyCheckBox.setEnabled_(False)
        self.logoutButton.setTransparent_(True)

    def checkUser(self):
        if sentinel.user:
            self.accountBox.setStringValue_("Logged in as " + sentinel.user.name)
            self.authorizeButton.setEnabled_(False)
            self.authorizeLabel.setTextColor_(NSColor.disabledControlTextColor())
            self.albumBox.setEnabled_(True)
            self.albumLabel.setTextColor_(NSColor.controlTextColor())
            self.albumPrivacyCheckBox.setEnabled_(True)
            self.logoutButton.setTransparent_(False)

    def checkAlbum(self):
        if (str(sentinel.albumName) is not '') and (sentinel.user):
            album = ''
            albums = sentinel.user.get_albums()
            for a in albums:
              if a.title == sentinel.albumName:
                album = a
                sentinel.albumID = a.id
                print "Album '" + a.title + "' found..."
            if not sentinel.albumID:
                album = sentinel.session.create_album(sentinel.albumName)
                sentinel.albumID = album.id
                print "Album '" + sentinel.albumName + "' not found: creating..."
            if sentinel.albumIsPrivate:
                album.update(privacy = 'hidden')
                print "Made '" + album.title + "' album hidden..."
            elif not sentinel.albumIsPrivate:
                album.update(privacy = 'public')
                print "Made '" + album.title + "' album public..."
        else:
            sentinel.albumName = ''
            sentinel.albumID = ''

    def updatePostUploads(self):
        if sentinel.postUpload == 0:
            self.moveRadio.setState_(True)
            self.deleteRadio.setState_(False)
            self.nothingRadio.setState_(False)
        elif sentinel.postUpload == 1:
            self.moveRadio.setState_(False)
            self.deleteRadio.setState_(True)
            self.nothingRadio.setState_(False)
        elif sentinel.postUpload == 2:
            self.moveRadio.setState_(False)
            self.deleteRadio.setState_(False)
            self.nothingRadio.setState_(True)

    def savePostUploads(self):
        if self.moveRadio.state():
            sentinel.postUpload = 0
        elif self.deleteRadio.state():
            sentinel.postUpload = 1
        elif self.nothingRadio.state():
            sentinel.postUpload = 2

    def checkPostUploads(self):
        move = self.moveRadio.state()
        delete = self.deleteRadio.state()
        nothing = self.nothingRadio.state()
        if move:
            self.archivePathBox.setEnabled_(True)
            self.archivePathButton.setEnabled_(True)
            self.archivePathLabel.setTextColor_(NSColor.controlTextColor())
        elif delete or nothing:
            self.archivePathBox.setEnabled_(False)
            self.archivePathButton.setEnabled_(False)
            self.archivePathLabel.setTextColor_(NSColor.disabledControlTextColor())

    def updateDisplay(self):
        self.tempPathBox.setStringValue_(sentinel.tempPath)
        self.archivePathBox.setStringValue_(sentinel.archivePath)
        self.albumBox.setStringValue_(sentinel.albumName)
        self.titleBox.setStringValue_(sentinel.titleText)
        self.loginCheckBox.setState_(autoStart)
        self.albumPrivacyCheckBox.setState_(sentinel.albumIsPrivate)
        self.updatePostUploads()
        self.checkPostUploads()

    def openFile(self):
        pool = NSAutoreleasePool.alloc().init()
        panel = NSOpenPanel.openPanel()
        panel.setCanCreateDirectories_(True)
        panel.setCanChooseDirectories_(True)
        panel.setCanChooseFiles_(False)
        #… there are lots of options, you see where this is going…
        if panel.runModal() == NSOKButton:
            return panel.directory()
        return 
        pool.drain()
        del pool

    def manageLogin(self, option):
        if option is 'add':
            command = ''' osascript -e '
            tell application "System Preferences" to quit
            tell application "System Events"
              make new login item at end of login items with properties {name:"Uploadur", path:"''' + os.path.abspath(__file__).replace('/Contents/Resources/Uploadur.py','') + '''", hidden:false}
            end tell
            tell application "System Preferences"
              set userPane to pane id "com.apple.preferences.users"
              tell userPane to reveal anchor "startupItemsPref"
              activate
            end tell'
            '''
        elif option is 'remove':
            command = '''osascript -e 'tell application "System Events" to delete every login item whose name is "Uploadur"' '''

        os.system(command)


    def saveSettings(self):
        global autoStart
        sentinel.tempPath = self.tempPathBox.stringValue()
        sentinel.archivePath = self.archivePathBox.stringValue()
        sentinel.albumName = self.albumBox.stringValue()
        sentinel.albumIsPrivate = self.albumPrivacyCheckBox.state()
        sentinel.titleText = self.titleBox.stringValue()
        autoStart = int(self.loginCheckBox.state())
        self.checkAlbum()
        self.savePostUploads()
        settings = {'tempPath':sentinel.tempPath, 'archivePath':sentinel.archivePath, 'refreshToken':sentinel.refreshToken, 'albumName':sentinel.albumName, 'albumID':sentinel.albumID, 'albumIsPrivate':sentinel.albumIsPrivate, 'autoStart':autoStart, 'postUpload':sentinel.postUpload, 'titleText':sentinel.titleText}
        with open(settingsPath, 'wb') as f:
            pickle.dump(settings, f)
        print "Saved settings to " + settingsPath + "..."

class SystemNotification(NSObject):
    def notify(self, title, message, link = 0):
        notification = NSUserNotification.alloc().init()
        notification.setTitle_(title)
        notification.setInformativeText_(message)
        notification.setUserInfo_({'link':link})
     
        center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.setDelegate_(self)
        center.deliverNotification_(notification)

    def userNotificationCenter_shouldPresentNotification_(self, center, notification):
            return True

    def userNotificationCenter_didActivateNotification_(self, center, notification):
        info = notification.userInfo()
        link = info['link']
        if link:
            subprocess.Popen(['open', link])

class Menu(NSObject):
    # inits
    images = {}
    statusbar = None
    URL = ''
    currentImage = False

    # Initialize the notification center object
    notification = SystemNotification.alloc().init()
    # The current icon (when not loading or otherwise engaged)
    default_icon = 'icon'

    def applicationDidFinishLaunching_(self, notification):
        statusbar = NSStatusBar.systemStatusBar()
        # Create the statusbar item
        self.statusitem = statusbar.statusItemWithLength_(NSVariableStatusItemLength)
        # Load all images
        for i in status_images.keys():
          self.images[i] = NSImage.imageNamed_(status_images[i])
        # Set initial image
        self.changeIcon(self.default_icon, True)
        # Let it highlight upon clicking
        self.statusitem.setHighlightMode_(1)
        # Set a tooltip
        self.statusitem.setToolTip_('Uploadur')
        # Build a very simple menu
        self.menu = NSMenu.alloc().init()
        self.menu.setDelegate_(self)
        # Initialize the servers submenu
        self.infoMenu = NSMenu.alloc().init()
        self.infoMenu.setDelegate_(self)
        # stop items from becoming selectable when they are not
        self.menu.setAutoenablesItems_(False)

        # About window
        self.aboutItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('About', 'about:', '')
        self.menu.addItem_(self.aboutItem)

        # Check for app upgrade
        self.checkUpgradeItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Check for Update', 'checkUpdate:', '')
        self.menu.addItem_(self.checkUpgradeItem)

        # App Upgrade
        self.addUpgradeItem()

        #Separator for the About window
        self.aboutSeparator = NSMenuItem.separatorItem()
        self.menu.addItem_(self.aboutSeparator)

        # Info bits!
        self.infoItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Idle...', 'info:', '')
        self.infoItem.setEnabled_(False)
        self.menu.addItem_(self.infoItem)
        self.infoItem.setSubmenu_(self.infoMenu)

        # Populate info submenu
        self.imageItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('', 'info:', '')
        self.infoMenu.addItem_(self.imageItem)

        if devMode:
            self.debug = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Debug', 'debug:', '')
            self.menu.addItem_(self.debug)

        #Separator for the functions/settings
        self.preSettingsSeparator = NSMenuItem.separatorItem()
        self.menu.addItem_(self.preSettingsSeparator)

        # Settings menu
        self.settingsItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Settings', 'settings:', '')
        self.menu.addItem_(self.settingsItem)

        #Separator for the functions/settings
        self.postSettingsSeparator = NSMenuItem.separatorItem()
        self.menu.addItem_(self.postSettingsSeparator)

        # Default event
        self.quitItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Quit', 'terminate:', '')
        self.menu.addItem_(self.quitItem)
        # Bind it to the status item
        self.statusitem.setMenu_(self.menu)
        # Start the sentinel
        self.start()

    def changeIcon(self, iconName, default = False):
        global default_icon
        self.statusitem.setImage_(self.images[iconName])
        if default:
            self.default_icon = iconName

    def copyText(self, s):
        pb = NSPasteboard.generalPasteboard()
        pb.declareTypes_owner_([NSStringPboardType], None)
        newData = NSString.stringWithString_(s).nsstring().dataUsingEncoding_(NSUTF8StringEncoding)
        pb.setData_forType_(newData, NSStringPboardType)

    def updateCurrentImage(self, path):
        size = NSSize()
        self.currentImage = NSImage.alloc().initWithContentsOfFile_(path)
        oldWidth = self.currentImage.size().width
        oldHeight = self.currentImage.size().height

        if (oldWidth > 300) or (oldHeight > 300):
            if oldHeight < oldWidth:
                width = 300
                height = oldHeight / (oldWidth / 300)
            else:
                height = 300
                width = oldWidth / (oldHeight / 300)
            size.width = width
            size.height = height
            self.currentImage.setSize_(size)
        self.imageItem.setImage_(self.currentImage)

    def start(self):
        global e
        global t

        if threading.activeCount() < 4:
            print "Starting monitor loop..."
            sentinel.run = True
            e = threading.Event()
            t = threading.Thread(target=sentinel.runLoop, args=(e,self))
            t.daemon = True
            t.start()
            self.r = threading.Timer(1500.0, self.restart, args=(True,))
            self.c = threading.Timer(1400.0, self.checkUpdate)
            self.r.start()
            self.c.start()

    def restart(self, scheduled = False):
        sentinel.run = False
        t.join()
        self.r.cancel()
        self.c.cancel()
        if scheduled:
            print "Scheduled restart proceeding..."
        print str(t) + " ended...\n"
        self.start()

    def checkForUpdate(self):
        global shouldUpgrade
        try:
            siteVersion = json.loads(urllib2.urlopen("https://api.github.com/repos/selovert/Uploadur/releases").read())[0]['tag_name']
        except:
            siteVersion = '0'
        if LooseVersion(siteVersion) > LooseVersion(version):
            self.notification.notify('Uploadur', 'Update available')
            print "Update to " + siteVersion + " available..."
            shouldUpgrade = True
        else: 
            print "No update available..."

    def addUpgradeItem(self, scheduled = False):
        global upgradeChecked
        if shouldUpgrade:
            self.changeIcon('icon-alert', True)
            self.upgradeItem = NSMenuItem.alloc().initWithTitle_action_keyEquivalent_('Update', 'update:', '')
            self.menu.addItem_(self.upgradeItem)
            self.menu.removeItem_(self.checkUpgradeItem)
        elif upgradeChecked and not scheduled:
            self.notification.notify('Uploadur', version + ' is the current version!')
        upgradeChecked = True

    def info_(self, sender):
        if self.URL is not '':
            subprocess.Popen(['open', self.URL])

    def settings_(self, sender):
        global settingsViewController
        settingsViewController = SettingsWindow.alloc().initWithWindowNibName_("MainMenu")
        # Show the window
        settingsViewController.showWindow_(settingsViewController)
        settingsViewController.ReleasedWhenClosed = True
        # Bring app to top
        NSApp.activateIgnoringOtherApps_(True)

    def about_(self, sender):
        global aboutViewController
        aboutViewController = AboutWindow.alloc().initWithWindowNibName_("About")
        # Show the window
        aboutViewController.showWindow_(aboutViewController)
        aboutViewController.ReleasedWhenClosed = True
        # Bring app to top
        NSApp.activateIgnoringOtherApps_(True)

    def checkUpdate_(self, sender):
        self.checkForUpdate()
        self.addUpgradeItem()

    def checkUpdate(self):
        self.checkForUpdate()
        self.addUpgradeItem(True)

    def update_(self, sender):
        pass
        self.statusitem.setEnabled_(False)
        def upgrade(self):
            filePath = os.path.expanduser('~/Downloads/Uploadur.zip')
            url = json.loads(urllib2.urlopen("https://api.github.com/repos/selovert/Uploadur/releases").read())[0]['assets'][0]['browser_download_url']
            urllib.urlretrieve (url, filePath)
            print "Download complete..."
            os.chdir("../../../")
            subprocess.call(["rm","-rf","Uploadur.app"])
            subprocess.call(["unzip",filePath,"-d","."])
            subprocess.call(["rm","-rf",filePath])
            os.system("sleep 2 && open Uploadur.app &")
            print "Restarting..."
            AppHelper.stopEventLoop()
        t = threading.Thread(target=upgrade, args=(self,))
        t.daemon = True
        t.start()

    def debug_(self, sender):
        print "AAAAAHHH"
        print autoStart

class AboutWindow(NSWindowController):
    versionLabel = objc.IBOutlet()

    def windowDidLoad(self):
        NSWindowController.windowDidLoad(self)
        self.versionLabel.setStringValue_("Version " + version)

    @objc.IBAction
    def source_(self, sender):
        subprocess.Popen(['open', "https://github.com/Selovert/Uploadur"])

def loadSettings():
    global autoStart
    with open(settingsPath, 'r') as f:
        settings = pickle.load(f)
        sentinel.tempPath = settings['tempPath']
        sentinel.archivePath = settings['archivePath']
        sentinel.refreshToken = settings['refreshToken']
        sentinel.albumName = settings['albumName']
        sentinel.albumID = settings['albumID']
        sentinel.albumIsPrivate = settings['albumIsPrivate']
        autoStart = settings['autoStart']
        sentinel.postUpload = settings['postUpload']
        sentinel.titleText = settings['titleText']

def pasteText():
    return NSPasteboard.generalPasteboard().stringForType_(NSStringPboardType)

if __name__ == "__main__":
    global delegate
    print "Starting app..."
    if os.path.isfile(settingsPath): 
        loadSettings()
        print "Settings loaded from " + settingsPath + "..."
    app = NSApplication.sharedApplication()
    delegate = Menu.alloc().init()
    delegate.checkForUpdate()
    NSApp().setDelegate_(delegate)
    AppHelper.runEventLoop()

