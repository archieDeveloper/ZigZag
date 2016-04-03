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
		
	    // 
		public var arrowsX:int = 0;
		public var arrowsY:int = 0;
		
		public function Player(positionX:int = 0, positionY:int = 0) {
			// constructor code
			trace(Game.stage);
			x = positionX;
			y = positionY;
		}
	}
	
}
