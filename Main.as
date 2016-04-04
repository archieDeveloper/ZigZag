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
	
	public class Main extends Sprite {
		
		private var loader:URLLoader = new URLLoader();
		private var photoLoader:Loader = new Loader();
		
		var spaceDown:Boolean = false;
		
		var shape:Shape,
			shape2:Shape;
		
		
		var date:Date = new Date();
		var lastTime = date.getTime();

		var fpsField:TextField = new TextField();
		
		var fps:int = 0;
		
		var tf: TextField;
				
		public function Main() {
			Game.SetStage(stage);
			Game.Init();
			
			tf = new TextField();
			tf.x = 10;
			tf.y = 50;
			tf.width = 587;
			tf.height = 349;
			
			stage.addChild(tf);
			//tf.appendText(flashVars['secret']+'\n'+flashVars['sid']+'');
			
			
			
			Game.VK.api('getProfiles', { uids: Game.flashVars['viewer_id'], fields: 'photo_100' }, fetchUserInfo, onApiRequestFail);
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
			
			Game.VK.api('storage.get', { key: 'gamesPlayed',user_id: Game.flashVars['viewer_id']}, function(data){
				Game.player.gamesPlayed = parseInt(data);
				Game.ui.gamesPlayedField.text = 'GAMES PLAYED: ' + Game.player.gamesPlayed;
				
				Game.VK.api('storage.get', { key: 'bestScore',user_id: Game.flashVars['viewer_id']}, function(data){
					Game.player.bestScore = parseInt(data);
					Game.ui.bestScoreField.text = 'BEST SCORE: ' + Game.player.bestScore;
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
			//player.cacheAsBitmap = true;
			stage.addChild(Game.player);

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
			Game.boxCollection.generate();				
			
			fpsField.x = 10;
			fpsField.y = 10;
			fpsField.width = 500;
			stage.addChild(fpsField);
			setInterval(function(){
				fpsField.text = 'FPS: '+Math.round(fps)+'\nID: ' + Game.flashVars['viewer_id']+'\nMemory: '+System.totalMemory/1024/1024;
			}, 400);
			/*
			*
			* Добавление текста со счетом
			*
			*/


			stage.addChild(Game.ui.logo);
			stage.addChild(Game.ui.gameInfo);
			stage.addChild(Game.ui.spaceToPlay);

			Game.ui.scoreText.addChild(Game.ui.gameOverScoreField);
			Game.ui.scoreText.addChild(Game.ui.gameOverBestScoreField);
					
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
			
			
			Game.player.nextLevel();
			
			Game.ui.scoreField.text = Game.player.score.toString();
			
			Game.ui.animate();
			
			shape.graphics.clear();
			shape2.graphics.clear();
			
			Box.firstColor = toColorAnim(Box.firstColor, Box.toFirstColor);
			Box.secondColor = toColorAnim(Box.secondColor, Box.toSecondColor);
	
			
			if (Game.isStarted && !Game.isOver) {
				Game.player.updateFrame(dt, shape);
			}
			
			if (!Game.isStarted && !Game.isOver) {
				Game.boxCollection.eachBox(function(box){
					Render.box(box, shape, -Game.stage.stageHeight/2);
				});
			}
			if (Game.isOver) {
				Game.player.gameOverUpdate(shape);
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
					stage.addChild(Game.ui.scoreField);
					
					
					stage.removeChild(Game.ui.logo);
					stage.removeChild(Game.ui.gameInfo);
					stage.removeChild(Game.ui.spaceToPlay);
					Game.isStarted = true;
					Game.player.score -= 1;
					Game.ui.logo.movY = -100;
					Game.ui.gameInfo.movY = stage.stageHeight+100;
				}
				if (!Game.isOver) {
					Game.player.rigth = !Game.player.rigth;
					Game.player.score += 1;
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
			stage.addChild(Game.ui.logo);
			stage.addChild(Game.ui.gameInfo);
			stage.addChild(Game.ui.spaceToPlay);
			retryGame();
		}

		function retryGame():void {
			setTimeout(function(){
				Game.ui.gameOverText.movX = stage.stageWidth + Game.ui.gameOverText.width;
			},0);
			setTimeout(function(){
				Game.ui.scoreText.movX = stage.stageWidth + Game.ui.scoreText.width;
			},50);
			setTimeout(function(){
				Game.ui.retryButton.movX = stage.stageWidth + Game.ui.retryButton.width;
			},100);
			setTimeout(function(){
				Game.ui.shareButton.movX = stage.stageWidth + Game.ui.shareButton.width;
			},150);
			stage.removeChild(shape2);
			
			Game.player.score = 0;
			Game.player.rigth = false;
			Game.player.x = stage.stageWidth/2;
			Game.player.y = stage.stageHeight/2;
			Game.isStarted = false;
			Game.isOver = false;
			Game.player.addPlayer = false;
			Game.player.speed = 3;
			Game.player.level = 0;
			Game.player.newLevel = 0;;
			
			Game.player.gravity = 0;
			
			Game.boxCollection.generate();
			
			Game.ui.logo.movY = stage.stageHeight/2/3;
			Game.ui.spaceToPlay.alpha = 0;
			Game.ui.gameInfo.movY = stage.stageHeight/1.5;
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