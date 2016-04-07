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
		if (oldPathState != null && document.path != oldPathState)
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