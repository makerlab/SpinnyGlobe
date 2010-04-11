package UI {
	
	// associates to "WinDisplay" MC graphic in meadanglobe.fla library
	
	import flash.display.*;
	import flash.text.*;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.DropShadowFilter;
//	import fl.video.*;
	import support.DataLoader;
	
	public class WinDisplay extends MovieClip {
		
		// reference
		public var appNode:*;
		public var app:*;
		
		// content
		public var winMode:String;
		private var winData:Object;
		private var title:String;
		private var contentPath:String;
		
		// properties
		private var winWidth:Number 		= 300;
		private var winHeight:Number		= 200;
		
		// display
		private var output:TextField;
//		private var videoPlayer:FLVPlayback;
		private var colorCode:uint;
		
		
		// WIN DISPLAY /////////////////////////////////////////////////////////////// 
		public function WinDisplay(winData:Object):void {
			
			// content
			winMode			= winData.winMode;
			title 			= winData.title;
			contentPath 	= winData.contentPath;
			colorCode		= winData.colorCode;
			
			// ref
			appNode 		= winData.appNode;
			app 			= winData.app;
			
			// cofigure
			configureWin(winWidth, winHeight);
		
			// events
			addEventListener(Event.ENTER_FRAME, render);
		}
		
		// RENDER (position window) //////////////////////////////////////////////////
		private function render(event:Event):void {
			
			// match visibility to node
			visible = appNode.visible;
			
			if (visible) {
				// set position relative to node position
				x = appNode.x;
				y = appNode.y;
			
				// adjust win placement (4 quadrants)
				var winSpaceBuffer:int = 20;
				if (appNode.x >= 0) {
					x = x - ((winWidth / 2) + winSpaceBuffer);
				}
				if (appNode.x < 0) {
					x = x + ((winWidth / 2) + winSpaceBuffer);
				}
				if (appNode.y >= 0) {
					y = y - ((winHeight / 2) + winSpaceBuffer);
				}
				if (appNode.y < 0) {
					y = y + ((winHeight / 2) + winSpaceBuffer);
				}
			}
		}
		
		// CONFIGURE WINDOW ////////////////////////////////////////////////////////////
		private function configureWin(winWidth:Number, winHeight:Number):void {
/* xxx	
			// properties
			bg.width 		= winWidth;
			bg.height 		= winHeight;
			bg.alpha 		= 0.5;
			//
			area.width 		= winWidth - 20;
			area.height 	= winHeight - 20;
			area.alpha 		= 0.6;
	
			// text formating
			var format1:TextFormat = new TextFormat();
			format1.font 	= "Helvetica";
			format1.color 	= 0x000000;
			format1.size 	= 14;
			format1.align 	= "left";
			
			// add title
			var titleText:TextField = new TextField();
			titleText.text 	= title;
			titleText.x		= -(winWidth / 2) + 15;
			titleText.y 	= -(winHeight / 2) + 12;
			titleText.selectable = false;
			titleText.setTextFormat(format1);
			addChild(titleText);
			
			// win mode (matched to node type)
			switch (winMode) {
				
				// html
				case "1":
					setUpHTMLArea();
					break;
				
				// video
				case "2":
			//		setUpVideoPlayer();
					break;
				
				//
				case "3":
					setUpHTMLArea();
					break;
				
				//
				case "4":
					setUpHTMLArea();
					break;
			}
			
			// add close button

			var cButton:CloseButton  = new CloseButton();
			cButton.x				 = (winWidth / 2) - 25;
			cButton.y				 = -(winHeight / 2) + 15;
			addChild(cButton);
			// event
			cButton.addEventListener(MouseEvent.CLICK, closeWindow);
			//
			colorTransform(colorCode);
*/
		}
		
		// TRANSFORMATIONS //////////////////////////////////////
		private function colorTransform(colorCode:uint):void {
/* xxx		
			// change color to type
			var colorInfo:ColorTransform = this.bg.transform.colorTransform;
			colorInfo.color = colorCode;
			this.bg.transform.colorTransform = colorInfo;
*/
		}
		

		// LOAD DATA /////////////////////////////////////////////////
		private function loadData(dataPath:String):void {

			var dataType:String = "HTML";
			
			var htmlSession:DataLoader = new DataLoader({
					dataType: 	dataType,
					dataPath:	dataPath,
					app:		this,
					onLoad:		this.processData
				
			});
			htmlSession.loadData();
		}
	
		// HTML VIEW /////////////////////////////////////////////////
		private function setUpHTMLArea():void {

		 	output 				= new TextField();
			output.width 			= winWidth - 30;
			output.height 			= winHeight - 45;

			output.x 				= -(winWidth / 2) + 15;
			output.y				= -(winHeight / 2) + 30;
			//output.border 		= true;
			//output.borderColor 	= 0xEEEEEE;
			output.background 		= true;
			output.backgroundColor 	= 0xFFFFFF;
			output.wordWrap 		= true;
			output.multiline 		= true;
			output.selectable 		= true;
			//output.condenseWhite 	= true;
			addChild(output);
			
			// load HTML data
			loadData(contentPath);
		}
	/*	
		// VIDEO PLAYER ///////////////////////////////////////////////
		private function setUpVideoPlayer():void {
			
			videoPlayer 			= new FLVPlayback();
			videoPlayer.width 		= winWidth - 30;
			videoPlayer.height 		= winHeight - 45;
			videoPlayer.x			= -(winWidth / 2) + 15;
			videoPlayer.y			= -(winHeight / 2) + 30;
			videoPlayer.visible 	= true;	
			videoPlayer.skinBackgroundColor = 0x666666;
            videoPlayer.skinBackgroundAlpha = 0.5;
			//videoPlayer.skin	= "videoPlayer_skin.swf";	
			
			//addChild(videoPlayer);
			addChild(videoPlayer);
			
			// load and play video
			playVideo(contentPath);
		}
		
		// PLAY VIDEO /////////////////////////////////////////////////
		public function playVideo(dataPath:String):void {
			videoPlayer.source 	= dataPath;
			videoPlayer.visible = true;
		}
	*/	
		// PROCESS DATA ///////////////////////////////////////////////
		public function processData (htmlData:String):void { 
			output.htmlText = htmlData;
		}
		
		// CLOSE WINDOW //////////////////////////////////////////////
		private function closeWindow(event:MouseEvent):void {
			if (winMode == "2") {
				trace ("remove vp");
//				videoPlayer.stop();
//				videoPlayer.closeVideoPlayer(1);
				//removeChildAt(0);
				 //TODO: must get index ? *
			}
			appNode.closeWindow();
		}
	}
}

