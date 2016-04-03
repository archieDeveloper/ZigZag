﻿package  {
	
	public class Box {
		
		public var x:int = 0;
		public var y:int = 0;
		
		public var width:int = 100;
		public var height:int = 50;
		
		public var rand:Boolean = Math.random()<.5;
		public var bothCollision:Boolean = false;
		
		public var bonus:Boolean = false;
		
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
	}
	
}
