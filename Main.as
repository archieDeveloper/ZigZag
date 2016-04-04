﻿package {
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.ColorTransform;
	import flash.system.System;

	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Main extends Sprite {

		private var loader: URLLoader = new URLLoader();
		private var photoLoader: Loader = new Loader();

		public var shape: Shape,
			shape2: Shape;

		public var date: Date = new Date();
		public var lastTime = date.getTime();

		public var fpsField: TextField = new TextField();
		public var fps: int = 0;

		public function Main(): void {
			Game.Init(stage);
			Game.VK.api(
				'getProfiles', {
					uids: Game.flashVars['viewer_id'],
					fields: 'photo_100'
				},
				fetchUserInfo,
				onApiRequestFail
			);
			/*VK.api('storage.set', { key:'bestScore',value:0,user_id:flashVars['viewer_id']}, function(){
			}, function(){});*/

		}
		private function fetchUserInfo(data: Object): void {
			// Example of fetching info from API request
			/*tf.appendText("\n// -- API request result:\n");
			for (var key: String in data[0]) {
			  tf.appendText(key + "=" + data[0][key] + "\n");
			}*/

			var request2: URLRequest = new URLRequest(data[0]['photo_100']);
			photoLoader.load(request2);
			photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onloaded);
		}

		private function onApiRequestFail(data: Object): void {
			// Example of fetching fail from API request
			//tf.appendText("Error: "+data.error_msg+"\n");
			initApp();
		}

		private function onloaded(e: Event): void {
			// отображаем загруженный аватар
			photoLoader.x = (550 - photoLoader.width) / 2;
			photoLoader.y = (400 - photoLoader.height) / 2;
			//addChild(photoLoader);

			Game.VK.api(
				'storage.get', {
					key: 'gamesPlayed',
					user_id: Game.flashVars['viewer_id']
				},
				function (data) {
					Game.player.gamesPlayed = parseInt(data);
					Game.ui.gamesPlayedField.text = 'GAMES PLAYED: ' + Game.player.gamesPlayed;

					Game.VK.api(
						'storage.get', {
							key: 'bestScore',
							user_id: Game.flashVars['viewer_id']
						},
						function (data) {
							Game.player.bestScore = parseInt(data);
							Game.ui.bestScoreField.text = 'BEST SCORE: ' + Game.player.bestScore;
							initApp();
						},
						function () {}
					);
				},
				function () {}
			);
		}

		public function initApp(): void {
			Box.matrix.createGradientBox(stage.stageWidth * 2, stage.stageHeight, 0, -stage.stageWidth / 2, 0);

			Box.firstColor.color = 0x3F6CA3;
			Box.toFirstColor.color = 0x3F6CA3;

			Box.secondColor.color = Box.firstColor.color;

			Box.secondColor.redOffset += 100;
			if (Box.secondColor.redOffset > 255) Box.secondColor.redOffset = 255;
			Box.secondColor.greenOffset += 100;
			if (Box.secondColor.greenOffset > 255) Box.secondColor.greenOffset = 255;
			Box.secondColor.blueOffset += 100;
			if (Box.secondColor.blueOffset > 255) Box.secondColor.blueOffset = 255;

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
			setInterval(function () {
				fpsField.text = 'FPS: ' + Math.round(fps) + '\nID: ' + Game.flashVars['viewer_id'] + '\nMemory: ' + System.totalMemory / 1024 / 1024;
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

			stage.addEventListener(KeyboardEvent.KEY_DOWN, Game.keyDownFunc);
			stage.addEventListener(KeyboardEvent.KEY_UP, Game.keyUpFunc);
			stage.addEventListener(Event.ENTER_FRAME, enterFramePhy);
		}


		function enterFramePhy(e: Event): void {

			date = new Date();
			var now = date.getTime(),
				dt = (now - lastTime) / 1000.0,
				i, a, b;
			fps = 1000.0 / (now - lastTime);


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
				Game.boxCollection.eachBox(function (box) {
					Render.box(box, shape, -Game.stage.stageHeight / 2);
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

		function toColorAnim(fromColor, toColor): ColorTransform {
			//var returnColor:ColorTransform = new ColorTransform();
			fromColor.redOffset += (toColor.redOffset - fromColor.redOffset) / 25;
			fromColor.greenOffset += (toColor.greenOffset - fromColor.greenOffset) / 25;
			fromColor.blueOffset += (toColor.blueOffset - fromColor.blueOffset) / 25;

			return fromColor;
		}
	}

}