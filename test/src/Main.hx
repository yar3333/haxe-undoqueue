class Main
{
	static function main()
	{
		var doc : TextFile = loadDocument();
		var undoQueue = new TextFileUndoQueue(doc);
		
		undoQueue.beginTransaction({ path:true });
			// here - changing `doc.path`
		if (isPathValid(doc.path)) undoQueue.commitTransaction();
		else                       undoQueue.cancelTransaction(); // revert + forget
		
		undoQueue.beginTransaction({ text:true });
			// here - operations with doc.text
		undoQueue.commitTransaction();
		
		// user save file - we must notify undoQueue:
		undoQueue.documentSaved();
		
		trace("Document was modified from last save: " + undoQueue.isDocumentModified());
		
		if (undoQueue.canUndo()) undoQueue.undo();
		if (undoQueue.canRedo()) undoQueue.redo();
	}
	
	static function loadDocument()
	{
		return { path:"c:/temp/doc.txt", text:"Abc def." };
	}
	
	static function isPathValid(s:String) return true;
}