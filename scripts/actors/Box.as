package scripts.actors
{

	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import scripts.scenes.Game;

	public class Box {

		public static var matrix: Matrix = new Matrix();

		public static var firstColor: ColorTransform = new ColorTransform();
		public static var toFirstColor: ColorTransform = new ColorTransform();

		public static var secondColor: ColorTransform = new ColorTransform();
		public static var toSecondColor: ColorTransform = new ColorTransform();

		public static var colorList: Array = new Array();

		public var x: Number = 0;
		public var y: Number = 0;

		public var width: int = 100;
		public var height: int = 50;

		public var rand: Boolean = Math.random() < .5;
		public var bothCollision: Boolean = false;

		public var bonus: Boolean = false;

		public function Box(options = null) {
			if (options != null) {
				if (options.x != null) {
					x = options.x;
				}
				if (options.y != null) {
					y = options.y;
				}
				if (options.width != null) {
					width = options.width;
				}
				if (options.height != null) {
					height = options.height;
				}

				if (options.rand != null) {
					rand = options.rand;
				}
				if (options.bothCollision != null) {
					bothCollision = options.bothCollision;
				}
				if (options.bonus != null) {
					bonus = options.bonus;
				}
			}
		}

		public function update(deltaTime: Number): void {
			if (y - Game.stage.stageHeight - height / 2 + Game.stage.stageHeight / 3 > 0) {
				y += 6;
			}
			y += Game.player.arrowsY;
		}

	}

}