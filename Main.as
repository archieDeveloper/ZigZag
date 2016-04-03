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
			//shapeArray:Vector.<Object>,
			boxCollection:BoxCollection = new BoxCollection(),
			newScoreF:int = 0,
			oldScoreF:int = 0;
		
		var flashVars: Object = stage.loaderInfo.parameters as Object;
		var VK: APIConnection = new APIConnection(flashVars);
		
		var alphaF:Boolean = true;
		var gravity:Number = 0;
		var addPlayer:Boolean = false;
		
		var date:Date = new Date();
		var lastTime = date.getTime();

		var fpsField:TextField = new TextField();
		
		var fps:int = 0;
		var scoreField:TextField = new TextField();
		var format:TextFormat = new TextFormat();
		var logo:Logo = new Logo();
		var spaceToPlay:SpaceToPlay = new SpaceToPlay();
		var gameInfo:MovieClip = new MovieClip();
		var bestScoreField:TextField = new TextField();
		var gamesPlayedField:TextField = new TextField();
		var gameOverText:GameOverText = new GameOverText();
		var retryButton:RetryButton = new RetryButton();
		var scoreText:ScoreText = new ScoreText();
		var shareButton:ShareButton = new ShareButton();
		
		var gameOverScoreField:TextField = new TextField();
		var gameOverBestScoreField:TextField = new TextField();
		
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


			logo.cacheAsBitmap = true;

			logo.x = stage.stageWidth/2;
			logo.y = -100;

			logo.movY = stage.stageHeight/2/3;


			spaceToPlay.x = stage.stageWidth/2;
			spaceToPlay.y = stage.stageHeight/2/1.5;

			spaceToPlay.alpha = 0;
			
			bestScoreField.text = 'BEST SCORE: '+bestScore;
			bestScoreField.width = 500;
			bestScoreField.x = -bestScoreField.width/2;
			
			gamesPlayedField.text = 'GAMES PLAYED: '+gamesPlayed;
			gamesPlayedField.width = 500;
			gamesPlayedField.x = -gamesPlayedField.width/2;
			gamesPlayedField.y = 40;

			gameInfo.addChild(bestScoreField);
			gameInfo.addChild(gamesPlayedField);
			gameInfo.x = stage.stageWidth/2;
			gameInfo.y = stage.stageHeight+100;

			gameInfo.movY = stage.stageHeight/1.5;

			stage.addChild(logo);
			stage.addChild(gameInfo);
			stage.addChild(spaceToPlay);


			gameOverText.cacheAsBitmap = true;
			gameOverText.x = stage.stageWidth+gameOverText.width;
			gameOverText.movX = stage.stageWidth+gameOverText.width;
			gameOverText.y = 100;


			gameOverScoreField.text = player.score.toString();
			gameOverScoreField.width = 500;
			gameOverScoreField.y -= 70;
			gameOverScoreField.x = -gameOverScoreField.width/2;
			
			
			gameOverBestScoreField.text = ''+bestScore;
			gameOverBestScoreField.width = 500;
			gameOverBestScoreField.y += 30;
			gameOverBestScoreField.x = -gameOverBestScoreField.width/2;
			

			scoreText.addChild(gameOverScoreField);
			scoreText.addChild(gameOverBestScoreField);

			
			scoreText.x = stage.stageWidth+scoreText.width;
			scoreText.movX = stage.stageWidth+scoreText.width;
			scoreText.y = 300;


			retryButton.cacheAsBitmap = true;
			retryButton.x = stage.stageWidth+retryButton.width;
			retryButton.movX = stage.stageWidth+retryButton.width;
			retryButton.y = 480;


			shareButton.cacheAsBitmap = true;
			shareButton.x = stage.stageWidth+shareButton.width;
			shareButton.movX = stage.stageWidth+shareButton.width;
			shareButton.y = 580;
			
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
			
			//trace(dt);
			
			newScoreF = Math.floor(player.score/50);
			if(newScoreF > oldScoreF) {
				oldScoreF = newScoreF;
				
				player.speed += 0.05;
				
				Box.toFirstColor.color = Box.colorList[Math.floor(Math.random()*5)];
				Box.toSecondColor.color = Box.toFirstColor.color;
				
				Box.toSecondColor.redOffset += 100; if (Box.toSecondColor.redOffset > 255) Box.toSecondColor.redOffset = 255;
				Box.toSecondColor.greenOffset += 100; if (Box.toSecondColor.greenOffset > 255) Box.toSecondColor.greenOffset = 255;
				Box.toSecondColor.blueOffset += 100; if (Box.toSecondColor.blueOffset > 255) Box.toSecondColor.blueOffset = 255;
			}
			
			scoreField.text = player.score.toString();
			
			animateUI();
			
			shape.graphics.clear();
			shape2.graphics.clear();
			
			Box.firstColor = toColorAnim(Box.firstColor, Box.toFirstColor);
			Box.secondColor = toColorAnim(Box.secondColor, Box.toSecondColor);
			/*player.x = mouseX;
			player.y = mouseY;*/
			if (Game.isStarted && !Game.isOver) {
				player.arrowsX = lengthdirX((player.speed*100)*dt,26.57);
				player.arrowsY = lengthdirY((player.speed*100)*dt,26.57);
				
				
				
				/*player.arrowsX = lengthdirX((player.speed+2),26.57);
				player.arrowsY = lengthdirY((player.speed+2),26.57);*/
				
				lastBox = boxCollection.getLast();
				if (lastBox.y > -lastBox.height/2-150) {
					createBox();
				}
				
				var shapeArrayNum:int = boxCollection.getLastIndex();
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = boxCollection.getOnIndex(i);
					var boxX = box.x,
						boxY = box.y,
						boxW = box.width,
						boxH = box.height;
					if ((player.x >= boxX-boxW && player.x <= boxX+boxW) && (player.y >= boxY-boxH && player.y <= boxY+boxH)) {
						//trace(i);
						var randZ:int = 1;
						if (box.rand) {
							randZ = -1;
						}
						
						var arrPoint:Array = [
							[boxX,boxY-boxH/2],
							[boxX+boxW/2*randZ,boxY],
							[boxX+boxW*randZ,boxY-boxH/2],
							[boxX+boxW/2*randZ,boxY-boxH]
						];
						
						if(box.bonus) {
							var arrPointBonus:Array = [
								[boxX,boxY],
								[boxX-boxW/2/3,boxY-10-boxH/2/3],
								[boxX+boxW/2/3,boxY-10-boxH/2/3],
								[boxX,boxY-35]
							];
							
							var collBonus:Boolean = false;
							
							for (a = 0, b = arrPointBonus.length - 1; a < arrPointBonus.length; b = a++) {
								if (((arrPointBonus[a][1] > player.y) != (arrPointBonus[b][1] > player.y)) && (player.x < (arrPointBonus[b][0] - arrPoint[a][0]) * (player.y - arrPointBonus[a][1]) / (arrPointBonus[b][1] - arrPointBonus[a][1]) + arrPointBonus[a][0])) {
									collBonus = !collBonus;
								}
							}
							
							if (collBonus) {
								box.bonus = false;
								player.score += 2;
							}
						}
						
						var coll:Boolean = false;
						
						for (a = 0, b = arrPoint.length - 1; a < arrPoint.length; b = a++) {
							if (((arrPoint[a][1] > player.y) != (arrPoint[b][1] > player.y)) && (player.x < (arrPoint[b][0] - arrPoint[a][0]) * (player.y - arrPoint[a][1]) / (arrPoint[b][1] - arrPoint[a][1]) + arrPoint[a][0])) {
								coll = !coll;
							}
						}
						
						if(box.bothCollision){
							arrPoint = [
								[boxX+50,boxY-boxH/2+25],
								[boxX+boxW/2*randZ*(-1),boxY],
								[boxX+boxW*randZ*(-1),boxY-boxH/2],
								[boxX+50+boxW/2*randZ*(-1),boxY-boxH+25]
							];
							for (a = 0, b = arrPoint.length - 1; a < arrPoint.length; b = a++) {
							if (((arrPoint[a][1] > player.y) != (arrPoint[b][1] > player.y)) && (player.x < (arrPoint[b][0] - arrPoint[a][0]) * (player.y - arrPoint[a][1]) / (arrPoint[b][1] - arrPoint[a][1]) + arrPoint[a][0])) {
									coll = !coll;
								}
							}
						}
						
						if (coll){
							player.rigth = !box.rand;
							Game.isOver = true;
							gameOverFunc();
							stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownFunc);
							retryButton.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
							setTimeout(function(){
								stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownFunc);
								retryButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
							},500);
						}
					}
					if (boxY-stage.stageHeight-boxH/2 + stage.stageHeight/3 > 0){
						box.y+=6;
					}
					box.y+=player.arrowsY;
					Render.box(box,shape,-stage.stageHeight/2);
				}
				player.x += player.arrowsX * (player.rigth ? 1 : -1);
			}
			
			if (!Game.isStarted && !Game.isOver) {
				shapeArrayNum = boxCollection.getLastIndex();
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = boxCollection.getOnIndex(i);
					Render.box(box,shape,-stage.stageHeight/2);
				}
			}
			if (Game.isOver) {
				shapeArrayNum = boxCollection.getLastIndex();
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = boxCollection.getOnIndex(i);
					if (box.y-stage.stageHeight-box.height/2 + stage.stageHeight/3 > 0){
						box.y+=6;
					}
					Render.box(box,shape,-stage.stageHeight/2);
					Render.box(box,shape2,stage.stageHeight/2);
				}
				
				if (!addPlayer){
					stage.addChild(shape2);
					
					stage.addChild(gameOverText);
					stage.addChild(scoreText);
					stage.addChild(retryButton);
					stage.addChild(shareButton);
					
					stage.removeChild(scoreField);
					
					addPlayer = true;
					gamesPlayed += 1;
					gamesPlayedField.text = 'GAMES PLAYED: '+gamesPlayed;
					gameOverScoreField.text = player.score.toString();
					VK.api('storage.set', { key:'gamesPlayed', value:gamesPlayed, user_id:flashVars['viewer_id'] }, function(){}, function(){});
					
					//смена цвета плашки со счетом
					var my_color:ColorTransform = new ColorTransform();
					my_color.color = 0xE1E1E1;
					scoreText.getChildAt(0).transform.colorTransform = my_color;
					
					my_color.color = 0x333333;
					scoreText.getChildAt(1).transform.colorTransform = my_color;
					scoreText.getChildAt(2).transform.colorTransform = my_color;
					gameOverScoreField.textColor = my_color.color;
					gameOverBestScoreField.textColor = my_color.color;
					//конец смены цвета
					if(player.score > bestScore){
						bestScore = player.score;
						bestScoreField.text = 'BEST SCORE: '+bestScore;
						gameOverBestScoreField.text = ''+bestScore;
						
						//смена цвета плашки со счетом
						my_color = new ColorTransform();
						my_color.color = 0xFD44E8;
						scoreText.getChildAt(0).transform.colorTransform = my_color;
						
						my_color.color = 0xFFFEFE;
						scoreText.getChildAt(1).transform.colorTransform = my_color;
						scoreText.getChildAt(2).transform.colorTransform = my_color;
						gameOverScoreField.textColor = my_color.color;
						gameOverBestScoreField.textColor = my_color.color;
						//конец смены цвета
						
						//stage.addChild();
						VK.api('storage.set', { key:'bestScore', value:bestScore, user_id:flashVars['viewer_id'] }, function(){}, function(){});
					} else {
					}
				}
				
				
				if (player.rigth) {
					player.x += player.arrowsX;
				} else {
					player.x -= player.arrowsX;
				}
				gravity += 0.4;
				player.y += gravity; 
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

		function createBox():void {
			var newBoxPoint:Box = boxCollection.getFirst();
			
			for(var i:int = 0, thisShapeLen:int = boxCollection.getLastIndex(); i < thisShapeLen; i++){
				boxCollection.setOnIndex(i, boxCollection.getOnIndex(i+1));
			}
			
			var rand:Boolean = Math.random()<.5;
			var thisShape:Object = boxCollection.getLast();
			if ((thisShape.x > stage.stageWidth-thisShape.width && rand) ||
				(thisShape.x < thisShape.width && !rand)) rand = !rand;
			
			newBoxPoint.x = thisShape.x+(rand ? thisShape.width/2 : -thisShape.width/2);
			newBoxPoint.y = thisShape.y-thisShape.height/2;
			newBoxPoint.width = 100;
			newBoxPoint.height = 50;
			newBoxPoint.rand = rand;
			newBoxPoint.bothCollision = false;
			newBoxPoint.bonus = Math.floor(Math.random()*5) ? false : true;

			thisShape.rand = rand;
			boxCollection.setOnIndex(thisShapeLen, newBoxPoint);
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
		
		function animateUI():void {
			logo.y += (logo.movY-logo.y)/10;
			gameInfo.y += (gameInfo.movY-gameInfo.y)/10;
			
			if(gameInfo.visible = true && gameInfo.y > stage.stageHeight+gameInfo.height/2){
				gameInfo.visible = false;
			} else {
				gameInfo.visible = true;
			}
			
			if(logo.visible = true && logo.y < 0-logo.height/2){
				logo.visible = false;
			} else {
				logo.visible = true;
			}
			
			scoreText.x += (scoreText.movX-scoreText.x)/10;
			retryButton.x += (retryButton.movX-retryButton.x)/10;
			shareButton.x += (shareButton.movX-shareButton.x)/10;
			gameOverText.x += (gameOverText.movX-gameOverText.x)/10;
			
			if(gameOverText.visible = true && gameOverText.x > stage.stageWidth+gameOverText.width/2){
				gameOverText.visible = false;
			} else {
				gameOverText.visible = true;
			}
			
			if(retryButton.visible = true && retryButton.x > stage.stageWidth+retryButton.width/2){
				retryButton.visible = false;
			} else {
				retryButton.visible = true;
			}
			
			if(shareButton.visible = true && shareButton.x > stage.stageWidth+shareButton.width/2){
				shareButton.visible = false;
			} else {
				shareButton.visible = true;
			}
			
			if(scoreText.visible = true && scoreText.x > stage.stageWidth+scoreText.width/2){
				scoreText.visible = false;
			} else {
				scoreText.visible = true;
			}

			if (spaceToPlay.alpha > 1) alphaF = false;
			if (spaceToPlay.alpha < 0 && !Game.isStarted) alphaF = true;
			
			if (alphaF) spaceToPlay.alpha += 0.025; else if(!alphaF) spaceToPlay.alpha -= 0.025;
			if (Game.isStarted) {
				spaceToPlay.alpha -= 0.05;
				if (spaceToPlay.alpha <= 0) {
					spaceToPlay.alpha = 0;
				}
			}
		}
	}
	
}