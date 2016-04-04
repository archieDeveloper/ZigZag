package  {
	
	import flash.display.Sprite;
	import flash.display.Stage;
	
	public class Player extends Sprite {
		
		// Счет игрока
		public var score:int = 0;
		
		// Скорость игрока
		public var speed:int = 3;
		
        // В право ли направлен игрок		
		public var rigth:Boolean = false;
		
	    // Перемещение по X
		public var arrowsX:int = 0;
		
		// Перемещение по Y
		public var arrowsY:int = 0;
		
		// Гравитация
		public var gravity:Number = 0;
		
		// Уровень сложности
		public var level:int = 0;
		
		public var newLevel:int = 0;
		
		public function Player(positionX:int = 0, positionY:int = 0) {
			// constructor code
			x = positionX;
			y = positionY;
		}
		
		public function updateFrame(deltaTime:int):void
		{
			arrowsX = lengthdirX((speed*100)*deltaTime,26.57);
			arrowsY = lengthdirY((speed*100)*deltaTime,26.57);
			
			/*player.arrowsX = lengthdirX((player.speed+2),26.57);
			player.arrowsY = lengthdirY((player.speed+2),26.57);*/
			
			lastBox = boxCollection.getLast();
			if (lastBox.y > -lastBox.height/2-150) {
				createBox();
			}
			
			var shapeArrayNum:int = boxCollection.getLastIndex();
			
			for(var i:int = shapeArrayNum; i >= 0; i--) {
				box = boxCollection.getOnIndex(i);
				var boxX = box.x,
					boxY = box.y,
					boxW = box.width,
					boxH = box.height;
				if ((x >= boxX-boxW && x <= boxX+boxW) && (y >= boxY-boxH && y <= boxY+boxH)) {
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
							if (((arrPointBonus[a][1] > y) != (arrPointBonus[b][1] > y)) && (x < (arrPointBonus[b][0] - arrPoint[a][0]) * (y - arrPointBonus[a][1]) / (arrPointBonus[b][1] - arrPointBonus[a][1]) + arrPointBonus[a][0])) {
								collBonus = !collBonus;
							}
						}
						
						if (collBonus) {
							box.bonus = false;
							score += 2;
						}
					}
					
					collisionsss();
				}
				Render.box(box,shape,-stage.stageHeight/2);
			}
			x += arrowsX * (rigth ? 1 : -1);
		}
		
		public function nextLevel():void
		{
			newLevel = Math.floor(score/50);
			if(newLevel > level) {
				level = newLevel;
				
				speed += 0.05;
				
				Box.toFirstColor.color = Box.colorList[Math.floor(Math.random()*5)];
				Box.toSecondColor.color = Box.toFirstColor.color;
				
				Box.toSecondColor.redOffset += 100; if (Box.toSecondColor.redOffset > 255) Box.toSecondColor.redOffset = 255;
				Box.toSecondColor.greenOffset += 100; if (Box.toSecondColor.greenOffset > 255) Box.toSecondColor.greenOffset = 255;
				Box.toSecondColor.blueOffset += 100; if (Box.toSecondColor.blueOffset > 255) Box.toSecondColor.blueOffset = 255;
			}
		}
		
		public function gameOverUpdate():void
		{
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
				if(player.score > bestScore) {
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
			
			
			if (rigth) {
				x += arrowsX;
			} else {
				x -= arrowsX;
			}
			gravity += 0.4;
			y += gravity; 
		}
		
		public function collisionsss():void
		{
			var coll:Boolean = false;
					
			for (a = 0, b = arrPoint.length - 1; a < arrPoint.length; b = a++) {
				if (((arrPoint[a][1] > y) != (arrPoint[b][1] > y)) && (x < (arrPoint[b][0] - arrPoint[a][0]) * (y - arrPoint[a][1]) / (arrPoint[b][1] - arrPoint[a][1]) + arrPoint[a][0])) {
					coll = !coll;
				}
			}
			
			if(box.bothCollision) {
				arrPoint = [
					[boxX+50,boxY-boxH/2+25],
					[boxX+boxW/2*randZ*(-1),boxY],
					[boxX+boxW*randZ*(-1),boxY-boxH/2],
					[boxX+50+boxW/2*randZ*(-1),boxY-boxH+25]
				];
				for (a = 0, b = arrPoint.length - 1; a < arrPoint.length; b = a++) {
				if (((arrPoint[a][1] > y) != (arrPoint[b][1] > y)) && (x < (arrPoint[b][0] - arrPoint[a][0]) * (y - arrPoint[a][1]) / (arrPoint[b][1] - arrPoint[a][1]) + arrPoint[a][0])) {
						coll = !coll;
					}
				}
			}
			
			if (coll) {
				rigth = !box.rand;
				Game.isOver = true;
				gameOverFunc();
				Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownFunc);
				retryButton.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				setTimeout(function(){
					Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownFunc);
					retryButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				},500);
			}
		}
	}
	
}
