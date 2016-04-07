package undoqueue;

import stdlib.Debug;

class Transaction<Operation:EnumValue> implements stdlib.AbstractClass
{
	public var operations(default, null) : Array<Operation>;
	
	function new(?operations:Array<Operation>)
	{
		this.operations = operations != null ? operations : [];
	}
	
	public function add(operation:Operation)
	{
		operations.push(operation);
	}
	
	public function redo()
	{
		Debug.assert(operations.length > 0);
		
		for (operation in operations)
		{
			applyOperation(operation);
		}
	}
	
	public function undo()
	{
		Debug.assert(operations.length > 0);
		
		var i = operations.length - 1; while (i >= 0)
		{
			applyOperation(getReversedOperation(operations[i--]));
		}
	}
	
	public function getReversed() : Transaction<Operation>
	{
		var ops = operations.map(getReversedOperation);
		ops.reverse();
		return newTransaction(ops);
	}
	
	function applyOperation(operation:Operation) : Void;
	
	function getReversedOperation(operation:Operation) : Operation;
	
	function newTransaction(operations:Array<Operation>) : Transaction<Operation>;
	
	public function toString() return operations.map(function(op) return Type.enumConstructor(op)).join(", ");
	
	static function log(v:Dynamic, ?infos:haxe.PosInfos)
	{
		//trace(Reflect.isFunction(v) ? v() : v, infos);
	}
}