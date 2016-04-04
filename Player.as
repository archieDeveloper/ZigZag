package {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.events.*;
	import flash.utils.*;

	public class Player extends Sprite {

		// Счет игрока
		public var score: int = 0;

		public var bestScore: int = 0;
		public var gamesPlayed: int = 0;

		// Скорость игрока
		public var speed: int = 3;

		// В право ли направлен игрок		
		public var rigth: Boolean = false;

		// Перемещение по X
		public var arrowsX: Number = 0;

		// Перемещение по Y
		public var arrowsY: Number = 0;

		// Гравитация
		public var gravity: Number = 0;

		// Уровень сложности
		public var level: int = 0;

		public var newLevel: int = 0;


		public var addPlayer: Boolean = false;

		public var lastBox: Box;
		public var box: Box;

		public function Player() {
			// constructor code
			x = Game.stage.stageWidth / 2;
			y = Game.stage.stageHeight / 2;
		}

		/*
		 *
		 * дополнительные функции
		 *
		 */
		function lengthdirX(len, dir): Number {
			return Math.cos(dir * Math.PI / 180) * len;
		}

		function lengthdirY(len, dir): Number {
			return Math.sin(dir * Math.PI / 180) * len;
		}

		public function updateFrame(deltaTime: Number, shape: Shape): void {
			arrowsX = lengthdirX((speed * 100) * deltaTime, 26.57);
			arrowsY = lengthdirY((speed * 100) * deltaTime, 26.57);

			/*player.arrowsX = lengthdirX((player.speed+2),26.57);
			player.arrowsY = lengthdirY((player.speed+2),26.57);*/

			lastBox = Game.boxCollection.getLast();
			if (lastBox.y > -lastBox.height / 2 - 150) {
				Game.boxCollection.createBox();
			}

			var shapeArrayNum: int = Game.boxCollection.getLastIndex();

			for (var i: int = shapeArrayNum; i >= 0; i--) {
				box = Game.boxCollection.getOnIndex(i);
				var boxX = box.x,
					boxY = box.y,
					boxW = box.width,
					boxH = box.height;
				if ((x >= boxX - boxW && x <= boxX + boxW) && (y >= boxY - boxH && y <= boxY + boxH)) {
					//trace(i);
					var randZ: int = 1;
					if (box.rand) {
						randZ = -1;
					}

					var arrPoint: Array = [
						[boxX, boxY - boxH / 2],
						[boxX + boxW / 2 * randZ, boxY],
						[boxX + boxW * randZ, boxY - boxH / 2],
						[boxX + boxW / 2 * randZ, boxY - boxH]
					];

					if (box.bonus) {
						var arrPointBonus: Array = [
							[boxX, boxY],
							[boxX - boxW / 2 / 3, boxY - 10 - boxH / 2 / 3],
							[boxX + boxW / 2 / 3, boxY - 10 - boxH / 2 / 3],
							[boxX, boxY - 35]
						];

						var collBonus: Boolean = false;

						for (var a = 0, b = arrPointBonus.length - 1; a < arrPointBonus.length; b = a++) {
							if (((arrPointBonus[a][1] > y) != (arrPointBonus[b][1] > y)) && (x < (arrPointBonus[b][0] - arrPoint[a][0]) * (y - arrPointBonus[a][1]) / (arrPointBonus[b][1] - arrPointBonus[a][1]) + arrPointBonus[a][0])) {
								collBonus = !collBonus;
							}
						}

						if (collBonus) {
							box.bonus = false;
							score += 2;
						}
					}

					var coll: Boolean = false;

					for (var a = 0, b = arrPoint.length - 1; a < arrPoint.length; b = a++) {
						if (((arrPoint[a][1] > y) != (arrPoint[b][1] > y)) && (x < (arrPoint[b][0] - arrPoint[a][0]) * (y - arrPoint[a][1]) / (arrPoint[b][1] - arrPoint[a][1]) + arrPoint[a][0])) {
							coll = !coll;
						}
					}

					if (box.bothCollision) {
						arrPoint = [
							[boxX + 50, boxY - boxH / 2 + 25],
							[boxX + boxW / 2 * randZ * (-1), boxY],
							[boxX + boxW * randZ * (-1), boxY - boxH / 2],
							[boxX + 50 + boxW / 2 * randZ * (-1), boxY - boxH + 25]
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
						Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, Game.keyDownFunc);
						Game.ui.retryButton.removeEventListener(MouseEvent.MOUSE_DOWN, Game.mouseDown);
						setTimeout(function () {
							Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, Game.keyDownFunc);
							Game.ui.retryButton.addEventListener(MouseEvent.MOUSE_DOWN, Game.mouseDown);
						}, 500);
					}
				}
				box.update(deltaTime);
				Render.box(box, shape, -Game.stage.stageHeight / 2);
			}
			x += arrowsX * (rigth ? 1 : -1);
		}

		public function nextLevel(): void {
			newLevel = Math.floor(score / 50);
			if (newLevel > level) {
				level = newLevel;

				speed += 0.05;

				Box.toFirstColor.color = Box.colorList[Math.floor(Math.random() * 5)];
				Box.toSecondColor.color = Box.toFirstColor.color;

				Box.toSecondColor.redOffset += 100;
				if (Box.toSecondColor.redOffset > 255) Box.toSecondColor.redOffset = 255;
				Box.toSecondColor.greenOffset += 100;
				if (Box.toSecondColor.greenOffset > 255) Box.toSecondColor.greenOffset = 255;
				Box.toSecondColor.blueOffset += 100;
				if (Box.toSecondColor.blueOffset > 255) Box.toSecondColor.blueOffset = 255;
			}
		}

		public function gameOverUpdate(shape: Shape): void {
			var shapeArrayNum = Game.boxCollection.getLastIndex();

			for (var i = shapeArrayNum; i >= 0; i--) {
				box = Game.boxCollection.getOnIndex(i);
				if (box.y - Game.stage.stageHeight - box.height / 2 + Game.stage.stageHeight / 3 > 0) {
					box.y += 6;
				}
				Render.box(box, shape, -Game.stage.stageHeight / 2);
				//Render.box(box, shape2, stage.stageHeight/2);
			}

			if (!addPlayer) {
				//stage.addChild(shape2);

				Game.stage.addChild(Game.ui.gameOverText);
				Game.stage.addChild(Game.ui.scoreText);
				Game.stage.addChild(Game.ui.retryButton);
				Game.stage.addChild(Game.ui.shareButton);

				Game.stage.removeChild(Game.ui.scoreField);

				addPlayer = true;
				gamesPlayed += 1;
				Game.ui.gamesPlayedField.text = 'GAMES PLAYED: ' + gamesPlayed;
				Game.ui.gameOverScoreField.text = score.toString();
				Game.VK.api('storage.set', {
					key: 'gamesPlayed',
					value: gamesPlayed,
					user_id: Game.flashVars['viewer_id']
				}, function () {}, function () {});

				//смена цвета плашки со счетом
				var my_color: ColorTransform = new ColorTransform();
				my_color.color = 0xE1E1E1;
				Game.ui.scoreText.getChildAt(0).transform.colorTransform = my_color;

				my_color.color = 0x333333;
				Game.ui.scoreText.getChildAt(1).transform.colorTransform = my_color;
				Game.ui.scoreText.getChildAt(2).transform.colorTransform = my_color;
				Game.ui.gameOverScoreField.textColor = my_color.color;
				Game.ui.gameOverBestScoreField.textColor = my_color.color;
				//конец смены цвета
				if (score > bestScore) {
					bestScore = score;
					Game.ui.bestScoreField.text = 'BEST SCORE: ' + bestScore;
					Game.ui.gameOverBestScoreField.text = '' + bestScore;

					//смена цвета плашки со счетом
					my_color = new ColorTransform();
					my_color.color = 0xFD44E8;
					Game.ui.scoreText.getChildAt(0).transform.colorTransform = my_color;

					my_color.color = 0xFFFEFE;
					Game.ui.scoreText.getChildAt(1).transform.colorTransform = my_color;
					Game.ui.scoreText.getChildAt(2).transform.colorTransform = my_color;
					Game.ui.gameOverScoreField.textColor = my_color.color;
					Game.ui.gameOverBestScoreField.textColor = my_color.color;
					//конец смены цвета

					//stage.addChild();
					Game.VK.api('storage.set', {
						key: 'bestScore',
						value: bestScore,
						user_id: Game.flashVars['viewer_id']
					}, function () {}, function () {});
				} else {}
			}


			if (rigth) {
				x += arrowsX;
			} else {
				x -= arrowsX;
			}
			gravity += 0.4;
			y += gravity;
		}

		public function collisionsss(arrPoint: Array): void {

		}

		public function gameOverFunc(): void {

			Box.toFirstColor.color = 0x3F6CA3;

			Box.toSecondColor.color = Box.toFirstColor.color;

			Box.toSecondColor.redOffset += 100;
			if (Box.toSecondColor.redOffset > 255) Box.toSecondColor.redOffset = 255;
			Box.toSecondColor.greenOffset += 100;
			if (Box.toSecondColor.greenOffset > 255) Box.toSecondColor.greenOffset = 255;
			Box.toSecondColor.blueOffset += 100;
			if (Box.toSecondColor.blueOffset > 255) Box.toSecondColor.blueOffset = 255;

			setTimeout(function () {
				Game.ui.gameOverText.movX = stage.stageWidth / 2;
			}, 200);
			setTimeout(function () {
				Game.ui.scoreText.movX = stage.stageWidth / 2;
			}, 300);
			setTimeout(function () {
				Game.ui.retryButton.movX = stage.stageWidth / 2;
			}, 400);
			setTimeout(function () {
				Game.ui.shareButton.movX = stage.stageWidth / 2;
			}, 500);
		}

	}

}