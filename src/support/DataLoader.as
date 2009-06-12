package support {
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*
	
	public class DataLoader {
		
		protected var loader:URLLoader;
		
		// data
		public var dataPath:String;
		public var dataType:String;
		public var xmlData:XML;
		public var htmlData:String;
		
		// reference
		public var app:*;
		public var onLoad:Function;
		
		// INIT ////////////////////////////////////////////////////////////////
		public function DataLoader(options:Object) {
			
			dataType		= options.dataType;		// type: XML or HTML
			dataPath 		= options.dataPath;		// path of requested data
			app 			= options.app;			// requester of the data, used for the callback method
			onLoad			= options.onLoad;		// method to call on the app object once loading is complete
		}
		
		// LOAD DATA //////////////////////////////////////////////////////////
		public function loadData():void {
			
			var urlRequest:URLRequest = new URLRequest(dataPath);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			loader.addEventListener(Event.COMPLETE, loadDataComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadDataError);
			
			loader.load(urlRequest);
		}

		// LOAD and RETURN ///////////////////////////////////////////////////
		private function loadDataComplete (event:Event):void { 
		
			switch (dataType) {
				
				case "XML":
					xmlData = new XML(loader.data);
					onLoad.call(app, xmlData);
					break;
				
				case "HTML":
					htmlData = new String(loader.data);
					onLoad.call(app, htmlData);
					break;
			}
		}
		
		// ON LOAD ERROR //////////////////////////////////////////////////////
		private function loadDataError (event:Event):void {
			throw new Error("* Error loading the specified " + dataType + " file from: " + dataPath);
		}
	}
}
