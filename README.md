# undoqueue haxe library #

This library help you to implement your undo/redo functionality.

Below you will see the example for text editor.
Document in the text editor will have two properties: `path` (to file) and `text`.

## Our document (class or struct) ##
typedef TextFile =
{
	var path : String;
	var text : String;
}

## Create struct to say us what can be changed in the document ##
typedef Changes =
{
	?path: Bool,
	?text: Bool
}
```

## Create enum to store changed parts ##
```haxe
enum Operation
{
	PATH(oldPath:String, newPath:String);
	TEXT(oldText:String, newText:String);
}
```

## Implement your own Transaction  ##
```haxe
class TextFileTransaction extends undoqueue.Transaction<Operation>
{
	var document : TextFile;
	
	public function new(document:TextFile, ?operations:Array<Operation>)
	{
		super(operations);
		this.document = document;
	}
	
	override function applyOperation(operation:Operation)
	{
		switch (operation)
		{
			case Operation.PATH(oldPath, newPath):
				document.path = newPath;
				
			case Operation.TEXT(oldText, newText):
				document.text = newText;
		}
	}
	
	override function getReversedOperation(operation:Operation) : Operation
	{
		switch (operation)
		{
			case Operation.PATH(oldPath, newPath):
				return Operation.PATH(newPath, oldPath);
				
			case Operation.TEXT(oldText, newText):
				return Operation.TEXT(newText, oldText);
		}
	}
	
	override function newTransaction(operations:Array<Operation>)
	{
		return new TextFileTransaction(document, operations);
	}
}

## Implement your own UndoQueue  ##
```
class TextFileUndoQueue extends undoqueue.UndoQueue<Changes, Operation>
{
	var document : TextFile;
	
	var oldPathState : String;
	var oldTextState : String;
	
	public function new(document:TextFile)
	{
		super();
		this.document = document;
	}
	
	override function rememberStates(changes:Changes)
	{
		if (oldPathState == null && changes.path) oldPathState = document.path;
		if (oldTextState == null && changes.text) oldTextState = document.text;
	}
	
	override function restoreFromStoredStates()
	{
		if (oldPathState != null) document.path = oldPathState;
		if (oldTextState != null) document.text = oldTextState;
	}
	
	override function clearStoredStates()
	{
		oldPathState = null;
		oldTextState = null;
	}
	
	override function addOperationsFromStoredStates()
	{
		if (oldPathState != null && document.text != oldPathState)
		{
			addOperation(Operation.PATH(oldPathState, document.path));
		}
		if (oldTextState != null && document.text != oldTextState)
		{
			addOperation(Operation.TEXT(oldTextState, document.text));
		}
	}
	
	override function newTransaction()
	{
		return new TextFileTransaction(document);
	}
}
```


## Using result classes in code ##
```haxe
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
```

