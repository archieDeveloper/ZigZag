package  {
	
	import flash.display.Stage;
	
	import vk.api.MD5;
	
	import vk.APIConnection;
	import vk.events.*;
	import vk.ui.VKButton;
	
	public class Game {
		
		public static var stage:Stage = null;
		
		// игра началась?
		public static var isStarted:Boolean = false;
		
		// игра проиграна?
		public static var isOver:Boolean = false;
		
		// Главный герои игры
		public static var player:Player;
		// Коллекция платформ
		public static var boxCollection:BoxCollection;
		// UI
		public static var ui:UI;
		
		
		public static var flashVars:Object; 
		public static var VK: APIConnection;
		
		public function Game() {
		}
		
		public static function Init():void
		{
			flashVars = stage.loaderInfo.parameters as Object;
			VK = new APIConnection(flashVars);
			
			player = new Player();
			boxCollection = new BoxCollection();
			ui = new UI();
		}
		
		// Ссылка на главый объект Stage
		public static function SetStage(stageRef:Stage) {
			stage = stageRef;
		}
	}
	
}
