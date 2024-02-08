package;

import util.CameraUtil;
import flixel.system.FlxAssets.FlxShader;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.FlxSprite;

import shaders.Displacement;
import shaders.WaveEffect;

import util.ShaderUtil;
import util.ReflectUtil;

import haxe.Timer;

// this is bullshit
@:access(flixel.addons.editors.ogmo.FlxOgmo3Loader)
class PlayState extends flixel.addons.transition.FlxTransitionableState // TODO: extend FlxTransitionableState and make it GOOD
{
	@:allow(PauseSubState)
	@:noCompletion static final _cameraLerp = .25;

	public var player:Player;
	public var playerSpawn:FlxPoint = FlxPoint.get();
	// public var levelCollision:FlxTypedGroup<FlxSprite>;

	public var levelData:FlxOgmo3Loader;

	public var background:FlxGroup;
	public var levelCollision:FlxTilemapExt;
	public var foreground:FlxGroup;

	public var shaderGroup:ShaderGroup;
	// public var waveEffect:WaveEffect;
	public var displacement:Displacement;

	public var cameraUI:FlxCamera; // TODO: add UI and set transition camera to the UI camera
	public var UIGroup:FlxSpriteGroup;
	public var playerStats:FlxSprite;

	override public function create()
	{
		final startTime = Timer.stamp();

		// placeholder
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
		{
			// TODO: behave or get banbaned!
			final banban = FlxG.random.bool() ? Assets.worldMusic("to_sunshine_forest") : Assets.battleMusic("makotos_stage_spunky");
			FlxG.sound.playMusic(banban);
		}

		/*
		// plain colored bg is boring 🥱
		final backdrop = new flixel.addons.display.FlxBackdrop(Assets.image("placeholder"));
		backdrop.color = 0xFFCFCFCF;
		backdrop.velocity.set(60, 60);
		// backdrop.scrollFactor.set(0.6, 0.6);
		// backdrop.setGraphicSize(FlxG.width * 0.5);
		// backdrop.updateHitbox();
		add(backdrop);

		waveEffect = new WaveEffect();
		waveEffect.setEffect(DREAMY, HEAT_WAVE);
		waveEffect.amplitude = 0.06;
		waveEffect.frequency = 15;
		waveEffect.speed = 5;
		backdrop.shader = waveEffect.shader;
		FlxG.console.registerObject("waveTest", waveEffect);
		*/

		// basic colision, will redo later
		/*final collisionData = [
			{x: -150,   y: -660,   width: 260,    height: 210},
			{x:  110,   y: -660,   width: 850,    height: 40},
			{x:  960,   y: -660,   width: 180,    height: 170},
			{x: -470,   y: -560,   width: 40,     height: 220},
			{x: -270,   y: -490,   width: 120,    height: 40},
			{x: 1100,   y: -490,   width: 40,     height: 560},
			{x: -470,   y: -340,   width: 190,    height: 130},
			{x: -470,   y: -210,   width: 1180,   height: 100},
			{x: -470,   y: -110,   width: 80,     height: 540},
			{x: -390,   y: -110,   width: 440,    height: 60},
			{x:  850,   y:  70,    width: 290,    height: 610},
			{x: -470,   y:  430,   width: 270,    height: 250},
			{x: -200,   y:  640,   width: 1050,   height: 40}
		];*/

		shaderGroup = new ShaderGroup();

		levelData = new FlxOgmo3Loader(Assets.data("dev", OGMO), Assets.data(FlxG.random.bool(10) ? "dash_room_lmao" : "dev_room1", JSON));
		background = levelData.loadDecals("background", "", loadOgmoSprites);
		add(background);

		// levelCollision = new FlxTypedGroup<FlxSprite>();
		levelCollision = levelData.loadTilemapExt(Assets.image("debug_tileset"), "collision");

		// standart collision tile
		levelCollision.setTileProperties(0, NONE); // air lol
		levelCollision.setTileProperties(1, ANY);

		// directional collition tiles
		levelCollision.setTileProperties(2, RIGHT);
		levelCollision.setTileProperties(3, DOWN);
		levelCollision.setTileProperties(4, LEFT);
		levelCollision.setTileProperties(5, UP);

		// door tile
		// TODO: maybe replace with some trigger???
		levelCollision.setTileProperties(6, NONE, (_, _) -> trace("collided with door"));

		// ladder tile
		levelCollision.setTileProperties(7, WALL);

		// brainrot
		levelCollision.setTileProperties(8, NONE, (_, _) -> trace("FIRE IN THE HOLE!!!"));
		add(levelCollision);

		/*for (data in collisionData)
		{
			final wall = new FlxSprite(data.x, data.y).makeGraphic(data.width, data.height, FlxColor.MAGENTA);
			wall.immovable = true;
			wall.active = false;
			levelCollision.add(wall);
		}*/

		// gets player spawn position from map
		// TODO: make it door dipendant or smth like this
		levelData.loadEntities((entity:EntityData) ->
			{
				switch (entity.name)
				{
					case "player":
						playerSpawn.set(entity.x, entity.y);

					default: // nothing yet
				}
			},
			"entities"
		);

		player = new Player(playerSpawn.x, playerSpawn.y);
		add(player);

		cameraUI = new FlxCamera();
		cameraUI.bgColor.alpha = 0;
		FlxG.cameras.add(cameraUI, false);

		UIGroup = new FlxSpriteGroup();
		UIGroup.cameras = [cameraUI];
		add(UIGroup);

		final money = new FlxSprite(Assets.image("money"));
		money.active = false;
		UIGroup.add(money);

		final iconGroup = new FlxSpriteGroup();
		iconGroup.active = false;
		UIGroup.add(iconGroup);

		for (i in 0...4)
		{
			final iconSpr = new FlxSprite(400, 10).loadGraphic(Assets.image("menu_icons"), true, 50, 50);
			iconSpr.frame = iconSpr.frames.frames[i];
			iconSpr.x += (10 + iconSpr.width) * i;
			iconGroup.add(iconSpr);

			// removing garbage data
			/*for (frameID in 0...iconSpr.numFrames)
				if (frameID != i)
					iconSpr.frames.frames.splice(frameID, 1);*/
		}

		final selectArrow = new FlxSprite().loadGraphic(Assets.image("menu_arrow"), true, 38, 24);
		selectArrow.animation.add("idle", [0, 1, 2, 1], 12, true);
		selectArrow.animation.play("idle");
		UIGroup.add(selectArrow);

		final _item = iconGroup.members[0];
		selectArrow.setPosition(_item.x + (_item.width - selectArrow.width) * .5, _item.y + _item.height + 5);
		UIGroup.y = -UIGroup.height;

		playerStats = new FlxSprite(0, FlxG.height, Assets.image("player_card"));
		playerStats.cameras = [cameraUI];
		playerStats.y = FlxG.height;
		playerStats.active = false;
		add(playerStats);

		// i hate flixel collision system
		FlxG.worldBounds.set(0, 0, levelData.level.width, levelData.level.height);
		FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.right, FlxG.worldBounds.y, FlxG.worldBounds.bottom);
		FlxG.camera.follow(player, LOCKON, _cameraLerp);
		FlxG.camera.snapToTarget();
		add(shaderGroup);

		displacement = new Displacement();
		FlxG.camera.filters = [new openfl.filters.ShaderFilter(displacement.shader)];

		super.create();
		trace("PlayState created in " + Std.int((Timer.stamp() - startTime) * 1000) + "ms WOOOOOOOW :OO");
	}

	// welcome to CODING NIGHTMARE ZONE!!
	function loadOgmoSprites(Data:DecalData, Path:String):FlxSprite
	{
		// disable some flags if needed
		inline function disableFlagsAndReturn(spr:FlxSprite):FlxSprite
		{
			spr.moves = !spr.velocity.isZero() || !spr.acceleration.isZero() || !spr.drag.isZero() ||
						  spr.angularVelocity != 0 || spr.angularAcceleration != 0 || spr.angularDrag != 0;
			spr.active = spr.moves || spr.path != null || spr.animation.getAnimationList().length > 0;
			return spr;
		}

		// trace(Data);
		final image = Assets.image(Path + Data.texture.substring(0, Data.texture.indexOf(".")));
		final sprite:FlxSprite = switch (Std.string(Data.values?.object_type))
		{
			case t if (t.startsWith("backdrop")):
				new FlxBackdrop(image, FlxAxes.fromString(t.substr(t.indexOf("_")+1)), Data.x, Data.y);

			default:
				new FlxSprite(Data.x, Data.y, image);
		}

		if (Data.scaleX != null)
			sprite.scale.x = Data.scaleX;
		if (Data.scaleY != null)
			sprite.scale.y = Data.scaleY;
		if (Data.rotation != null)
			sprite.angle = levelData.project.anglesRadians ? flixel.math.FlxAngle.asDegrees(Data.rotation) : Data.rotation;

		if (Data.values == null)
			return disableFlagsAndReturn(sprite);

		// cache shader data if it comes before shader was initialized.
		// also why is this even a thing? "shader_data" field always comes after "shader" field
		// and for some fucking reason "shader_data" can still go first?????
		// i specifically set fields order to prevent this kind of bullshit and it still passes through?!??!
		// TL:DR; yeah ignore all of this stuff above, i was just a little tired from debugging this shit
		var shaderDataToLoad:String = null;
		inline function setAdditionalData(Object:FlxSprite, Field:String, Value:Dynamic)
		{
			final StringValue = Std.string(Value);
			switch (Field)
			{
				case "shader": // create shader
					if (StringValue == "") return;

					Object.shader = shaderGroup.add(cast Type.createInstance(ShaderUtil.shaderList[StringValue], [])).shader;
					if (shaderDataToLoad != null)
					{
						ShaderUtil.parseOgmoShaderValues(Object.shader, shaderDataToLoad);
						shaderDataToLoad = null;
					}

				case "shader_data": // set shader data
					if (StringValue == "") 	return;

					if (Object.shader == null)
						shaderDataToLoad = StringValue;
					else
						ShaderUtil.parseOgmoShaderValues(Object.shader, StringValue);
				
				case "color": // rearange shit cuz ogmo saves color in RRGGBBAA format (whyyy)
					if (StringValue != "#ffffffff")
						Object.color = FlxColor.fromString("#" + StringValue.substr(7, 2) + StringValue.substr(1, 6));

				case "blend": // string to blend
					if (StringValue != "")
						Object.blend = cast (StringValue : openfl.display.BlendMode);

				default: // everything else
					ReflectUtil.setPropertyLoop(Object, Field.split("_"), Value);
			}
		}

		final _additionalData = Reflect.fields(Data.values);
		_additionalData.remove("object_type");
		// TODO: extend FlxSprite and add position wraping
		// _additionalData.remove("wrap_x");
		// _additionalData.remove("wrap_y");

		var value:Dynamic;
		if (_additionalData.length == 1)
		{
			value = Reflect.field(Data.values, _additionalData[0]);
			if (value != null)
				setAdditionalData(sprite, _additionalData[0], value);
		}
		else
		{
			for (field in _additionalData)
			{
				value = Reflect.field(Data.values, field);
				if (value != null) // no value - skip it
					setAdditionalData(sprite, field, value);
			}
		}

		return disableFlagsAndReturn(sprite);
	}

	@:noCompletion var _resetTimer = 0.;
	@:noCompletion var _statsState = false;
	@:noCompletion var _UIState = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// waveEffect.update(elapsed);

		FlxG.collide(player, levelCollision);

		#if debug
		FlxG.watch.addQuick("Player X:", player.x);
		FlxG.watch.addQuick("Player Y:", player.y);

		// TODO: move this to options menu
		// TODO TODO: make main menu
		// TODO TODO TODO: lol))
		if (!FlxG.fullscreen)
		{
			if (FlxG.keys.justPressed.ONE)
				scaleWindow(1.);
			else if (FlxG.keys.justPressed.TWO)
				scaleWindow(1.2);
			else if (FlxG.keys.justPressed.THREE)
				scaleWindow(1.4);
		}
		#end

		if (FlxG.keys.justPressed.ENTER)
		{
			openSubState(new PauseSubState());
			FlxG.camera.followLerp = 0;
			persistentUpdate = false; // fuck
		}

		if (FlxG.keys.pressed.R)
		{
			_resetTimer += elapsed;
			if (_resetTimer >= 2)
				FlxG.resetState();
		}
		else if (FlxG.keys.justReleased.R)
			_resetTimer = 0;

		// i love mother 2's battle backgrounds sm
		if (FlxG.keys.justPressed.F1)
			FlxG.openURL("youtu.be/zjQik7uwLIQ");

		// TODO: less bullshit like this
		if (FlxG.keys.justPressed.X)
			_statsState = !_statsState;

		if (FlxG.keys.justPressed.C)
			_UIState = !_UIState;
		
		final _statsPos = _statsState ? FlxG.height - playerStats.height : FlxG.height;
		if (playerStats.y != _statsPos)
			playerStats.y = FlxMath.lerp(playerStats.y, _statsPos, elapsed * 10);

		final _UIPos = _UIState ? 0 : -UIGroup.height;
		if (UIGroup.y != _UIPos)
			UIGroup.y = FlxMath.lerp(UIGroup.y, _UIPos, elapsed * 10);
	}

	#if debug
	// TODO: OPTIONS!!!! (and controls too!!!!!)
	@:noCompletion inline function scaleWindow(scale:Float)
	{
		final width = Math.floor(FlxG.width * scale);
		final height = Math.floor(FlxG.height * scale);
		final window = openfl.Lib.application.window; // yeah im lazy ass 🥱🥱

		if (window.width != width || window.height != height)
		{
			window.move(Math.floor((window.display.bounds.width - width) * .5), Math.floor((window.display.bounds.height - height) * .5));
			window.resize(width, height);
		}
	}
	#end

	override function transitionIn()
	{
		super.transitionIn();
		persistentUpdate = true;
	}

	override function transitionOut(?OnExit:()->Void)
	{
		super.transitionOut(OnExit);
		persistentUpdate = true;
		player.readInput = false;
	}

	override function destroy()
	{
		// FlxG.console.removeByAlias("waveTest");
		super.destroy();
	}
}
