package com.hackurious.helper
{
	import flash.system.Capabilities;
	import flash.system.System;
	
	public class ConsoleHelper
	{
		
		public static const FIELD_SEPARATOR:String = ": :"
		
		public function ConsoleHelper()
		{
		}
		
		/**
		 * Creates a String of valid time value
		 * @return 			String 		current time as a String using valid hours, minutes, seconds and milliseconds
		 */
		
		public static function getCurrentTime ():String
		{
			var currentDate: Date = new Date();
			
			var currentTime: String = 	"time "
				+ timeToValidString(currentDate.getHours()) 
				+ ":" 
				+ timeToValidString(currentDate.getMinutes()) 
				+ ":" 
				+ timeToValidString(currentDate.getSeconds()) 
				+ "." 
				+ timeToValidString(currentDate.getMilliseconds()) + FIELD_SEPARATOR;
			return currentTime;
		}
		
		/**
		 * Creates a valid time value
		 * @param 	timeValue	Number     	Hour, minute or second
		 * @return 				String 		A valid hour, minute or second
		 */
		
		private static function timeToValidString(timeValue: Number):String
		{
			return timeValue > 9 ? timeValue.toString() : "0" + timeValue.toString();
		}
		
		/**
		 * Checking for primitive types
		 * 
		 * @param 	type				String			type of object
		 * @return 	isPrimitiveType 	Boolean			isPrimitiveType
		 * 
		 */							
		public static function primitiveType (type: String): Boolean
		{
			var isPrimitiveType: Boolean;
			
			switch (type) 
			{
				case "Boolean":
				case "void":
				case "int":
				case "uint":
				case "Number":
				case "String":
				case "undefined":
				case "null":
					isPrimitiveType = true;
					break;			
				default:
					isPrimitiveType = false;
			}
			
			return isPrimitiveType;
		}
		
		/**
		 * Calculates the amount of memory in MB and Kb currently in use by Flash Player
		 * @return 	String		Message about the current value of memory in use
		 *
		 * Tip: For detecting memory leaks in Flash or Flex check out WSMonitor, too.
		 * @see: http://www.websector.de/blog/2007/10/01/detecting-memory-leaks-in-flash-or-flex-applications-using-wsmonitor/ 
		 *
		 */		 
		public static function memorySnapshot():String
		{
			var currentMemValue: uint = System.totalMemory;
			var message: String = 	"Memory Snapshot: " 
				+ Math.round(currentMemValue / 1024 / 1024 * 100) / 100 
				+ " MB (" 
				+ Math.round(currentMemValue / 1024) 
				+ " kb)";
			return message;
		}
		
		public static function isBrowserBased():Boolean {
			return ( Capabilities.playerType == "ActiveX" || Capabilities.playerType == "PlugIn" );
			
		}
		
	}
}