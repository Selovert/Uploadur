from setuptools import setup
from os import listdir

APP = ['Uploadur.py']
DATA_FILES = [
  'MainMenu.xib',
  'Resources/uploadur.png',
  'Resources/uploadur@2x.png',
  'Resources/uploadur-dl.png',
  'Resources/uploadur-dl@2x.png',
  'Resources/uploadur-grey.png',
  'Resources/uploadur-grey@2x.png',
  'Resources/uploadur-alert.png',
  'Resources/uploadur-alert@2x.png',
]

plist=dict(
        LSUIElement=True,
        NSUserNotificationAlertStyle='banner',
        CFBundleName='Uploadur',
        CFBundleVersion='0.1.0',
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
