package  {
	
	import flash.display.Stage;
	
	public class Game {
		
		public static var stage:Stage = null;
		
		public function Game() {
		}
		
		public static function SetStage(stageRef:Stage) {
			stage = stageRef;
		}
	}
	
}
