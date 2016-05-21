package hex.service;

import hex.di.IInjectorContainer;
import hex.error.VirtualMethodException;
import hex.event.MessageType;
import hex.service.IService;
import hex.service.ServiceConfiguration;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractService<ServiceConfigurationType:ServiceConfiguration> implements IService<ServiceConfigurationType> implements IInjectorContainer
{
	var _configuration : ServiceConfigurationType;
	
	function new() 
	{
		
	}

	public function getConfiguration() : ServiceConfigurationType
	{
		return this._configuration;
	}
	
	@PostConstruct
	public function createConfiguration() : Void
	{
		throw new VirtualMethodException( this + ".createConfiguration must be overridden" );
	}
	
	public function setConfiguration( configuration : ServiceConfigurationType ) : Void
	{
		throw new VirtualMethodException( this + ".setConfiguration must be overridden" );
	}
	
	public function addHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Bool
	{
		throw new VirtualMethodException( this + ".addHandler must be overridden" );
	}
	
	public function removeHandler( messageType : MessageType, scope : Dynamic, callback : Dynamic ) : Bool
	{
		throw new VirtualMethodException( this + ".removeHandler must be overridden" );
	}
	
	public function removeAllListeners( ):Void
	{
		throw new VirtualMethodException( this + ".removeAllListeners must be overridden" );
	}
	
	public function release() : Void
	{
		throw new VirtualMethodException( this + ".release must be overridden" );
	}
}