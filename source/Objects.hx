package;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.util.FlxSort;


class Structure extends FlxSprite {
	public static inline function ByBaseline (order:Int, obj1:FlxSprite, obj2:FlxSprite) {
		// trace('sorting', obj1.y + obj1.height, obj2.y + obj2.height);
		return FlxSort.byValues(order, obj1.y + obj1.height, obj2.y + obj2.height);
	}
	
	public var glow:GlowFilter;
	public var name:String;

	public function new (?x:Float, ?y:Float, ?graphic, ?name:String) {
		super(x, y, graphic);

		// fix me: center origin somehow??
		this.origin.set(0, 0);

		this.name = name;
		// var SIZE_INCREASE = 50;
		// glow = new GlowFilter(16711680, 1, 10, 10, 1.5, 1);
		// var filterFrames = FlxFilterFrames.fromFrames(
		// 	this.frames, SIZE_INCREASE, SIZE_INCREASE, [glow]);
		// filterFrames.applyToSprite(this, false, true);
		// glow.alpha = 0;
	}
}