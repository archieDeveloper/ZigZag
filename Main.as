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
		
		var startGame:Boolean = false,
			gameOver:Boolean = false,
			player:Player = new Player(),
			shape:Shape,
			shape2:Shape,
			shapeArray:Vector.<Object>,
			newScoreF:int = 0,
			oldScoreF:int = 0;
		
		var flashVars: Object = stage.loaderInfo.parameters as Object;
		var VK: APIConnection = new APIConnection(flashVars);
		
		var matrix:Matrix = new Matrix();
		
		var thisColor:ColorTransform = new ColorTransform();
		var toThisColor:ColorTransform = new ColorTransform();
		
		var thisColorWhite:ColorTransform = new ColorTransform();
		var toThisColorWhite:ColorTransform = new ColorTransform();
		
		var arrayColor:Array = new Array();
		
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
		
		var lastBox:Object;
		var box:Object;
		
		public function Main() {
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
			
			
			matrix.createGradientBox(stage.stageWidth*2, stage.stageHeight,0,-stage.stageWidth/2,0);
			
			thisColor.color = 0x3F6CA3;
			toThisColor.color = 0x3F6CA3;
			
			thisColorWhite.color = thisColor.color;
			
			thisColorWhite.redOffset += 100; if (thisColorWhite.redOffset > 255) thisColorWhite.redOffset = 255;
			thisColorWhite.greenOffset += 100; if (thisColorWhite.greenOffset > 255) thisColorWhite.greenOffset = 255;
			thisColorWhite.blueOffset += 100; if (thisColorWhite.blueOffset > 255) thisColorWhite.blueOffset = 255;
			
			toThisColorWhite.color = thisColorWhite.color;
			
			arrayColor = [
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
			player = new Player();
			player.score = 0;
			player.speed = 3;
			player.rigth = false;
			player.x = stage.stageWidth/2;
			player.y = stage.stageHeight/2;
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
			shapeArray = new Vector.<Object>(38,true);

			shapeArray[0] = {
				x: stage.stageWidth/2,
				y: stage.stageHeight/2,
				width: 1000,
				height: 500,
				rand: true,
				bothCollision: true
			};


			shapeArray[1] = {
				x: shapeArray[0].x+50,
				y: shapeArray[0].y-shapeArray[0].height/2,
				width: 100,
				height: 50,
				rand: true,
				bothCollision: true
			};

			for (var s:int = 1; s < shapeArray.length-1; s++){
				var rand:Boolean = Math.random()<.5;
				var thisShape:Object = shapeArray[s];
				
				if ((thisShape.x > stage.stageWidth-thisShape.width && rand) ||
					(thisShape.x < thisShape.width && !rand)) rand = !rand;
				
				var newBoxPoint:Object = {
					x: thisShape.x+(rand ? thisShape.width/2 : -thisShape.width/2),
					y: thisShape.y-thisShape.height/2,
					width: 100,
					height: 50,
					rand: rand,
					bothCollision: false,
					bonus: Math.floor(Math.random()*5) ? false : true
				};

				thisShape.rand = rand;
				shapeArray[s+1] = newBoxPoint;
			}
				
			
			/*fpsField.x = 10;
			fpsField.y = 10;
			fpsField.width = 500;
			stage.addChild(fpsField);
			setInterval(function(){
				fpsField.text = 'FPS: '+Math.round(fps)+'\nID: '+flashVars['viewer_id']+'\nMemory: '+System.totalMemory/1024/1024;
			}, 400);*/
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


			gameOverScoreField.text = player.score;
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
				
				toThisColor.color = arrayColor[Math.floor(Math.random()*5)];
				toThisColorWhite.color = toThisColor.color;
				
				toThisColorWhite.redOffset += 100; if (toThisColorWhite.redOffset > 255) toThisColorWhite.redOffset = 255;
				toThisColorWhite.greenOffset += 100; if (toThisColorWhite.greenOffset > 255) toThisColorWhite.greenOffset = 255;
				toThisColorWhite.blueOffset += 100; if (toThisColorWhite.blueOffset > 255) toThisColorWhite.blueOffset = 255;
			}
			
			scoreField.text = player.score;
			
			animateUI();
			
			shape.graphics.clear();
			shape2.graphics.clear();
			
			thisColor = toColorAnim(thisColor,toThisColor);
			thisColorWhite = toColorAnim(thisColorWhite,toThisColorWhite);
			/*player.x = mouseX;
			player.y = mouseY;*/
			if (startGame && !gameOver) {
				player.arrowsX = lengthdirX((player.speed*100)*dt,26.57);
				player.arrowsY = lengthdirY((player.speed*100)*dt,26.57);
				
				
				
				/*player.arrowsX = lengthdirX((player.speed+2),26.57);
				player.arrowsY = lengthdirY((player.speed+2),26.57);*/
				
				lastBox = shapeArray[shapeArray.length-1];
				if (lastBox.y > -lastBox.height/2-150) {
					createBox();
				}
				
				var shapeArrayNum:int = shapeArray.length-1;
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = shapeArray[i];
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
							gameOver = true;
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
					drawBoxes(box,shape,-stage.stageHeight/2);
				}
				player.x += player.arrowsX * (player.rigth ? 1 : -1);
			}
			
			if (!startGame && !gameOver) {
				shapeArrayNum = shapeArray.length-1;
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = shapeArray[i];
					drawBoxes(box,shape,-stage.stageHeight/2);
				}
			}
			
			if (gameOver) {
				shapeArrayNum = shapeArray.length-1;
				
				for(i = shapeArrayNum; i >= 0; i--) {
					box = shapeArray[i];
					if (box.y-stage.stageHeight-box.height/2 + stage.stageHeight/3 > 0){
						box.y+=6;
					}
					drawBoxes(box,shape,-stage.stageHeight/2);
					drawBoxes(box,shape2,stage.stageHeight/2);
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
					gameOverScoreField.text = player.score;
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
			if(e.keyCode === 32 && !spaceDown){
				spaceDown = true;
				if (!startGame) {
					stage.addChild(scoreField);
					
					
					stage.removeChild(logo);
					stage.removeChild(gameInfo);
					stage.removeChild(spaceToPlay);
					startGame = true;
					player.score -= 1;
					logo.movY = -100;
					gameInfo.movY = stage.stageHeight+100;
				}
				if (!gameOver) {
					player.rigth = !player.rigth;
					player.score += 1;
				}
			}
			if(e.keyCode === 86){
				startGame = false;
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

		function createBox():void{
			
			var newBoxPoint:Object = shapeArray[0];
			var thisShapeLen:int = shapeArray.length-1;
			
			for(var i:int = 0; i < thisShapeLen; i++){
				shapeArray[i] = shapeArray[i+1];
			}
			
			var rand:Boolean = Math.random()<.5;
			var thisShape:Object = shapeArray[thisShapeLen];
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
			shapeArray[thisShapeLen] = newBoxPoint;
		}

		function retryGame():void{
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
			startGame = false;
			gameOver = false;
			addPlayer = false;
			player.speed = 3;
			
			oldScoreF = newScoreF = 0;
			
			gravity = 0;
			
			shapeArray = new Vector.<Object>(38,true);

			shapeArray[0] = {
				x: stage.stageWidth/2,
				y: stage.stageHeight/2,
				width: 1000,
				height: 500,
				rand: true,
				bothCollision: true
			};


			shapeArray[1] = {
				x: shapeArray[0].x+50,
				y: shapeArray[0].y-shapeArray[0].height/2,
				width: 100,
				height: 50,
				rand: true
			};

			for (var s:int = 1; s < shapeArray.length-1; s++){
				var rand:Boolean = Math.random()<.5;
				var thisShape:Object = shapeArray[s];
				
				if ((thisShape.x > stage.stageWidth-thisShape.width && rand) ||
					(thisShape.x < thisShape.width && !rand)) rand = !rand;
				
				var newBoxPoint:Object = {
					x: thisShape.x+(rand ? thisShape.width/2 : -thisShape.width/2),
					y: thisShape.y-thisShape.height/2,
					width: 100,
					height: 50,
					rand: rand,
					bothCollision: false
				};

				thisShape.rand = rand;
				shapeArray[s+1] = newBoxPoint;
			}
			
			logo.movY = stage.stageHeight/2/3;
			spaceToPlay.alpha = 0;
			gameInfo.movY = stage.stageHeight/1.5;
		}

		function gameOverFunc():void{
			
			toThisColor.color = 0x3F6CA3;
			
			toThisColorWhite.color = toThisColor.color;

			toThisColorWhite.redOffset += 100; if (toThisColorWhite.redOffset > 255) toThisColorWhite.redOffset = 255;
			toThisColorWhite.greenOffset += 100; if (toThisColorWhite.greenOffset > 255) toThisColorWhite.greenOffset = 255;
			toThisColorWhite.blueOffset += 100; if (toThisColorWhite.blueOffset > 255) toThisColorWhite.blueOffset = 255;
			
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
		
		function toColorAnim(fromColor, toColor):ColorTransform{
			//var returnColor:ColorTransform = new ColorTransform();
			fromColor.redOffset += (toColor.redOffset-fromColor.redOffset)/25;
			fromColor.greenOffset += (toColor.greenOffset-fromColor.greenOffset)/25;
			fromColor.blueOffset += (toColor.blueOffset-fromColor.blueOffset)/25;
			
			return fromColor;
		}
		
		function drawBoxes(box, shape, ifY):void {
	
			if(box.y > ifY && !(box.y > stage.stageHeight+box.height/2) && !(box.y < -box.height/2-150)){
				shape.graphics.beginFill(thisColor.color);

				var commands:Vector.<int>  = new Vector.<int>(4,true);
				var coords:Vector.<Number>  = new Vector.<Number>(8,true);
				
				commands[0] = 1;
				coords[0] = box.x;
				coords[1] = box.y+box.height/2;

				commands[1] = 2;
				coords[2] = box.x+box.width/2;
				coords[3] = box.y;
				
				commands[2] = 2;
				coords[4] = box.x+box.width/2;
				coords[5] = box.y+150;

				commands[3] = 2;
				coords[6] = box.x;
				coords[7] = box.y+box.height/2+150;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				
				shape.graphics.beginFill(thisColor.color);
									
				
				commands[0] = 1;
				coords[0] = box.x-box.width/2;
				coords[1] = box.y;

				commands[1] = 2;
				coords[2] = box.x;
				coords[3] = box.y+box.height/2;
				
				commands[2] = 2;
				coords[4] = box.x;
				coords[5] = box.y+box.height/2+150;

				commands[3] = 2;
				coords[6] = box.x-box.width/2;
				coords[7] = box.y+150;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				
				shape.graphics.beginGradientFill(GradientType.RADIAL,
									[thisColorWhite.color, thisColor.color], 
									[1, 1], 
									[0, 255],  
									matrix,  
									SpreadMethod.PAD,  
									InterpolationMethod.LINEAR_RGB,  
									0);
				
				commands[0] = 1;
				coords[0] = box.x-box.width/2;
				coords[1] = box.y;

				commands[1] = 2;
				coords[2] = box.x;
				coords[3] = box.y-box.height/2;
				
				commands[2] = 2;
				coords[4] = box.x+box.width/2;
				coords[5] = box.y;

				commands[3] = 2;
				coords[6] = box.x;
				coords[7] = box.y+box.height/2;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				if (box.bonus){
					shape.graphics.beginFill(0xFD65EE);
					commands= new Vector.<int>(3,true);
					coords= new Vector.<Number>(6,true);
					
					commands[0] = 1;
					coords[0] = box.x;
					coords[1] = box.y;

					commands[1] = 2;
					coords[2] = box.x-box.width/2/3;
					coords[3] = box.y-10-box.height/2/3;
					
					commands[2] = 2;
					coords[4] = box.x;
					coords[5] = box.y-10;
					shape.graphics.drawPath(commands,coords);
					shape.graphics.endFill();
					
					/**********  2  *********/
					shape.graphics.beginFill(0xB122A2);
					
					commands[0] = 1;
					coords[0] = box.x;
					coords[1] = box.y;

					commands[1] = 2;
					coords[2] = box.x+box.width/2/3;
					coords[3] = box.y-10-box.height/2/3;
					
					commands[2] = 2;
					coords[4] = box.x;
					coords[5] = box.y-10;
					shape.graphics.drawPath(commands,coords);
					shape.graphics.endFill();
					
					/**********  3  *********/
					shape.graphics.beginFill(0xFE9EF5);
					
					commands[0] = 1;
					coords[0] = box.x;
					coords[1] = box.y-10;

					commands[1] = 2;
					coords[2] = box.x-box.width/2/3;
					coords[3] = box.y-10-box.height/2/3;
					
					commands[2] = 2;
					coords[4] = box.x;
					coords[5] = box.y-35;
					shape.graphics.drawPath(commands,coords);
					shape.graphics.endFill();
					
					/**********  4  *********/
					shape.graphics.beginFill(0xFE43EA);
					
					commands[0] = 1;
					coords[0] = box.x;
					coords[1] = box.y-10;

					commands[1] = 2;
					coords[2] = box.x+box.width/2/3;
					coords[3] = box.y-10-box.height/2/3;
					
					commands[2] = 2;
					coords[4] = box.x;
					coords[5] = box.y-35;
					shape.graphics.drawPath(commands,coords);
					shape.graphics.endFill();
				}
				
				
				
				
				/*if ((player.x >= box.x-box.width && player.x <= box.x+box.width) && (player.y >= box.y-box.height && player.y <= box.y+box.height)) {
					shape.graphics.lineStyle(1,0,0.5);
					var randZ = 1;
					if (box.rand) {
						randZ = -1;
					}
					shape.graphics.moveTo(box.x,box.y-box.height/2);
					shape.graphics.lineTo(box.x+box.width/2*randZ,box.y);
					shape.graphics.lineTo(box.x+box.width*randZ,box.y-box.height/2);
					shape.graphics.lineTo(box.x+box.width/2*randZ,box.y-box.height);
					shape.graphics.lineTo(box.x,box.y-box.height/2);
					
					if(box.bothCollision){
						shape.graphics.moveTo(box.x+50,box.y-box.height/2+25);
						shape.graphics.lineTo(box.x+box.width/2*randZ*(-1),box.y);
						shape.graphics.lineTo(box.x+box.width*randZ*(-1),box.y-box.height/2);
						shape.graphics.lineTo(box.x+50+box.width/2*randZ*(-1),box.y-box.height+25);
						shape.graphics.lineTo(box.x+50,box.y-box.height/2+25);
					}
				}*/
			}
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
			if (spaceToPlay.alpha < 0 && !startGame) alphaF = true;
			
			if (alphaF) spaceToPlay.alpha += 0.025; else if(!alphaF) spaceToPlay.alpha -= 0.025;
			if (startGame) {
				spaceToPlay.alpha -= 0.05;
				if (spaceToPlay.alpha <= 0) {
					spaceToPlay.alpha = 0;
				}
			}
		}
	}
	
}