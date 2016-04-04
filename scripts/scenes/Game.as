package scripts.scenes
{

	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.*;

	import vk.api.MD5;

	import vk.APIConnection;
	import vk.events.*;
	import vk.ui.VKButton;
	
	import scripts.actors.Player;
	import scripts.components.BoxCollection;
	import scripts.components.UI;

	public class Game {

		public static var stage: Stage = null;

		// игра началась?
		public static var isStarted: Boolean = false;

		// игра проиграна?
		public static var isOver: Boolean = false;

		// Главный герои игры
		public static var player: Player;
		// Коллекция платформ
		public static var boxCollection: BoxCollection;
		// UI
		public static var ui: UI;


		public static var flashVars: Object;
		public static var VK: APIConnection;



		public static var spaceDown: Boolean = false;

		public function Game() {}

		public static function Init(stageRef: Stage): void {
			stage = stageRef;
			flashVars = stage.loaderInfo.parameters as Object;
			VK = new APIConnection(flashVars);

			player = new Player();
			boxCollection = new BoxCollection();
			trace(player.score);
			ui = new UI();
		}



		/*
		 *
		 * нажатие пробела
		 *
		 */
		public static function keyDownFunc(e: KeyboardEvent): void {
			if (e.keyCode === 32 && !spaceDown) {
				spaceDown = true;
				if (!Game.isStarted) {
					stage.addChild(Game.ui.scoreField);


					stage.removeChild(Game.ui.logo);
					stage.removeChild(Game.ui.gameInfo);
					stage.removeChild(Game.ui.spaceToPlay);
					Game.isStarted = true;
					Game.player.score -= 1;
					Game.ui.logo.movY = -100;
					Game.ui.gameInfo.movY = stage.stageHeight + 100;
				}
				if (!Game.isOver) {
					Game.player.rigth = !Game.player.rigth;
					Game.player.score += 1;
				}
			}
			if (e.keyCode === 86) {
				Game.isStarted = false;
			}
		}
		public static function keyUpFunc(e: KeyboardEvent): void {
			if (e.keyCode === 32) {
				spaceDown = false;
			}
		}

		public static function mouseDown(e: MouseEvent): void {
			stage.addChild(Game.ui.logo);
			stage.addChild(Game.ui.gameInfo);
			stage.addChild(Game.ui.spaceToPlay);
			retryGame();
		}



		public static function retryGame(): void {
			setTimeout(function () {
				Game.ui.gameOverText.movX = stage.stageWidth + Game.ui.gameOverText.width;
			}, 0);
			setTimeout(function () {
				Game.ui.scoreText.movX = stage.stageWidth + Game.ui.scoreText.width;
			}, 50);
			setTimeout(function () {
				Game.ui.retryButton.movX = stage.stageWidth + Game.ui.retryButton.width;
			}, 100);
			setTimeout(function () {
				Game.ui.shareButton.movX = stage.stageWidth + Game.ui.shareButton.width;
			}, 150);
			//stage.removeChild(shape2);

			Game.player.score = 0;
			Game.player.rigth = false;
			Game.player.x = stage.stageWidth / 2;
			Game.player.y = stage.stageHeight / 2;
			Game.isStarted = false;
			Game.isOver = false;
			Game.player.addPlayer = false;
			Game.player.speed = 3;
			Game.player.level = 0;
			Game.player.newLevel = 0;;

			Game.player.gravity = 0;

			Game.boxCollection.generate();

			Game.ui.logo.movY = stage.stageHeight / 2 / 3;
			Game.ui.spaceToPlay.alpha = 0;
			Game.ui.gameInfo.movY = stage.stageHeight / 1.5;
		}
	}

}