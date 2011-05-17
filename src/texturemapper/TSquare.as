package texturemapper {
	import flash.display.Sprite;

	/**
	 * @author cjgammon
	 */
	public class TSquare extends Sprite {
		
		public function TSquare(_w:Number, _h:Number) 
		{
			buttonMode = true;
			size(_w, _h);
		}
		
		public function size(_w:Number, _h:Number):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x00ff00);
			graphics.beginFill(0xffffff, 1);
			graphics.drawRect(0, 0, _w, _h);
			graphics.endFill();
		}
	}
}
