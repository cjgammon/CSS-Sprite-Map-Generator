package texturemapper {
	import flash.display.Sprite;

	/**
	 * @author cjgammon
	 */
	public class THandle extends Sprite {
		public function THandle() {
			buttonMode = true;
			graphics.lineStyle(1, 0xff0000);
			graphics.beginFill(0xff0000, 0.5);
			graphics.drawCircle(0, 0, 5);
			graphics.endFill();
		}
	}
}
