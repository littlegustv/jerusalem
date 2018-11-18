package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		stage.showDefaultContextMenu = false;

		addChild(new FlxGame(240, 240, PlayState, 1, 60, 60, true));
	}
}
