package  {
	
	import flash.display.Stage;
	
	public class Game {
		
		public static var stage:Stage = null;
		
		// игра началась?
		public static var isStarted:Boolean = false;
		
		// игра проиграна?
		public static var isOver:Boolean = false;
		
		public function Game() {
		}
		
		// Ссылка на главый объект Stage
		public static function SetStage(stageRef:Stage) {
			stage = stageRef;
		}
	}
	
}
