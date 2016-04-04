package  
{
	
	public class UI 
	{
		public var logo:Logo = new Logo();
		public var spaceToPlay:SpaceToPlay = new SpaceToPlay();
		public var bestScoreField:TextField = new TextField();
		public var gamesPlayedField:TextField = new TextField();
		public var gameInfo:MovieClip = new MovieClip();
		
		public var gameOverText:GameOverText = new GameOverText();
		public var gameOverScoreField:TextField = new TextField();
		public var gameOverBestScoreField:TextField = new TextField();
		
		public var retryButton:RetryButton = new RetryButton();
		public var scoreText:ScoreText = new ScoreText();
		public var shareButton:ShareButton = new ShareButton();
		public function UI() 
		{
			logo.cacheAsBitmap = true;
			logo.x = stage.stageWidth/2;
			logo.y = -100;
			logo.movY = stage.stageHeight/2/3;
			
			spaceToPlay.x = stage.stageWidth/2;
			spaceToPlay.y = stage.stageHeight/2/1.5;
			spaceToPlay.alpha = 0;
			
			bestScoreField.text = 'BEST SCORE: '+bestScore;
			bestScoreField.width = 500;
			bestScoreField.x = -bestScoreField.width/2;
			
			gamesPlayedField.text = 'GAMES PLAYED: '+gamesPlayed;
			gamesPlayedField.width = 500;
			gamesPlayedField.x = -gamesPlayedField.width/2;
			gamesPlayedField.y = 40;

			gameInfo.addChild(bestScoreField);
			gameInfo.addChild(gamesPlayedField);
			gameInfo.x = stage.stageWidth/2;
			gameInfo.y = stage.stageHeight+100;
			gameInfo.movY = stage.stageHeight/1.5;
			
			
			
			
			gameOverText.cacheAsBitmap = true;
			gameOverText.x = stage.stageWidth+gameOverText.width;
			gameOverText.movX = stage.stageWidth+gameOverText.width;
			gameOverText.y = 100;

			gameOverScoreField.text = player.score.toString();
			gameOverScoreField.width = 500;
			gameOverScoreField.y -= 70;
			gameOverScoreField.x = -gameOverScoreField.width/2;
			
			gameOverBestScoreField.text = ''+bestScore;
			gameOverBestScoreField.width = 500;
			gameOverBestScoreField.y += 30;
			gameOverBestScoreField.x = -gameOverBestScoreField.width/2;
			
			
			
			
			scoreText.x = stage.stageWidth+scoreText.width;
			scoreText.movX = stage.stageWidth+scoreText.width;
			scoreText.y = 300;


			retryButton.cacheAsBitmap = true;
			retryButton.x = stage.stageWidth+retryButton.width;
			retryButton.movX = stage.stageWidth+retryButton.width;
			retryButton.y = 480;


			shareButton.cacheAsBitmap = true;
			shareButton.x = stage.stageWidth+shareButton.width;
			shareButton.movX = stage.stageWidth+shareButton.width;
			shareButton.y = 580;
		}
		
		public function animate():void
		{
			logo.y += (logo.movY-logo.y)/10;
			gameInfo.y += (gameInfo.movY-gameInfo.y)/10;
			
			if(gameInfo.visible = true && gameInfo.y > stage.stageHeight+gameInfo.height/2){
				gameInfo.visible = false;
			} else {
				gameInfo.visible = true;
			}
			
			if(logo.visible = true && logo.y < 0-logo.height/2){
				logo.visible = false;
			} else {
				logo.visible = true;
			}
			
			scoreText.x += (scoreText.movX-scoreText.x)/10;
			retryButton.x += (retryButton.movX-retryButton.x)/10;
			shareButton.x += (shareButton.movX-shareButton.x)/10;
			gameOverText.x += (gameOverText.movX-gameOverText.x)/10;
			
			if(gameOverText.visible = true && gameOverText.x > stage.stageWidth+gameOverText.width/2){
				gameOverText.visible = false;
			} else {
				gameOverText.visible = true;
			}
			
			if(retryButton.visible = true && retryButton.x > stage.stageWidth+retryButton.width/2){
				retryButton.visible = false;
			} else {
				retryButton.visible = true;
			}
			
			if(shareButton.visible = true && shareButton.x > stage.stageWidth+shareButton.width/2){
				shareButton.visible = false;
			} else {
				shareButton.visible = true;
			}
			
			if(scoreText.visible = true && scoreText.x > stage.stageWidth+scoreText.width/2){
				scoreText.visible = false;
			} else {
				scoreText.visible = true;
			}

			if (spaceToPlay.alpha > 1) alphaF = false;
			if (spaceToPlay.alpha < 0 && !Game.isStarted) alphaF = true;
			
			if (alphaF) spaceToPlay.alpha += 0.025; else if(!alphaF) spaceToPlay.alpha -= 0.025;
			if (Game.isStarted) {
				spaceToPlay.alpha -= 0.05;
				if (spaceToPlay.alpha <= 0) {
					spaceToPlay.alpha = 0;
				}
			}
		}
	}
	
}
