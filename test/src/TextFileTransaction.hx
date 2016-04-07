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
