package  {
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.InterpolationMethod;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.system.System;
	
	import flash.net.URLLoader;
    import flash.net.URLRequest;
	
	import vk.api.MD5;
	
	import vk.APIConnection;
	import vk.events.*;
	import vk.ui.VKButton;
	
	import Box;
	
	public class Main extends Sprite {
		
		private var loader:URLLoader = new URLLoader();
		private var photoLoader:Loader = new Loader();
		
		var spaceDown:Boolean = false;
		
		var player:Player,
			shape:Shape,
			shape2:Shape,
			boxCollection:BoxCollection = new BoxCollection();
		
		var flashVars: Object = stage.loaderInfo.parameters as Object;
		var VK: APIConnection = new APIConnection(flashVars);
		
		var alphaF:Boolean = true;
		var addPlayer:Boolean = false;
		
		var date:Date = new Date();
		var lastTime = date.getTime();

		var fpsField:TextField = new TextField();
		
		var fps:int = 0;
		var scoreField:TextField = new TextField();
		var format:TextFormat = new TextFormat();
		
		public var ui:UI = new UI();
		
		var tf: TextField;
		
		var gamesPlayed:int;
		var bestScore:int;
		
		var lastBox:Box;
		var box:Box;
		
		public function Main() {
			Game.SetStage(stage);
			
			tf = new TextField();
			tf.x = 10;
			tf.y = 50;
			tf.width = 587;
			tf.height = 349;
			
			stage.addChild(tf);
			//tf.appendText(flashVars['secret']+'\n'+flashVars['sid']+'');
			
			format.font = "Ubahn";
			format.color = 0x2C2C2C;
			format.size = 42;
			scoreField.defaultTextFormat = format;
			
			format.color = 0x2C2C2C;
			format.size = 24;
			format.align = 'center';
			bestScoreField.defaultTextFormat = format;
			gamesPlayedField.defaultTextFormat = format;
			
			format.size = 60;
			gameOverScoreField.defaultTextFormat = format;
			gameOverBestScoreField.defaultTextFormat = format;
			
			VK.api('getProfiles', { uids: flashVars['viewer_id'], fields: 'photo_100' }, fetchUserInfo, onApiRequestFail);
			/*VK.api('storage.set', { key:'bestScore',value:0,user_id:flashVars['viewer_id']}, function(){
			}, function(){});*/
			
		}
		private function fetchUserInfo(data: Object): void {
			// Example of fetching info from API request
			/*tf.appendText("\n// -- API request result:\n");
			for (var key: String in data[0]) {
			  tf.appendText(key + "=" + data[0][key] + "\n");
			}*/
			
			var request2:URLRequest=new URLRequest(data[0]['photo_100']);
			photoLoader.load(request2);
			photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloaded);
		}
		
		private function onApiRequestFail(data: Object): void {
			// Example of fetching fail from API request
			//tf.appendText("Error: "+data.error_msg+"\n");
			initApp();
		}
		
		private function onloaded(e:Event):void {
			// отображаем загруженный аватар
			photoLoader.x = (550-photoLoader.width)/2;
			photoLoader.y = (400-photoLoader.height)/2;
			//addChild(photoLoader);
			
			VK.api('storage.get', { key:'gamesPlayed',user_id:flashVars['viewer_id']}, function(data){
				gamesPlayed = parseInt(data);
				gamesPlayedField.text = 'GAMES PLAYED: '+gamesPlayed;
				
				VK.api('storage.get', { key:'bestScore',user_id:flashVars['viewer_id']}, function(data){
					bestScore = parseInt(data);
					bestScoreField.text = 'BEST SCORE: '+bestScore;
					initApp();
				}, function(){});
			}, function(){});
		}
		
		public function initApp():void {
			Box.matrix.createGradientBox(stage.stageWidth*2, stage.stageHeight,0,-stage.stageWidth/2,0);
			
			Box.firstColor.color = 0x3F6CA3;
			Box.toFirstColor.color = 0x3F6CA3;
			
			Box.secondColor.color = Box.firstColor.color;
			
			Box.secondColor.redOffset += 100; if (Box.secondColor.redOffset > 255) Box.secondColor.redOffset = 255;
			Box.secondColor.greenOffset += 100; if (Box.secondColor.greenOffset > 255) Box.secondColor.greenOffset = 255;
			Box.secondColor.blueOffset += 100; if (Box.secondColor.blueOffset > 255) Box.secondColor.blueOffset = 255;
			
			Box.toSecondColor.color = Box.secondColor.color;
			
			Box.colorList = [
				0x9A8E46,
				0x8E2E29,
				0x666A8D,
				0x328186,
				0x333333
			];
			
			/*
			*
			* создание персонажа
			*
			*/
			player = new Player(stage.stageWidth/2, stage.stageHeight/2);
			//player.cacheAsBitmap = true;
			stage.addChild(player);

			/*
			*
			* создание первой платформы
			*
			*/
			shape = new Shape();
			addChild(shape);

			shape2 = new Shape();


			/*
			*
			* создание 20 платформ
			*
			*/
			boxCollection.generate();				
			
			fpsField.x = 10;
			fpsField.y = 10;
			fpsField.width = 500;
			stage.addChild(fpsField);
			setInterval(function(){
				fpsField.text = 'FPS: '+Math.round(fps)+'\nID: '+flashVars['viewer_id']+'\nMemory: '+System.totalMemory/1024/1024;
			}, 400);
			/*
			*
			* Добавление текста со счетом
			*
			*/
			scoreField.x = stage.stageWidth-100;
			scoreField.y = 10;
			scoreField.selectable = false;


			stage.addChild(ui.logo);
			stage.addChild(ui.gameInfo);
			stage.addChild(ui.spaceToPlay);

			ui.scoreText.addChild(ui.gameOverScoreField);
			ui.scoreText.addChild(ui.gameOverBestScoreField);
					
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownFunc);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpFunc);
			stage.addEventListener(Event.ENTER_FRAME, enterFramePhy);
		}
		
		
		function enterFramePhy(e:Event):void {
	
			date = new Date();
			var now = date.getTime(),
				dt = (now - lastTime) / 1000.0,
				i,a,b;
			fps = 1000.0 /(now - lastTime);
			
			
			player.nextLevel();
			
			scoreField.text = player.score.toString();
			
			ui.animate();
			
			shape.graphics.clear();
			shape2.graphics.clear();
			
			Box.firstColor = toColorAnim(Box.firstColor, Box.toFirstColor);
			Box.secondColor = toColorAnim(Box.secondColor, Box.toSecondColor);
	
			
			if (Game.isStarted && !Game.isOver) {
				player.updateFrame(dt);
			}
			
			if (!Game.isStarted && !Game.isOver) {
				boxCollection.eachBox(function(box){
					Render.box(box, shape, -Game.stage.stageHeight/2);
				});
			}
			if (Game.isOver) {
				player.gameOverUpdate();
			}

			/*
			*
			* сохранение времени после выполенния функции
			*
			*/
			date = new Date();
			lastTime = date.getTime();
		}
		
		/*
		*
		* нажатие пробела
		*
		*/
		function keyDownFunc(e:KeyboardEvent):void {
			if(e.keyCode === 32 && !spaceDown) {
				spaceDown = true;
				if (!Game.isStarted) {
					stage.addChild(scoreField);
					
					
					stage.removeChild(logo);
					stage.removeChild(gameInfo);
					stage.removeChild(spaceToPlay);
					Game.isStarted = true;
					player.score -= 1;
					logo.movY = -100;
					gameInfo.movY = stage.stageHeight+100;
				}
				if (!Game.isOver) {
					player.rigth = !player.rigth;
					player.score += 1;
				}
			}
			if(e.keyCode === 86) {
				Game.isStarted = false;
			}
		}
		function keyUpFunc(e:KeyboardEvent):void {
			if(e.keyCode === 32){
				spaceDown = false;
			}
		}

		function mouseDown(e:MouseEvent):void {
			stage.addChild(logo);
			stage.addChild(gameInfo);
			stage.addChild(spaceToPlay);
			retryGame();
		}

		/*
		*
		* дополнительные функции
		*
		*/
		function lengthdirX(len, dir):Number{
			return Math.cos(dir*Math.PI/180)*len;
		}

		function lengthdirY(len, dir):Number{
			return Math.sin(dir*Math.PI/180)*len;
		}

		function retryGame():void {
			setTimeout(function(){
				gameOverText.movX = stage.stageWidth+gameOverText.width;
			},0);
			setTimeout(function(){
				scoreText.movX = stage.stageWidth+scoreText.width;
			},50);
			setTimeout(function(){
				retryButton.movX = stage.stageWidth+retryButton.width;
			},100);
			setTimeout(function(){
				shareButton.movX = stage.stageWidth+shareButton.width;
			},150);
			stage.removeChild(shape2);
			
			player.score = 0;
			player.rigth = false;
			player.x = stage.stageWidth/2;
			player.y = stage.stageHeight/2;
			Game.isStarted = false;
			Game.isOver = false;
			addPlayer = false;
			player.speed = 3;
			
			oldScoreF = newScoreF = 0;
			
			gravity = 0;
			
			boxCollection.generate();
			
			logo.movY = stage.stageHeight/2/3;
			spaceToPlay.alpha = 0;
			gameInfo.movY = stage.stageHeight/1.5;
		}

		function gameOverFunc():void {
			
			Box.toFirstColor.color = 0x3F6CA3;
			
			Box.toSecondColor.color = Box.toFirstColor.color;

			Box.toSecondColor.redOffset += 100; if (Box.toSecondColor.redOffset > 255) Box.toSecondColor.redOffset = 255;
			Box.toSecondColor.greenOffset += 100; if (Box.toSecondColor.greenOffset > 255) Box.toSecondColor.greenOffset = 255;
			Box.toSecondColor.blueOffset += 100; if (Box.toSecondColor.blueOffset > 255) Box.toSecondColor.blueOffset = 255;
			
			setTimeout(function(){
				gameOverText.movX = stage.stageWidth/2;
			},200);
			setTimeout(function(){
				scoreText.movX = stage.stageWidth/2;
			},300);
			setTimeout(function(){
				retryButton.movX = stage.stageWidth/2;
			},400);
			setTimeout(function(){
				shareButton.movX = stage.stageWidth/2;
			},500);
		}
		
		function toColorAnim(fromColor, toColor):ColorTransform {
			//var returnColor:ColorTransform = new ColorTransform();
			fromColor.redOffset += (toColor.redOffset-fromColor.redOffset)/25;
			fromColor.greenOffset += (toColor.greenOffset-fromColor.greenOffset)/25;
			fromColor.blueOffset += (toColor.blueOffset-fromColor.blueOffset)/25;
			
			return fromColor;
		}
	}
	
}