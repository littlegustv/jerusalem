package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

import haxe.Http;
import haxe.Json;

class PlayState extends FlxState
{
	private var moveable:FlxSpriteGroup = new FlxSpriteGroup();
	private var moving:FlxSprite;

	private function weather(data:Dynamic) {
		if (data[0].main == "Clouds") {
			for(i in 0...10) {
				var cloud = new FlxSprite(FlxG.random.int(0, 320), FlxG.random.int(0, 320));
				cloud.loadGraphic(AssetPaths.cloud__png);
				add(cloud);
			}
		} else {
			trace(data, data.main, data.main == "Clouds");
		}
	}

	override public function create():Void
	{
		super.create();

		var result = Http.requestUrl("http://api.openweathermap.org/data/2.5/weather?q=jerusalem,il&appid=fb6870e2ff78a3469740b685e3bcdd98");
		var data = Json.parse(result);
		weather(data.weather);

		this.bgColor = FlxColor.PURPLE;

		var church = new FlxSprite(196, 320 - 72);
		church.loadGraphic(AssetPaths.church__png);
		moveable.add(church);

		var dome = new FlxSprite(156, 320 - 88);
		dome.loadGraphic(AssetPaths.dome__png);
		moveable.add(dome);

		var aqsa = new FlxSprite(112, 320 - 80);
		aqsa.loadGraphic(AssetPaths.alaqsa__png);
		moveable.add(aqsa);

		for (i in 0...10) {
			var w = new FlxSprite(i * 32, 320 - 32);
			w.loadGraphic(AssetPaths.wall__png);
			moveable.add(w);
		}

		var wailing = new FlxSprite(112 - 40, 320 - 40);
		wailing.loadGraphic(AssetPaths.wailing__png);
		moveable.add(wailing);

		add(moveable);


	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.mouse.justPressed) {
			trace('just pressed!');
			for (m in moveable) {
				trace('hmm??');
				if (FlxG.mouse.overlaps(m)) {
					trace('found one!');
					moving = m;
					break;
				}
			}
		}

		if (FlxG.mouse.justReleased) {
			moving = null;
		}

		if (moving != null) {
			trace('should be moving', moving.x, moving.y, FlxG.mouse.x, FlxG.mouse.y);
			moving.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		}

		super.update(elapsed);
	}
}
