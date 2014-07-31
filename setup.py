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

from setuptools import setup
from os import listdir

APP = ['Uploadur.py']
DATA_FILES = [
  'MainMenu.xib',
  'About.xib',
  'Resources/uploadur.png',
  'Resources/uploadur@2x.png',
  'Resources/uploadur-big.png',
  'Resources/uploadur-dl.png',
  'Resources/uploadur-dl@2x.png',
  'Resources/uploadur-grey.png',
  'Resources/uploadur-grey@2x.png',
  'Resources/uploadur-error.png',
  'Resources/uploadur-error@2x.png',
  'Resources/uploadur-alert.png',
  'Resources/uploadur-alert@2x.png',
]

plist=dict(
        LSUIElement=True,
        NSUserNotificationAlertStyle='banner',
        CFBundleName='Uploadur',
        CFBundleVersion='0.2.1',
        CFBundleIdentifier='selovert.uploadur',
        CFBundleSignature='SBLM',
        NSHumanReadableCopyright="Don't steal this code, please.",
        CFBundleGetInfoString='Uploads screenshots.',
        NSMainNibFile='MainMenu'
    )
OPTIONS = {
  'packages': [ 'requests' ],
  'iconfile':'Resources/uploadur.icns',
  'plist': plist
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
