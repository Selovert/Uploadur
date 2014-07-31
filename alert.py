import objc
from AppKit import *
from Foundation import *

class Alert(object):   
    def __init__(self, messageText):
        super(Alert, self).__init__()
        self.messageText = messageText
        self.informativeText = ""
        self.buttons = []
    
    def displayAlert(self):
        alert = NSAlert.alloc().init()
        alert.setMessageText_(self.messageText)
        alert.setInformativeText_(self.informativeText)
        alert.setAlertStyle_(NSInformationalAlertStyle)
        for button in self.buttons:
            alert.addButtonWithTitle_(button)
        NSApp.activateIgnoringOtherApps_(True)
        self.buttonPressed = alert.runModal()

def alert(message="Default Message", info_text="", buttons=["OK"]):    
    ap = Alert(message)
    ap.informativeText = info_text
    ap.buttons = buttons
    ap.displayAlert()
    return ap.buttonPressed