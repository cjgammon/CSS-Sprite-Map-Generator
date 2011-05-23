package texturemapper {
	import com.bit101.components.Label;
	import flash.display.DisplayObject;
	import org.osflash.signals.Signal;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.Sprite;
	/**
	 * @author cjgammon
	 */
	
	
	public class TImage extends Sprite 
	{
		public var DESTROY:Signal = new Signal(DisplayObject);
		
		public var snapping:Boolean = false;
		
		public var square:TSquare;
		public var handles:Array = [];
		public var position:Point = new Point(0, 0);
		public var size:Point = new Point(0, 0);
		
		private var nameText:Label;
		private var positionText:Label;
		private var sizeText:Label;

		public function TImage(_x:Number = 0, _y:Number = 0, _width:Number = 10, _height:Number = 10)
		{	
			if(snapping){
				_x = Math.round(_x/10)*10;
				_y = Math.round(_y/10)*10;
			}
	
			this.x = _x;
			this.y = _y;
		
			position.x = _x;
			position.y = _y;
			
			size.x = _width;
			size.y = _height;	
			
			square = new TSquare(_width, _height);
			addChild(square);
			
			nameText = new Label(this, 5, 5, this.name);
			positionText = new Label(this, 5, 20, position.x+","+position.y);
			sizeText = new Label(this, 5, 30, size.x+","+size.y);
			
			for(var i:int=0;i<4;i++){
				var handle:THandle = new THandle();
				handle.name = String(i);
				switch(i)
				{
					case 0:
						handle.x = square.x;
						handle.y = square.y;
						handle.addEventListener(MouseEvent.MOUSE_DOWN, handle_move_MOUSE_DOWN, false);
						handle.addEventListener(MouseEvent.MOUSE_UP, handle_move_MOUSE_UP, false);
						break;	
					case 1:
						handle.x = square.width;
						handle.y = square.y;
						//handle.addEventListener(MouseEvent.MOUSE_DOWN, handle_close_MOUSE_DOWN);
						break;
					case 2:
						handle.x = square.width;
						handle.y = square.height;
						handle.addEventListener(MouseEvent.MOUSE_DOWN, handle_resize_MOUSE_DOWN, false);
						handle.addEventListener(MouseEvent.MOUSE_UP, handle_resize_MOUSE_UP, false);
						break;
					case 3:
						handle.x = square.x;
						handle.y = square.height;
						break;
				}
				
				addChild(handle);
				handles.push(handle);
			}
		}
		
		/*
		 * @param obj : object defining x, y, w, y for updating values
		 */
		public function update(obj:Object):void
		{
			if(obj.name){
				this.name = obj.name;
			}
			if(obj.x){
				this.x = obj.x;
				if(snapping){
					this.x = Math.round(this.x/10)*10;
				}
				position.x = this.x;
			}
			if(obj.y){
				this.y = obj.y;
				if(snapping){
					this.y = Math.round(this.y/10)*10;
				}
				position.y = this.y;
			}
			
			if(obj.w){
				if(snapping){
					square.size(Math.round(obj.w/10)*10, Math.round(size.y/10)*10);
				}else{
					square.size(obj.w, size.y);
				}
				size.x = obj.w;
			}
			if(obj.h){
				if(snapping){
					square.size(Math.round(size.x/10)*10, Math.round(obj.h/10)*10);
				}else{
					square.size(size.x, obj.h);
				}
				size.y = obj.h;
			}
			updateHandles();
			
			nameText.text = this.name;
			sizeText.text = size.x+","+size.y;	
			positionText.text = position.x+","+position.y;	
		}
		
		/*
		private function handle_close_MOUSE_DOWN(e:MouseEvent):void
		{
			DESTROY.dispatch(this);			
		}
		*/
		private function handle_move_MOUSE_DOWN(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, handle_move_MOUSE_UP, true);
			this.addEventListener(Event.ENTER_FRAME, handle_move_ENTER_FRAME);
			this.startDrag();
		}
		
		private function handle_move_MOUSE_UP(e:MouseEvent):void
		{
			if(stage){
				if(stage.hasEventListener(MouseEvent.MOUSE_DOWN)){
					stage.removeEventListener(MouseEvent.MOUSE_UP, handle_move_MOUSE_UP);
				}
			}
			
			if(this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, handle_move_ENTER_FRAME);
			}
			this.stopDrag();
		}

		private function handle_move_ENTER_FRAME(e : Event) : void 
		{
			if(snapping){
				this.x = Math.round(this.x/10)*10;
				this.y = Math.round(this.y/10)*10;
			}
			position.x = this.x;
			position.y = this.y;
			positionText.text = position.x+","+position.y;			
		}
		
		private function handle_resize_MOUSE_DOWN(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, handle_resize_MOUSE_UP, true);
			this.addEventListener(Event.ENTER_FRAME, handle_resize_ENTER_FRAME);
		}
		
		private function handle_resize_MOUSE_UP(e:MouseEvent):void
		{
			if(stage){
				if(stage.hasEventListener(MouseEvent.MOUSE_UP)){
					stage.removeEventListener(MouseEvent.MOUSE_UP, handle_resize_MOUSE_UP);
				}
			}
			
			if(this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, handle_resize_ENTER_FRAME);
			}
		}
		
		private function handle_resize_ENTER_FRAME(e : Event) : void 
		{
			if(snapping){
				square.size(Math.round(mouseX/10)*10, Math.round(mouseY/10)*10);
			}else{
				square.size(mouseX, mouseY);
			}
			
			size.x = square.width;
			size.y = square.height;
			sizeText.text = size.x+","+size.y;			
			updateHandles();
		}
		
		private function updateHandles():void
		{
			for(var i:int=0;i<handles.length;i++){
				var handle:THandle = handles[i];
				switch(i)
				{
					case 0:
						handle.x = square.x;
						handle.y = square.y;
						break;	
					case 1:
						handle.x = square.width;
						handle.y = square.y;
						break;
					case 2:
						handle.x = square.width;
						handle.y = square.height;
						break;
					case 3:
						handle.x = square.x;
						handle.y = square.height;
						break;
				}
			}
		}
		
	}
}
