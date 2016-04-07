package undoqueue;

import stdlib.Debug;
using StringTools;
using Lambda;

class UndoQueue<Changes, Operation:EnumValue> implements stdlib.AbstractClass
{
	var transactions = new Array<Transaction<Operation>>();
	var equivalentPositions = new Array<{ p1:Int, p2:Int }>();
	var pos = 0;
	var isBeginTransaction = true;
	var savedPos = 0;
	var freezed = false;
	
	function new() {}
	
	/**
	 * This method may be called several times with different operations.
	 */
	@:profile
	public function beginTransaction(changes:Changes)
	{
		if (freezed) return;
		
		log("beginTransaction " + Debug.getDump(changes, 1).replace("\n", " ")/* + "\n" + CallStack.toString(CallStack.callStack())*/);
		
		isBeginTransaction = true;
		
		rememberStates(changes);
	}
	
	@:profile
	public function cancelTransaction()
	{
		if (freezed) return;
		
		revertTransaction();
		forgetTransaction();
	}
	
	@:profile
	public function revertTransaction()
	{
		if (freezed) return;
		
		restoreFromStoredStates();
	}
	
	@:profile
	public function forgetTransaction()
	{
		if (freezed) return;
		
		clearStoredStates();
	}
	
	@:profile
	public function commitTransaction()
	{
		if (freezed) return;
		
		log("commitTransaction");
		
		addOperationsFromStoredStates();
		clearStoredStates();
	}
	
	function addOperation(operation:Operation)
	{
		log("\tadd operation " + operation.getName());
		
		if (pos < transactions.length)
		{
			var i = transactions.length - 1; while (i >= pos)
			{
				transactions.push(transactions[i].getReversed());
				equivalentPositions.push( { p1:i, p2:transactions.length } );
				i--;
			}
			isBeginTransaction = true;
		}
		
		if (isBeginTransaction)
		{
			transactions.push(newTransaction());
			pos = transactions.length;
			isBeginTransaction = false;
		}
		
		transactions[pos - 1].add(operation);
		
		changed();
	}
	
	@:profile
	public function undo()
	{
		commitTransaction();
		if (canUndo())
		{
			log("undo");
			freezed = true;
			transactions[--pos].undo();
			freezed = false;
			changed();
		}
	}
	
	@:profile
	public function redo()
	{
		commitTransaction();
		if (canRedo())
		{
			log("redo");
			freezed = true;
			transactions[pos++].redo();
			freezed = false;
			changed();
		}
	}
	
	public function canUndo() : Bool return pos > 0;
	public function canRedo() : Bool return pos < transactions.length;
	
	public function documentSaved() : Void
	{
		log("documentSaved " + pos);
		savedPos = pos;
	}
	
	public function isDocumentModified() : Bool return !isEquivalentPos(savedPos, pos);
	
	@:noapi
	public function getOperationsFromLastSaveToNow() : Array<Operation>
	{
		log("getOperationsFromLastSaveToNow: transactions = " + transactions.length + "; savedPos = " + savedPos);
		
		var r = [];
		
		var tt = transactions.slice(savedPos);
		if (pos < transactions.length)
		{
			var additional = transactions.slice(pos).map(function(t) return t.getReversed());
			additional.reverse();
			tt = tt.concat(additional);
		}
		
		for (t in tt) r = r.concat(t.operations);
		
		return r;
	}
	
	function isEquivalentPos(p1:Int, p2:Int) : Bool
	{
		if (p1 == p2) return true;
		
		var ep = [ p1 => true ];
		while (true)
		{
			var added = false;
			
			for (epos in equivalentPositions)
			{
				if (ep.exists(epos.p1))
				{
					if (!ep.exists(epos.p2)) { ep.set(epos.p2, true); added = true; }
				}
				else
				if (ep.exists(epos.p2))
				{
					if (!ep.exists(epos.p1)) { ep.set(epos.p1, true); added = true; }
				}
			}
			
			if (!added) break;
		}
		
		return ep.exists(p2);
	}
	
	public function toString()
	{
		var s = "UNDO_QUEUE savedPos = " + savedPos + "; pos = " + pos + "\n";
		s += "\t\t" + transactions.join("\n\t\t");
		return s;
	}
	
	/**
	 * Override to process undo status changing.
	 */
	function changed() {}
	
	function rememberStates(changes:Changes) : Void;
	function restoreFromStoredStates() : Void;
	function clearStoredStates() : Void;
	function addOperationsFromStoredStates() : Void;
	function newTransaction() : Transaction<Operation>;
	
	static function log(v:Dynamic, ?infos:haxe.PosInfos)
	{
		//trace(Reflect.isFunction(v) ? v() : v, infos);
	}
}
