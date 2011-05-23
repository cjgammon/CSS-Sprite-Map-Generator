package {
	import com.bit101.components.CheckBox;
	import flash.events.Event;
	import com.bit101.components.HSlider;
	import flash.display.Bitmap;
	import com.bit101.components.Label;
	import com.bit101.components.Window;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import texturemapper.TModel;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import texturemapper.TImage;
	import flash.events.MouseEvent;
	import flash.display.Sprite;

	/**
	 * @author cjgammon
	 */
	public class TextureMapper extends Sprite {
		
		public var _model:TModel;
		public var imageDefinitions:Array = [];
		
		private var SHIFT:Boolean = false;
		private var SPACE:Boolean = false;
		private var CMD:Boolean = false;
		
		private var opacity:Number = 50;
		
		private var snapping:Boolean = false;
		private var contentHolder:Sprite = new Sprite();
		private var boxHolder:Sprite = new Sprite();
		private var imageHolder:Sprite = new Sprite();
		private var imagePathInput:InputText;
		private var classNameInput:InputText;
		private var opacitySlider:HSlider;
		private var retinaCheckBox:CheckBox;
		private var sassCheckBox:CheckBox;
		private var current : TImage;
		
		public function TextureMapper() {
			
			stage.scaleMode = StageScaleMode.NO_SCALE; 
			stage.align = StageAlign.TOP_LEFT; 
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handle_stage_MOUSE_DOWN);
			stage.addEventListener(MouseEvent.MOUSE_UP, handle_stage_MOUSE_UP);

			_model = new TModel();
			
			init();
		}
		
		private function init():void
		{
			contentHolder = new Sprite();
			addChild(contentHolder);
			
			imageHolder = new Sprite();	
			contentHolder.addChild(imageHolder);
			
			boxHolder = new Sprite();
			boxHolder.alpha = opacity/100;
		 	contentHolder.addChild(boxHolder);
					
			var utilityWindow:Window = new Window(this, 5, 5, "Tools");
			utilityWindow.height = 300;
			utilityWindow.width = 110;
			utilityWindow.alpha = .8;
			utilityWindow.hasMinimizeButton = true;
			
			var loadImageButton:PushButton = new PushButton(utilityWindow, 5, 5, "laod image");
			loadImageButton.addEventListener(MouseEvent.CLICK, handle_loadImageButton_CLICK);
			
			var loadFileButton:PushButton = new PushButton(utilityWindow, 5, 30, "laod css");
			loadFileButton.addEventListener(MouseEvent.CLICK, handle_loadFileButton_CLICK);
			
			var saveFileButton:PushButton = new PushButton(utilityWindow, 5, 55, "save css");
			saveFileButton.addEventListener(MouseEvent.CLICK, handle_saveFileButton_CLICK);
			
			var label1:Label = new Label(utilityWindow, 5, 75, "image path");
			imagePathInput = new InputText(utilityWindow, 5, 90, "imagepath");
			
			var label2:Label = new Label(utilityWindow, 5, 105, "classname");
			classNameInput = new InputText(utilityWindow, 5, 120, "classname");
			
			var label3:Label = new Label(utilityWindow, 5, 135, "opacity");
			opacitySlider = new HSlider(utilityWindow, 5, 155, handle_opacitySlider_UPDATE);
			opacitySlider.value = opacity;
			
			retinaCheckBox = new CheckBox(utilityWindow, 5, 180, "retina", handle_retinaCheckBox_UPDATE);
			
			sassCheckBox = new CheckBox(utilityWindow, 5, 200, "sass", handle_sassCheckBox_UPDATE);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handle_this_KEY_DOWN, false);
			stage.addEventListener(KeyboardEvent.KEY_UP, handle_this_KEY_UP, false);
		}
		
		private function handle_this_KEY_DOWN(e:KeyboardEvent):void
		{
			var nudgeValue:Number = snapping ? 10 : 1;
			trace(e.keyCode);
			
			switch(e.keyCode){
				case 13:	//RETURN
					if(current){
						current.update({name:classNameInput.text});
					}
				case 15:	//CMD
					CMD = true;
					break;
				case 16:	//SHIFT
					SHIFT = true;
					break;
				case 32:	//SPACE
					SPACE = true;
					break;
				case 37:	//LEFT
					if(current){
						if(SHIFT){
							current.update({w:current.size.x-nudgeValue});
						}else{
							current.update({x:current.position.x-nudgeValue});
						}
					}
					break;
				case 38:	//UP
					if(current){
						if(SHIFT){
							trace(current.size.y);
							trace(current.size.y-nudgeValue);
							current.update({h:current.size.y-nudgeValue});
						}else{
							current.update({y:current.position.y-nudgeValue});
						}
					}
					break;
				case 39:	//RIGHT
					if(current){
						if(SHIFT){
							current.update({w:current.size.x+nudgeValue});						
						}else{
							current.update({x:current.position.x+nudgeValue});
						}
					}
					break;
				case 40:	//DOWN
					if(current){
						if(SHIFT){
							current.update({h:current.size.y+nudgeValue});
						}else{
							current.update({y:current.position.y+nudgeValue});
						}
					}
					break;
				case 68:	//D
					addImageDefinition(mouseX-contentHolder.x, mouseY-contentHolder.y);
					break;
				case 83:	//S
					if(CMD==true){
					//	_model.saveCSS(imageDefinitions);					
					}
					break;
				case 186:	//;
					toggleSnapping();
					break;
				case 219:
					getPrevious();
					break;
				case 221:
					getNext();
					break;
			}
		}
		
		private function handle_this_KEY_UP(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case 15:	//CMD
					CMD = false;
					break;
				case 16:	//SHIFT
					SHIFT = false;
					break;
				case 32:	//SPACE
					SPACE = false;
					break;
				case 68:
					break;
			}
		}
		
		private function handle_stage_MOUSE_DOWN(event : MouseEvent) : void 
		{
			if(SPACE){
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handle_stage_MOUSE_MOVE);
			}
		}

		private function handle_stage_MOUSE_MOVE(event : MouseEvent) : void 
		{
			contentHolder.startDrag();
		}

		private function handle_stage_MOUSE_UP(event : MouseEvent) : void 
		{
			contentHolder.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handle_stage_MOUSE_MOVE);
		}
		
		private function handle_image_CLICK(event : MouseEvent) : void 
		{
			var target : TImage = event.target is TImage ? TImage(event.target) : DisplayObject(event.target).parent is TImage ? TImage(DisplayObject(event.target).parent): null;
			for(var i:int=0;i<imageDefinitions.length;i++){
				TImage(imageDefinitions[i]).alpha = .8;
			}
			if(target&&boxHolder.numChildren>0){
				target.alpha = 1;
				boxHolder.setChildIndex(target, boxHolder.numChildren-1);
			}
			classNameInput.text = target.name;
			current = target;
		}
		
		private function handle_opacitySlider_UPDATE(event:Event):void
		{
			opacity = event.target.value;
			boxHolder.alpha = opacity/100;
		}
		
		private function handle_retinaCheckBox_UPDATE(event:Event):void
		{
			_model.retina = event.target.selected;
		}
		
		private function handle_sassCheckBox_UPDATE(event:Event):void
		{
			_model.sass = event.target.selected;
		}
		
		/*LOAD IMAGE*/
		private function handle_loadImageButton_CLICK(e:MouseEvent):void
		{
			_model.LOADED_IMAGE.add(handle_IMAGE_LOADED);
			_model.loadImage();
		}
		
		private function handle_IMAGE_LOADED(dsp:DisplayObject):void
		{
			trace("loaded");
			imageHolder.addChild(dsp);
		}
		
		/*LOAD CSS*/
		private function handle_loadFileButton_CLICK(e:MouseEvent):void
		{
			_model.LOADED_CSS.add(handle_CSS_LOADED);
			_model.loadCSS();
		}
		
		private function handle_CSS_LOADED(array:Array):void
		{
			for(var i:int=0;i<array.length;i++){
				addImageDefinition(array[i].x, array[i].y, array[i].width, array[i].height, array[i].name);
			}
		}
		
		/*SAVE FILE*/
		private function handle_saveFileButton_CLICK(e:MouseEvent):void
		{
			_model.saveCSS(imageDefinitions, imagePathInput.text);				
		}
		
		private function handle_image_DESTROY(image:DisplayObject):void
		{	
			if(boxHolder.contains(image)){
				boxHolder.removeChild(image);
			}
			
			for(var i:int=0;i<imageDefinitions.length;i++){
				if(imageDefinitions[i]==image){
					imageDefinitions.splice(i, 1);
				}
			}
			image = null;
		}
		
		private function getNext():void
		{
			var num:int;
			for(var i:int=0;i<imageDefinitions.length;i++){
				if(imageDefinitions[i]==current){
					num = i<imageDefinitions.length-1 ? i+1 : 0;
				}
			}
			var target:TImage = imageDefinitions[num];
			if(target&&boxHolder.numChildren>0){
				target.alpha = 1;
				boxHolder.setChildIndex(target, boxHolder.numChildren-1);
			}
			classNameInput.text = target.name;
			current = target;		
		}
		
		private function getPrevious():void
		{
			var num:int;
			for(var i:int=0;i<imageDefinitions.length;i++){
				if(imageDefinitions[i]==current){
					num = i>0 ? i-1 : imageDefinitions.length-1;
				}
			}
			var target:TImage = imageDefinitions[num];
			if(target&&boxHolder.numChildren>0){
				target.alpha = 1;
				boxHolder.setChildIndex(target, boxHolder.numChildren-1);
			}
			classNameInput.text = target.name;
			current = target;
		}
		
		private function toggleSnapping():void
		{
			if(snapping){
				snapping = false;
			}else{
				snapping = true;
			}
			
			for(var i:int=0;i<imageDefinitions.length;i++){
				TImage(imageDefinitions[i]).snapping = snapping;
			}
		}
		
		private function addImageDefinition(x:Number = 10, y:Number = 10, w:Number = 10, h:Number = 10, n:String = ""):void
		{
			var image:TImage;
			if(w){
				image = new TImage(x, y, w, h);				
			}else{
				image = new TImage(x, y);
			}
			if(n!==""){
				image.update({name:n});
			}
			image.alpha = .5;
			image.DESTROY.add(handle_image_DESTROY);
			image.addEventListener(MouseEvent.MOUSE_DOWN, handle_image_CLICK);
			boxHolder.addChild(image);
			imageDefinitions.push(image);
		}
		
	}
}
