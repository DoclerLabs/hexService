package hex.service.stateless;

import hex.control.ICancellable;
import hex.data.ServiceParser;
import hex.service.IService;

/**
 * @author Francis Bourre
 */

interface IStatelessService extends IService extends ICancellable
{
	function getResult() : Dynamic;

	function getRawResult() : Dynamic;
	
	function setParser( parser : ServiceParser ) : Void;
	
	function handleComplete() : Void;
	
	function handleFail() : Void;
	
	function handleCancel() : Void;
	
	function release() : Void;
	
	function removeAllListeners() : Void;
	
	var wasUsed( get, null ) : Bool;
	
	var isRunning( get, null ) : Bool;
	
	var hasCompleted( get, null ) : Bool;
	
	var hasFailed( get, null ) : Bool;
	
	var isCancelled( get, null ) : Bool;
}