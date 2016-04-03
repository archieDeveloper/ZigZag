package  {
	
	import flash.display.Shape;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.display.SpreadMethod;
	import flash.display.InterpolationMethod;
	
	public class Render {
		
		public function Render() {
		}
				
		public static function box(box:Box, shape:Shape, ifY:int) {
			
			if(box.y > ifY && !(box.y > Game.stage.stageHeight+box.height/2) && !(box.y < -box.height/2-150)){
				shape.graphics.beginFill(Box.firstColor.color);

				var commands:Vector.<int>  = new Vector.<int>(4,true);
				var coords:Vector.<Number>  = new Vector.<Number>(8,true);
				
				commands[0] = 1;
				coords[0] = box.x;
				coords[1] = box.y+box.height/2;

				commands[1] = 2;
				coords[2] = box.x+box.width/2;
				coords[3] = box.y;
				
				commands[2] = 2;
				coords[4] = box.x+box.width/2;
				coords[5] = box.y+150;

				commands[3] = 2;
				coords[6] = box.x;
				coords[7] = box.y+box.height/2+150;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				
				shape.graphics.beginFill(Box.firstColor.color);
									
				
				commands[0] = 1;
				coords[0] = box.x-box.width/2;
				coords[1] = box.y;

				commands[1] = 2;
				coords[2] = box.x;
				coords[3] = box.y+box.height/2;
				
				commands[2] = 2;
				coords[4] = box.x;
				coords[5] = box.y+box.height/2+150;

				commands[3] = 2;
				coords[6] = box.x-box.width/2;
				coords[7] = box.y+150;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				
				shape.graphics.beginGradientFill(GradientType.RADIAL,
									[Box.secondColor.color, Box.firstColor.color], 
									[1, 1], 
									[0, 255],  
									Box.matrix,  
									SpreadMethod.PAD,  
									InterpolationMethod.LINEAR_RGB,  
									0);
				
				commands[0] = 1;
				coords[0] = box.x-box.width/2;
				coords[1] = box.y;

				commands[1] = 2;
				coords[2] = box.x;
				coords[3] = box.y-box.height/2;
				
				commands[2] = 2;
				coords[4] = box.x+box.width/2;
				coords[5] = box.y;

				commands[3] = 2;
				coords[6] = box.x;
				coords[7] = box.y+box.height/2;
				shape.graphics.drawPath(commands,coords);
				shape.graphics.endFill();
				
				if (box.bonus) {
					Render.bonus(box, shape);
				}
				
				/*if ((player.x >= box.x-box.width && player.x <= box.x+box.width) && (player.y >= box.y-box.height && player.y <= box.y+box.height)) {
					shape.graphics.lineStyle(1,0,0.5);
					var randZ = 1;
					if (box.rand) {
						randZ = -1;
					}
					shape.graphics.moveTo(box.x,box.y-box.height/2);
					shape.graphics.lineTo(box.x+box.width/2*randZ,box.y);
					shape.graphics.lineTo(box.x+box.width*randZ,box.y-box.height/2);
					shape.graphics.lineTo(box.x+box.width/2*randZ,box.y-box.height);
					shape.graphics.lineTo(box.x,box.y-box.height/2);
					
					if(box.bothCollision){
						shape.graphics.moveTo(box.x+50,box.y-box.height/2+25);
						shape.graphics.lineTo(box.x+box.width/2*randZ*(-1),box.y);
						shape.graphics.lineTo(box.x+box.width*randZ*(-1),box.y-box.height/2);
						shape.graphics.lineTo(box.x+50+box.width/2*randZ*(-1),box.y-box.height+25);
						shape.graphics.lineTo(box.x+50,box.y-box.height/2+25);
					}
				}*/
			}
			
		}
		
		
		public static function bonus(box:Box, shape:Shape) {
			var commands:Vector.<int>  = new Vector.<int>(4,true);
				var coords:Vector.<Number>  = new Vector.<Number>(8,true);
			shape.graphics.beginFill(0xFD65EE);
			commands = new Vector.<int>(3,true);
			coords = new Vector.<Number>(6,true);
			
			commands[0] = 1;
			coords[0] = box.x;
			coords[1] = box.y;

			commands[1] = 2;
			coords[2] = box.x-box.width/2/3;
			coords[3] = box.y-10-box.height/2/3;
			
			commands[2] = 2;
			coords[4] = box.x;
			coords[5] = box.y-10;
			shape.graphics.drawPath(commands,coords);
			shape.graphics.endFill();
			
			/**********  2  *********/
			shape.graphics.beginFill(0xB122A2);
			
			commands[0] = 1;
			coords[0] = box.x;
			coords[1] = box.y;

			commands[1] = 2;
			coords[2] = box.x+box.width/2/3;
			coords[3] = box.y-10-box.height/2/3;
			
			commands[2] = 2;
			coords[4] = box.x;
			coords[5] = box.y-10;
			shape.graphics.drawPath(commands,coords);
			shape.graphics.endFill();
			
			/**********  3  *********/
			shape.graphics.beginFill(0xFE9EF5);
			
			commands[0] = 1;
			coords[0] = box.x;
			coords[1] = box.y-10;

			commands[1] = 2;
			coords[2] = box.x-box.width/2/3;
			coords[3] = box.y-10-box.height/2/3;
			
			commands[2] = 2;
			coords[4] = box.x;
			coords[5] = box.y-35;
			shape.graphics.drawPath(commands,coords);
			shape.graphics.endFill();
			
			/**********  4  *********/
			shape.graphics.beginFill(0xFE43EA);
			
			commands[0] = 1;
			coords[0] = box.x;
			coords[1] = box.y-10;

			commands[1] = 2;
			coords[2] = box.x+box.width/2/3;
			coords[3] = box.y-10-box.height/2/3;
			
			commands[2] = 2;
			coords[4] = box.x;
			coords[5] = box.y-35;
			shape.graphics.drawPath(commands,coords);
			shape.graphics.endFill();
		}
	}
	
}
