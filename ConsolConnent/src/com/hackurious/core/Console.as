/**
	* Logging Flex and Flash projects using Console available in Firebug in Firefox, Console in Chrome and Safari, DragonFly in Opera
* 
* @version	0.1
* @date		07/07/2012
*
* @author	Ashwinee Dash [www.hackurious.org]
*
* Influenced by ThunderBoltAS3 version 2.2
* @see		http://www.websector.de/blog/category/thunderbolt/
* @see		http://code.google.com/p/flash-thunderbolt/
* @source	http://flash-thunderbolt.googlecode.com/svn/trunk/as3/
* 
*/

package com.hackurious.core
{
	import com.hackurious.helper.ConsoleHelper;
	
	import flash.external.ExternalInterface;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	
	public class Console
	{
		
		// constants
		
		public static const INFO: String = "info";
		public static const WARN: String = "warn";
		public static const ERROR: String = "error";
		public static const LOG: String = "log";
		
		public static const CONSOLE_METHODS: Array = [INFO, WARN, ERROR, LOG];
		
		private static const GROUP_START: String = "group";
		private static const GROUP_END: String = "groupEnd";
		private static const MAX_DEPTH: int = 255;
		private static const VERSION: String = "0.1";
		private static const AUTHOR: String = "Ashwinee Dash"
			
		
		
		// private vars	
		private static var _stopLog: Boolean = false;
		private static var _depth: int;	
		private static var _logLevel: String;
		private static var isOperaOld:Boolean = false;
		private static var _hide: Boolean = false;
		private static var _firstRun: Boolean = true;
		private static var _firebug: Boolean = false;	
		private static var _console:Boolean = false;
		
		// public vars
		public static var includeTime: Boolean = true;
		public static var showCaller: Boolean = true;
		
				
		/**
		 * Logs error messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */	
		public static function error(message:String, ...logObjects):void {
			
			Console.log(message, Console.ERROR, logObjects);
		}
		
		/**
		 * Logs warn messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */	
		public static function info(message:String, ...logObjects):void {
			Console.log(message, Console.INFO, logObjects);
		}
		
		/**
		 * Logs messages including objects in console based on the type of method provided. Four type of methods are available i.e. Console.INFO,
		 * Console.LOG, Console.ERROR and Console.WARN.
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */
		public static function $(...messages):void {
			
			var msg:String = "" ;
			var logObjects:Array = [];
			var method:String = Console.LOG;
			if (messages != null && messages.length > 0)
			{
				var i: int = 0, l: int = messages.length;	 	
				for (i = 0; i < l; i++) 
				{
					if (getQualifiedClassName(messages[i]) == "String" || getQualifiedClassName(messages[i]) == "Number" || getQualifiedClassName(messages[i]) == "int") 
					{
						if (messages[i] == CONSOLE_METHODS[0] || messages[i] == CONSOLE_METHODS[1] || messages[i] == CONSOLE_METHODS[2] || messages[i] == CONSOLE_METHODS[3]) 
						{
							method = messages[i];
						} else {
							msg += messages[i]
						}
					}else  {
						logObjects.push(messages[i])
					}
				}					
			} else {
				msg = "From console with <3 :: " ;
				logObjects= null;
			}		
			

			if (method.toLowerCase() == Console.LOG ) {
							
				Console.log(msg, Console.LOG, logObjects);
							
			} else if (method.toLowerCase() == Console.INFO) {
					
				Console.log(msg, Console.INFO, logObjects);
			
			} else if (method.toLowerCase() == Console.WARN) {
				
				Console.log(msg, Console.WARN, logObjects);
			
			} else if ( method.toLowerCase() == Console.ERROR) {
				Console.log(msg, Console.ERROR, logObjects);
			
			} else {
				//				
			}
			
		} 
		
		/**
		 * Logs warn messages including objects for calling Firebug
		 * 
		 * @param 	msg				String		log message 
		 * @param 	logObjects		Array		Array of log objects using rest parameter
		 * 
		 */	
		
		public static function warn(message:String, ...logObjects):void {
			Console.log(message, Console.WARN, logObjects);
		}
		
		/**
		 * Hides the logging process calling Firebug
		 * @param 	value	Boolean     Hide or show the logs of ThunderBolt within Firebug. Default value is "false"
		 */		 
		public static function set hide(value: Boolean):void
		{
			_hide = value;
		}
		
		/**
		 * Flag to use console trace() methods
		 * @param 	value	Boolean     Flag to use Firebug or not. Default value is "true".
		 */		 
		public static function set console(value: Boolean):void
		{
			_firstRun = false;
			_console = !value;
		}
		
		
		private static function get isConsoleAvailable():Boolean 
		{
			var isBrowser:Boolean = ConsoleHelper.isBrowserBased();
		
			if ( isBrowser && ExternalInterface.available)
			{
				
				var requiredMethodsCheck:String = "";
				for each (var method:String in CONSOLE_METHODS) {
					// Most browsers report typeof function as 'function'
					// Internet Explorer reports typeof function as 'object'
					requiredMethodsCheck += " && (typeof console." + method + " == 'function' || typeof console." + method + " == 'object') "
				}
				try
				{
					if ( ExternalInterface.call( "function(){ return typeof window.console == 'object' " + requiredMethodsCheck + "}" ) )
						return true;
					
				}
				catch (error:SecurityError)
				{
					return false;
				}
			}
			
			return false;
		}
		
		private function get isOperaOld():Boolean {
			var isBrowser:Boolean = ConsoleHelper.isBrowserBased();
		
			if (!isConsoleAvailable && isBrowser && ExternalInterface.available) {
			
				try {
				// prior to Opeara 10.5 console is not supported in Opera
				if(ExternalInterface.call( "function(){ if (typeof opera == 'object') { return window.console != 'object' } } "))
					return true;
				} catch (error:SecurityError) {
					return false;
				}
			}
			return false;
		}
		/**
		 * Calls Firebugs command line API to write log information
		 * 
		 * @param 	level		String			log level 
		 * @param 	msg			String			log message 
		 * @param 	logObjects	Array			Array of log objects
		 */			 
		public static function log (msg: String, level: String,  logObjects: Array = null): void
		{
			if(!_hide)
			{
				// at first run check
				// using browser or not and check if firebug is enabled
				if (_firstRun)
				{
					_console = isConsoleAvailable;
					_firstRun = false;
				}
				
				_depth = 0;
				// get log level
				_logLevel = level;
				// log message
				var logMsg: String = "";
				// add time	to log message
				if (includeTime) 
					logMsg += ConsoleHelper.getCurrentTime();
				
				// get package and class name + line number
				// using getStackTrace(); 
				// @see: http://livedocs.adobe.com/flex/3/langref/Error.html#getStackTrace()
				// Note: For using it the Flash Debug Player has to be installed on your machine!
				if ( showCaller ) 
					logMsg += logCaller();            
				
				
				// add message text to log message
				logMsg += msg;
				
				// send message	to the logging system
				Console.call( logMsg );
				
				// log objects	
				if (logObjects != null)
				{
					var i: int = 0, l: int = logObjects.length;	 	
					for (i = 0; i < l; i++) 
					{
						Console.logObject(logObjects[i]);
					}					
				}				
			}
			
		}
		
		/**
		 * Logs nested instances and properties
		 * 
		 * @param 	logObj		Object		log object
		 * @param 	id			String		short description of log object
		 */	
		private static function logObject (logObj:*, id:String = null): void
		{				
			if ( _depth < Console.MAX_DEPTH )
			{
				++ _depth;
				
				var propID: String = id || "";
				var description:XML = describeType(logObj);				
				var type: String = description.@name;
				
				if (ConsoleHelper.primitiveType(type))
				{					
					var msg: String = (propID.length) 	? 	"[" + type + "] " + propID + " = " + logObj
						: 	"[" + type + "] " + logObj;
					
					Console.call( msg );
				}
				else if (type == "Object")
				{
					Console.callGroupAction( GROUP_START, "[Object] " + propID);
					
					for (var element: String in logObj)
					{
						logObject(logObj[element], element);	
					}
					Console.callGroupAction( GROUP_END );
				}
				else if (type == "Array")
				{
					Console.callGroupAction( GROUP_START, "[Array] " + propID );
					
					var i: int = 0, max: int = logObj.length;					  					  	
					for (i; i < max; i++)
					{
						logObject(logObj[i]);
					}
					
					Console.callGroupAction( GROUP_END );
					
				}
				else
				{
					// log private props as well - thx to Rob Herman [http://www.toolsbydesign.com]
					var list: XMLList = description..accessor;					
					
					if (list.length())
					{
						for each(var item: XML in list)
						{
							var propItem: String = item.@name;
							var typeItem: String = item.@type;							
							var access: String = item.@access;
							
							// log objects && properties accessing "readwrite" and "readonly" only 
							if (access && access != "writeonly") 
							{
								//TODO: filter classes
								// var classReference: Class = getDefinitionByName(typeItem) as Class;
								var valueItem: * = logObj[propItem];
								Console.logObject(valueItem, propItem);
							}
						}					
					}
					else
					{
						Console.logObject(logObj, type);					
					}
				}
			}
			else
			{
				// call one stop message only
				if (!_stopLog)
				{
					Console.call( "STOP LOGGING: More than " + _depth + " nested objects or properties." );
					_stopLog = true;
				}			
			}									
		}
		
		/**
		 * Call to Javacsript console or Opera postError
		 * use the standard trace method logging by flashlog.txt
		 * 
		 * @param 	msg			 String			log message
		 * 
		 */							
		private static function call (msg: String = ""): void
		{
			if ( _console)
				ExternalInterface.call("console." + _logLevel, msg);		
			else
				trace ( _logLevel + " " + msg);
			if (isOperaOld) // Prior to Opera 10.5 postError method is used to send info to console
				ExternalInterface.call("opera.postError", msg);
		}
		
		
		/**
		 * Calls an action to open or close a group of log properties
		 * 
		 * @param 	groupAction		String			Defines the action to open or close a group 
		 * @param 	msg			 	String			log message
		 * 
		 */
		private static function callGroupAction (groupAction: String, msg: String = ""): void
		{
			if ( _console )
			{
				if (groupAction == GROUP_START) 
					ExternalInterface.call("console.group", msg);		
				else if (groupAction == GROUP_END)
					ExternalInterface.call("console.groupEnd");			
				else
					ExternalInterface.call("console." + Console.ERROR, "group type has not defined");	
			}
			else
			{
				if (groupAction == GROUP_START) 
					trace( _logLevel + "." + GROUP_START + " " + msg);		
				
				else if (groupAction == GROUP_END)
					trace( _logLevel + "." + GROUP_END + " " + msg);		
				
				else
					trace ( ERROR + "group type has not defined");	
				
			}
		}
		
		/** 
		 * Get details of a caller of the log message
		 * which based on Jonathan Branams MethodDescription.createFromStackTrace();
		 * 
		 * @see: http://github.com/jonathanbranam/360flex08_presocode/
		 * 
		 */
		private static function stackDataFromStackTrace(stackTrace: String): StackData
		{
			// Check stackTrace
			// Note: It seems that there some issues to match it using Flash IDE, so we use an empty Array instead
			var matches:Array = stackTrace.match(/^\tat (?:(.+)::)?(.+)\/(.+)\(\)\[(?:(.+)\:(\d+))?\]$/)
				|| new Array(); 				
			
			var stackData: StackData = new StackData();		
			stackData.packageName = matches[1] || "";
			stackData.className = matches[2] || "";
			stackData.methodName = matches[3] || "";
			stackData.fileName = matches[4] || "";
			stackData.lineNumber = int( matches[5] ) || 0;	
			
			return stackData;
			
		}	    
		/** 
		 * Message about details of a caller who logs anything
		 * @return String	message of details
		 */
		private static function logCaller(): String
		{
			var debugError: Error;
			var message: String = '';
			
			try {
				var errorObject: Object;
				errorObject.halli = "galli";
			} 
			catch( error: Error )
			{
				debugError = new Error();
			}
			finally
			{
				var stackTrace:String = debugError.getStackTrace();
				// track all stacks only if we have a stackTrace
				if ( stackTrace != null )
				{
					var stacks:Array = stackTrace.split("\n");
					
					if ( stacks != null )
					{
						var stackData: StackData;
						
						// stacks data for using Logger 
						
						/* 		    			trace ("stacks.length " + stacks.length); */
						
						if ( stacks.length >= 5 )
							stackData = Console.stackDataFromStackTrace( stacks[ 4 ] );
						
						// special stack data for using ThunderBoldTarget which is a subclass of mx.logging.AbstractTarget
						if ( stackData.className == "AbstractTarget" &&  stacks.length >= 9 ) // needs removal
							stackData = Console.stackDataFromStackTrace( stacks[ 8 ] ); // needs removal
						
						// show details of stackData only if it available
						if ( stackData != null )
						{
							/* 							trace ("stackData " + stackData.toString() );  */
							
							message += ( stackData.packageName != "") 
								? stackData.packageName + "."
								: stackData.packageName;
							
							message += stackData.className;
							
							if ( stackData.lineNumber > 0  )
								message += " [" + stackData.lineNumber + "]" + ConsoleHelper.FIELD_SEPARATOR;
						}							    		
					}  		    			
				}               
			}
			
			
			return message;	
		}	    
	}


		
	
	}
/**
 * Stackdata for storing all data throwing by an error
 * 
 */

internal class StackData
{
	public var packageName: String;
	public var className: String;
	public var methodName: String;
	public var fileName: String;
	public var lineNumber: int;
	
	public function toString(): String
	{
		var s: String = "packageName " + packageName
			+ " // className " + className
			+ " // methodName " + methodName
			+ " // fileName " + fileName
			+ "// lineNumber " + lineNumber;
		return s;
		
	}
}
