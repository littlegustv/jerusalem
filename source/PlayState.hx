package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.group.FlxGroup;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.util.FlxSpriteUtil;

import openfl.Assets;

import haxe.Http;
import haxe.Json;

import Objects;

class PlayState extends FlxState
{
	private var moveable:FlxTypedGroup<Structure> = new FlxTypedGroup<Structure>();
	private var mouse_offset:FlxPoint = new FlxPoint();
	private var moving:Structure;
	private var bg:FlxSprite;

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

		bg = new FlxSprite(0, 0);
		add(bg);

		var result = Http.requestUrl("http://api.openweathermap.org/data/2.5/weather?q=jerusalem,il&appid=fb6870e2ff78a3469740b685e3bcdd98");
		var data = Json.parse(result);
		weather(data.weather);

		var layout:Dynamic = Json.parse(Assets.getText("assets/data/layout.json"));
		// trace(layout.objects.length);
		for (i in 0...layout.objects.length) {
			var s = new Structure(layout.objects[i].x, layout.objects[i].y, "assets/images/" + layout.objects[i].image, layout.objects[i].name);
			moveable.add(s);
			// trace('here!', s.graphic.assetsKey, s.graphic);
		}

		// var church = new Structure(140, 160 - 72, AssetPaths.church__png, "Church of the Holy Sepulchre");
		// moveable.add(church);

		// var dome = new Structure(90, 120 - 88, AssetPaths.dome__png, "Dome of the Rock");
		// moveable.add(dome);

		// var aqsa = new Structure(72, 120 - 80, AssetPaths.alaqsa__png, "Al Aqsa Mosque");
		// moveable.add(aqsa);

		// for (i in 0...5) {
		// 	var w = new Structure(i * 32, 120 - 32, AssetPaths.wall__png, "Ottoman Walls");
		// 	moveable.add(w);
		// }

		// var wailing = new Structure(72 - 40, 120 - 40, AssetPaths.wailing__png, "Wailing Wall");
		// moveable.add(wailing);

		// add(moveable);

		// set sky color

		// idea: create array of colors with 'percentage' values
		// i.e.: {0: "black", 5: "purple", 10: "lavender", 15: "blue" ... 85: "blue", 90: "violet" }
		// THEN periodically set color based on where it is in day...
		var colors = [
			0 => 0xFF010033,
			1 => 0xFF1A2B55,
			2 => 0xFF345577,
			3 => 0xFF4D8099,
			4 => 0xFF66AABB,
			5 => 0xFF99FFFF,
			6 => 0xFF66AABB,
			7 => 0xFF4D8099,
			8 => 0xFF345577,
			9 => 0xFF1A2B55,
			10 => 0xFF010033
		];
		var time = Math.floor(Date.now().getTime() / 1000) - data.sys.sunrise;
		var daylength = data.sys.sunset - data.sys.sunrise;
		var position = Math.max(Math.min(Math.floor(10.0 * time / daylength), 10), 0);

		for (i in colors.keys()) {
			if (i >= position) {
				// bg.color = colors[i];
				bg.makeGraphic(240, 240, colors[i]);	
				break;
			}
		}
		// bg.color = Math.floor(twilight + (noon - twilight) * time / daylength);

		// var day_duration = data.
		moveable.sort(Structure.ByBaseline);
		add(moveable);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			// trace('just pressed!');
			for (m in moveable) {
				// trace('hmm??');
				if (FlxG.mouse.overlaps(m)) {
					// m.glow.alpha = 1;
					// trace('found one!');
					moving = m;
					mouse_offset.x = FlxG.mouse.x - m.x;
					mouse_offset.y = FlxG.mouse.y - m.y;
					break;
				}
			}
		}

		if (FlxG.mouse.justPressedRight) {
			trace('just pressed!');
			for (m in moveable) {
				// trace('hmm??');
				if (FlxG.mouse.overlaps(m)) {
					// m.glow.alpha = 1;
					// trace('found one!');
					moving = new Structure(m.x, m.y, m.graphic.assetsKey, m.name);
					moveable.add(moving);
					mouse_offset.x = FlxG.mouse.x - moving.x;
					mouse_offset.y = FlxG.mouse.y - moving.y;
					break;
				}
			}
		}


		if (FlxG.mouse.justReleased) {
			moving = null;
			moveable.sort(Structure.ByBaseline);
		}

		if (moving != null) {
			// trace('should be moving', moving.x, moving.y, FlxG.mouse.x, FlxG.mouse.y);
			if (FlxG.keys.pressed.SHIFT) {
				moving.setPosition(Math.round((FlxG.mouse.x - mouse_offset.x) / 16) * 16, Math.round((FlxG.mouse.y - mouse_offset.y) / 16) * 16);
			} else {
				moving.setPosition(FlxG.mouse.x - mouse_offset.x, FlxG.mouse.y - mouse_offset.y);			
			}
		}

		if (FlxG.mouse.justReleasedMiddle) {
			var data = {objects: []};
			for (m in moveable) {
				var m_data = {
					name: m.name,
					x: m.x,
					y: m.y,
					image: m.graphic.assetsKey.split('/')[2] 					
				};
				data.objects.push(m_data);
			}
			trace(Json.stringify(data));
		}

		// updateFilter(church, glow);

	}
}
