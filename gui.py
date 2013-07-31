#  This is a file to do a super simple GUI.
#  Before I integrate it w/ the actual map thing, I want it to just start w/ angles of 0
#  and then let you hit an arrow button and display the angles.

import Tkinter
from Tkconstants import *
from numpy import *
from graphics import *

#  No idea what this does.
tk = Tkinter.Tk()

#  Frames are windows?
frame = Tkinter.Frame(tk, relief=RIDGE, borderwidth = 2)
frame.pack(fill = BOTH, expand = 1)

#  Labels??
#  This label must be applied to the frame called "frame"
label = Tkinter.Label(frame, text = "blllaaaaaaaaaaa")
label.pack(fill = X, expand = 1)

#  This puts a button on the frame 'frame', with a tex saying "Exit" that performs the command "command" when pressed, which in thise case is tk.destroy., destroying the tk environment called tk, which I guess holds everything.
button = Tkinter.Button(frame, text = "Exit", command = tk.destroy)
button.pack(side=BOTTOM)

#  Cool.  I think this works.  Now I want to add a display of x,y,z.
angleX = 0
angleY = 0
angleZ = 0


    

buttonX = Tkinter.Button(frame, text = ("Increase AngleX: ", angleX), command = "angleX = 4")
buttonX.pack(side=LEFT)

#  Start it.
tk.mainloop()
