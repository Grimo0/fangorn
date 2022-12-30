package ui;

import hxd.Event;

class TextInput extends h2d.TextInput
{
	override function handleKey(e : Event)
	{
		if (e.cancel || cursorIndex < 0)
			return;

		switch (e.keyCode)
		{
			case K.Z if (K.isDown(K.CTRL) && K.isDown(K.SHIFT)):
				if (redo.length > 0 && canEdit)
				{
					undo.push(curHistoryState());
					setState(redo.pop());
					onChange();
				}
				return;
		}

		super.handleKey(e);
	}
}