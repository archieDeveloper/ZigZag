package
{
	
	public class BoxCollection
	{
		
		private var boxCollection:Vector.<Box>;
		
		public function BoxCollection()
		{
		}
		
		public function generate():void
		{
			boxCollection = new Vector.<Box>(38,true);
			boxCollection[0] = new Box({
				x: Game.stage.stageWidth/2,
				y: Game.stage.stageHeight/2,
				width: 1000,
				height: 500,
				rand: true,
				bothCollision: true
			});
			boxCollection[1] = new Box({
				x: boxCollection[0].x+50,
				y: boxCollection[0].y-boxCollection[0].height/2,
				width: 100,
				height: 50,
				rand: true,
				bothCollision: true
			});
			for (var index:int = 1, count:int = boxCollection.length-1; index < count; index++) {
				var rand:Boolean, currentBox:Box, isNoSpaceRight:Boolean, isNoSpaceLeft:Boolean, newBox:Box;
				rand = Math.random()<.5;
				currentBox = boxCollection[index];
				isNoSpaceRight = (currentBox.x > Game.stage.stageWidth-currentBox.width && rand);
				isNoSpaceLeft = (currentBox.x < currentBox.width && !rand)
				if (isNoSpaceRight || isNoSpaceLeft) {
					rand = !rand;
				}
				newBox = new Box({
					x: currentBox.x+(rand ? currentBox.width/2 : -currentBox.width/2),
					y: currentBox.y-currentBox.height/2,
					width: 100,
					height: 50,
					rand: rand,
					bothCollision: false,
					bonus: Math.floor(Math.random()*5) ? false : true
				});
				currentBox.rand = rand;
				boxCollection[index+1] = newBox;
			}
		}
		
		public function getOnIndex(index:int):Box
		{
			return boxCollection[index];
		}
		
		public function getLast():Box
		{
			return boxCollection[boxCollection.length-1];
		}
		
		public function getFirst():Box
		{
			return boxCollection[0];
		}
		
		public function getLastIndex():int
		{
			return boxCollection.length-1;
		}
		
		public function setOnIndex(index:int, box:Box):void
		{
			boxCollection[index] = box;
		}
		
	}
	
}
