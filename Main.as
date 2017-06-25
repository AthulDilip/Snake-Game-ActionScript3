package{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.net.SharedObject;

 //used for ENTER_FRAME event

	public class Main extends MovieClip{
		const speed:int = 10;//speed of the snake
		var score:int;
		var vx:int;
		var vy:int;
		var gFood:Food;
		var head:SnakePart;
		var SnakeDirection:String;
		var snake:Array;
		var sharedData:SharedObject;
		
		public function Main(){
			init();
		}
		function init():void {
			//Initialize everything!
			vx = 1; vy = 0;
			score = 0;
			snake = new Array();
			SnakeDirection = "";
			//add food to the stage
			addFood();
			//add snakes head to the stage
			head = new SnakePart();
			head.x = stage.stageWidth/2;
			head.y = stage.stageHeight/2;
			snake.push(head);
			addChild(head);
			
			//create the sharedobject variable that will allow us to save and load data
			sharedData = SharedObject.getLocal("snake_info");
			if(sharedData.data.highScore == null){ //if it is being called for the first time it will be null. so change it to 0.
				sharedData.data.highScore = 0;
			}
			
			stage.addEventListener(KeyboardEvent.KEY_UP , onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN , onKeyDown);
			addEventListener(Event.ENTER_FRAME , onEnterFrame);
			//ENTER_FRAME listener is attached to main class and not to the stage directly
		}
		//This function will add food to the stage
		function addFood():void {
			gFood = new Food();
			gFood.x = 50 + Math.random()*(stage.stageWidth-100);
			gFood.y = 50 + Math.random()*(stage.stageHeight-100);
			addChild(gFood);
		}
		//this function will reset the game
		function reset():void {
			removeChild(gFood);
			addFood();
			head.x = stage.stageWidth/2;
			head.y = stage.stageHeight/2;
			vx = 1;vy = 0;
			
			for(var i = snake.length-1;i>0;--i){
				removeChild(snake[i]);
				snake.splice(i,1);
			}
		}
		function onKeyDown(event:KeyboardEvent):void{
			if(event.keyCode == Keyboard.LEFT){
			   SnakeDirection = "left";
			}else if (event.keyCode == Keyboard.RIGHT) {
			   SnakeDirection = "right";
			}else if (event.keyCode == Keyboard.UP) {
				SnakeDirection = "up";
			}else if (event.keyCode == Keyboard.DOWN) {
				SnakeDirection = "down";
			}
		}
		function onKeyUp(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.LEFT) {
				SnakeDirection = "";
			}else if(event.keyCode == Keyboard.RIGHT) {
			    SnakeDirection = "";
			}else if(event.keyCode == Keyboard.UP ) {
				SnakeDirection = "";
			}else if(event.keyCode == Keyboard.DOWN){
				SnakeDirection = "";
			}
		}
		function onEnterFrame(event:Event):void {
			//setting direction of velocity
			if(SnakeDirection == "left" && vx != 1) {
				vx = -1;
				vy = 0;
			}else if(SnakeDirection == "right" && vx != -1) {
				vx = 1;
				vy = 0;
			}else if(SnakeDirection == "up" && vy != 1) {
				vx = 0;
				vy = -1;
			}else if(SnakeDirection == "down" && vy != -1) {
				vx = 0;
				vy = 1;
			}
			
			//collison with stage
			if(head.x - head.width/2 <= 0){
				score = 0;
				reset();
			}
			if(head.x + head.width/2 >= stage.stageWidth){
				score = 0;
				reset();
			}
			if(head.y - head.height/2 <= 0){
				score = 0;
				reset();
			}
			if(head.y + head.height/2 >= stage.stageHeight){
				score = 0;
				reset();
			}
			//move body of the snake
			for(var i = snake.length-1;i>0;--i){
				snake[i].x = snake[i-1].x;
				snake[i].y = snake[i-1].y;
			}
			//changing the position of snake's head
			head.x += vx*speed;
			head.y += vy*speed;
			//collision with tail
			for(var i = snake.length-1;i>=1;--i){
				if(snake[0].x == snake[i].x && snake[0].y == snake[i].y){
					reset();
					break;
				}
			}
			//collision with food
			if(head.hitTestObject(gFood)){
				score += 1;
				if(score > sharedData.data.highScore){
					//if score greater than highscore then set highscore = score and save it.
					sharedData.data.highScore = score;
					sharedData.flush();
				}
				removeChild(gFood);
				addFood();
				var bodyPart = new SnakePart();
				bodyPart.x = snake[snake.length - 1].x;
				bodyPart.y = snake[snake.length - 1].y;
				snake.push(bodyPart);
				addChild(bodyPart);
			}
			//display scores
			txtScore.text = String(score);
			//display highscore
			txtHighScore.text = String(sharedData.data.highScore);
		}
	}
}