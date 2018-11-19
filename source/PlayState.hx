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
import flixel.tweens.FlxTween;

import openfl.Assets;

import haxe.Http;
import haxe.Json;

import Objects;


/*

TODO:

MONDAY:
- DRAFT OF ESSAY

TUESDAY:
- FINAL ESSAY
- last-minute polish
	- blending/lighting effects ?
	- make names structures have very simple animation (i.e. a reflection change) to draw the eye
	- make 'named' objects clickable or hoverable
	- border/frame is a little... eh?
	- remove all debug stuff ! like being able to move things around!

*/

class PlayState extends FlxState
{
	private var moveable:FlxTypedGroup<Structure> = new FlxTypedGroup<Structure>();
	private var mouse_offset:FlxPoint = new FlxPoint();
	private var moving:Structure;
	private var bg:FlxSprite;

	private var weather_condition:String = "snow";

	private var weather_bg:FlxGroup;
	private var weather_fg:FlxGroup;

	override public function create():Void
	{

		FlxG.camera.fade(FlxColor.WHITE, 1, true);

		super.create();

		bg = new FlxSprite(0, 0);
		add(bg);

		var result = Http.requestUrl("http://api.openweathermap.org/data/2.5/weather?q=jerusalem,il&appid=fb6870e2ff78a3469740b685e3bcdd98");
		// var result = Http.requestUrl("http://api.openweathermap.org/data/2.5/weather?q=montreal,ca&appid=fb6870e2ff78a3469740b685e3bcdd98");
		var data:Dynamic = Json.parse(result);
		trace(data.weather);
		weather_condition = "";
		for (i in 0...data.weather.length) {
			weather_condition += data.weather[i].description + " ";
		}
		
		var layout:Dynamic = Json.parse(Assets.getText("assets/data/layout.json"));
		// trace(layout.objects.length);
		for (i in 0...layout.objects.length) {
			var s = new Structure(layout.objects[i].x, layout.objects[i].y, "assets/images/" + layout.objects[i].image, layout.objects[i].name);
			moveable.add(s);
		}

		var colors = [
			0 => 0xFF010022,
			1 => 0xFF1A2B55,
			2 => 0xFF345577,
			3 => 0xFF4D8099,
			4 => 0xFF66AABB,
			5 => 0xFF99FFFF,
			6 => 0xFF66AABB,
			7 => 0xFF4D8099,
			8 => 0xFF345577,
			9 => 0xFF1A2B55,
			10 => 0xFF010022
		];

		var overcast_colors = [
			0 => 0xFF010101,
			1 => 0xFF333333,
			2 => 0xFF555555,
			3 => 0xFF777777,
			4 => 0xFF999999,
			5 => 0xFFCCCCCC,
			6 => 0xFF999999,
			7 => 0xFF777777,
			8 => 0xFF555555,
			9 => 0xFF333333,
			10 => 0xFF010101
		];

		var time = Math.floor(Date.now().getTime() / 1000) - data.sys.sunrise;
		var daylength = data.sys.sunset - data.sys.sunrise;
		var position = Math.max(Math.min(Math.floor(10.0 * time / daylength), 10), 0);
		var color = 0xFF000000;

		for (i in colors.keys()) {
			if (i >= position) {
				// bg.color = colors[i];
				if (weather_condition.indexOf('overcast') != -1) {
					color = overcast_colors[i];
				} else {
					color = colors[i];					
				}
				bg.makeGraphic(240, 240, color);	
				break;
			}
		}
		// bg.color = Math.floor(twilight + (noon - twilight) * time / daylength);

		// var day_duration = data.
		weather_bg = new FlxGroup();
		add(weather_bg);

		var ground = new FlxSprite(0, 0, AssetPaths.ground__png);
		add(ground);

		moveable.sort(Structure.ByBaseline);
		add(moveable);

		weather_fg = new FlxGroup();
		add(weather_fg);

		var filter = new FlxSprite(0, 0);
		filter.makeGraphic(240, 240, color);
		filter.alpha = 0.2;
		filter.blend = "multiply";
		add(filter);

		var frame = new FlxSprite(0, 0, AssetPaths.frame2__png);
		add(frame);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (weather_condition.indexOf("snow") != -1) {

			// snow
			if (FlxG.random.int(0,100) < 10) {
				var flake = new FlxSprite(FlxG.random.int(0, 240), 10);
				flake.loadGraphic(AssetPaths.snowflake__png, true, 7, 7);
				flake.animation.add("main", [FlxG.random.int(0,2)]);
				flake.animation.play("main");
				flake.velocity.x = -10;
				flake.velocity.y = FlxG.random.int(30, 80);
				weather_fg.add(flake);
			}
		}

		if (weather_condition.indexOf("rain") != -1) {


			// partly cloudy
			// if (FlxG.random.int(0,1000) <= 1) {
			// 	var cloud = new FlxSprite(FlxG.random.int(20,220), FlxG.random.int(20, 64), AssetPaths.cloud__png);
			// 	FlxSpriteUtil.fadeIn(cloud, 0.5);
			// 	weather_bg.add(cloud);				
			// }

			// rain
			if (FlxG.random.int(0,100) < 60) {
				var rain = new FlxSprite(FlxG.random.int(0,120) * 2, -230);
				rain.makeGraphic(2, 240, 0xFF9999CC);
				rain.velocity.y = FlxG.random.int(40,120);
				rain.alpha = FlxG.random.int(5,40) / 100;
				if (FlxG.random.int(0,100) > 50) {
					weather_fg.add(rain);									
				} else {
					weather_bg.add(rain);
				}
			}
		}

		if (weather_condition.indexOf("drizzle") != -1) {

			// drizzle
			if (FlxG.random.int(0,100) < 20) {
				var rain = new FlxSprite(FlxG.random.int(0,240), -230);
				rain.makeGraphic(1, 240, 0xFF9999CC);
				rain.velocity.y = FlxG.random.int(20,80);
				rain.alpha = FlxG.random.int(5,40) / 100;
				if (FlxG.random.int(0,100) > 50) {
					weather_fg.add(rain);									
				} else {
					weather_bg.add(rain);
				}
			}
		}



		if (weather_condition.indexOf("thunderstorm") != -1) {

			// lightning
			if (FlxG.random.int(0,1000) <= 2) {
				var lightning = new FlxSprite(FlxG.random.int(40, 200), 10, AssetPaths.lightning__png);
				weather_bg.add(lightning);
				FlxSpriteUtil.fadeOut(lightning, 0.4, function (?tween:FlxTween) {
					weather_bg.remove(lightning);
				});
			}
		}


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
