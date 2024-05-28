package;

import shaders.WaveEffect;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.FlxSprite;

import shaders.Displacement;
// import shaders.WaveEffect;

import util.ReflectUtil;
import util.ShaderUtil;
// import util.CameraUtil;

class PlayState extends flixel.addons.transition.FlxTransitionableState // TODO: extend FlxTransitionableState and make it GOOD
{
	@:allow(PauseSubState)
	@:noCompletion static final __cameraLerp = .25;

	public var player:Player;
	// public var playerSpawn:FlxPoint = FlxPoint.get();

	public var levelData:FlxOgmo3Loader;

	public var background:FlxGroup;
	public var levelCollision:FlxTilemapExt;
	public var foreground:FlxGroup;

	public var shaderGroup:ShaderGroup;
	public var displacement:Displacement;

	public var cameraUI:FlxCamera; // TODO: add UI and set transition camera to the UI camera
	public var UIGroup:FlxSpriteGroup;
	public var playerStats:FlxSprite;

	public function new() { super(); }

	override public function create()
	{
		final startTime = haxe.Timer.stamp();

		// placeholder
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
		{
			// TODO: behave or get banbaned!
			final banban = FlxG.random.bool() ? AssetsPath.worldMusic("to_sunshine_forest") : AssetsPath.battleMusic("makotos_stage_spunky");
			FlxG.sound.playMusic(banban);
		}

		shaderGroup = new ShaderGroup();

		levelData = new FlxOgmo3Loader(AssetsPath.data("dev", OGMO), AssetsPath.data(FlxG.random.bool(10) ? "dash_room_lmao" : "dev_room1", JSON));
		background = levelData.loadDecals("background", "", loadOgmoSprites);
		add(background);

		// levelCollision = new FlxTypedGroup<FlxSprite>();
		levelCollision = levelData.loadTilemapExt(AssetsPath.image("debug_tileset"), "collision");

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

		// gets player spawn position from map
		// TODO: make it door dipendant or smth like this
		final playerSpawn = FlxPoint.get();
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
		playerSpawn.put();

		cameraUI = new FlxCamera();
		cameraUI.bgColor.alpha = 0;
		FlxG.cameras.add(cameraUI, false);

		UIGroup = new FlxSpriteGroup();
		UIGroup.cameras = [cameraUI];
		add(UIGroup);

		final money = new FlxSprite(AssetsPath.image("money"));
		money.active = false;
		UIGroup.add(money);

		final iconGroup = new FlxSpriteGroup();
		iconGroup.active = false;
		UIGroup.add(iconGroup);

		for (i in 0...4)
		{
			final iconSpr = new FlxSprite(400, 10).loadGraphic(AssetsPath.image("menu_icons"), true, 50, 50);
			iconSpr.frame = iconSpr.frames.frames[i];
			iconSpr.x += (10 + iconSpr.width) * i;
			iconGroup.add(iconSpr);
		}

		final selectArrow = new FlxSprite().loadGraphic(AssetsPath.image("menu_arrow"), true, 38, 24);
		selectArrow.animation.add("idle", [0, 1, 2, 1], 12, true);
		selectArrow.animation.play("idle");
		UIGroup.add(selectArrow);

		final _item = iconGroup.members[0];
		selectArrow.setPosition(_item.x + (_item.width - selectArrow.width) * .5, _item.y + _item.height + 5);
		UIGroup.y = -UIGroup.height;

		playerStats = new FlxSprite(0, FlxG.height, AssetsPath.image("player_card"));
		playerStats.cameras = [cameraUI];
		playerStats.y = FlxG.height;
		playerStats.active = false;
		add(playerStats);

		// i hate flixel collision system
		FlxG.worldBounds.set(0, 0, levelData.level.width, levelData.level.height);
		FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.right, FlxG.worldBounds.y, FlxG.worldBounds.bottom);
		FlxG.camera.follow(player, LOCKON, __cameraLerp);
		FlxG.camera.snapToTarget();
		add(shaderGroup);

		displacement = new Displacement(null);
		FlxG.camera.filters = [new openfl.filters.ShaderFilter(displacement.shader)];

		super.create();
		trace("PlayState created in " + ((haxe.Timer.stamp() - startTime) * 1000).int() + "ms WOOOOOOOW :OO");
		// trace(Type.getClassName(WaveEffect));
	}

	// welcome to CODING NIGHTMARE ZONE!!
	function loadOgmoSprites(data:DecalData, path:String):FlxSprite
	{
		// disable some flags if needed
		inline function disableFlagsAndReturn(spr:FlxSprite):FlxSprite
		{
			spr.moves = !spr.velocity.isZero() || !spr.acceleration.isZero() || !spr.drag.isZero() ||
						  spr.angularVelocity != 0 || spr.angularAcceleration != 0 || spr.angularDrag != 0;
			spr.active = spr.moves || spr.path != null || spr.animation.getAnimationList().length > 0;
			return spr;
		}

		// trace(data);
		final image = AssetsPath.image(path + data.texture.substring(0, data.texture.indexOf(".")));
		final sprite:FlxSprite = switch (data.values?.object_type.string())
		{
			case t if (t.startsWith("backdrop")):
				new FlxBackdrop(image, FlxAxes.fromString(t.substr(t.indexOf("_")+1)), data.x, data.y);

			default:
				new FlxSprite(data.x, data.y, image);
		}

		if (data.scaleX != null)
			sprite.scale.x = data.scaleX;
		if (data.scaleY != null)
			sprite.scale.y = data.scaleY;
		if (data.rotation != null)
			sprite.angle = levelData.project.anglesRadians ? flixel.math.FlxAngle.asDegrees(data.rotation) : data.rotation;

		if (data.values == null)
			return disableFlagsAndReturn(sprite);

		// cache shader data if it comes before shader was initialized.
		// also why is this even a thing? "shader_data" field always comes after "shader" field
		// and for some fucking reason "shader_data" can still go first?????
		// i specifically set fields order to prevent this kind of bullshit and it still passes through?!??!
		// TL:DR; yeah ignore all of this stuff above, i was just a little tired from debugging this shit
		var shaderDataToLoad:String = null;
		inline function setAdditionalData(object:FlxSprite, field:String, value:Dynamic)
		{
			final stringValue = value.string();
			switch (field)
			{
				case "shader": // create shader
					if (stringValue.length == 0) return;

					// object.shader =
					shaderGroup.add(ShaderUtil.getShader(stringValue, object)); // .shader
					// shaderGroup.add(cast Type.createInstance(ShaderUtil.shaderList[stringValue], [object]));
					if (shaderDataToLoad != null)
					{
						ShaderUtil.parseOgmoShaderValues(object.shader, shaderDataToLoad);
						shaderDataToLoad = null;
					}

				case "shader_data": // set shader data
					if (stringValue.length == 0) return;

					if (object.shader == null)
						shaderDataToLoad = stringValue;
					else
						ShaderUtil.parseOgmoShaderValues(object.shader, stringValue);
				
				case "color": // rearange shit cuz ogmo saves color in RRGGBBAA format (whyyy)
					if (stringValue != "#ffffffff")
						object.color = FlxColor.fromString("#" + stringValue.substr(7, 2) + stringValue.substr(1, 6));

				case "blend": // string to blend
					if (stringValue.length > 0)
						object.blend = cast (stringValue : openfl.display.BlendMode);

				default: // everything else
					ReflectUtil.setPropertyLoop(object, field.split("_"), value);
			}
		}

		final _additionalData = Reflect.fields(data.values);
		_additionalData.remove("object_type");
		// TODO: extend FlxSprite and add position wraping
		// _additionalData.remove("wrap_x");
		// _additionalData.remove("wrap_y");

		var value:Dynamic;
		if (_additionalData.length == 1)
		{
			value = Reflect.field(data.values, _additionalData[0]);
			if (value != null)
				setAdditionalData(sprite, _additionalData[0], value);
		}
		else
		{
			for (field in _additionalData)
			{
				value = Reflect.field(data.values, field);
				if (value != null) // no value - skip it
					setAdditionalData(sprite, field, value);
			}
		}

		return disableFlagsAndReturn(sprite);
	}

	@:noCompletion var __resetTimer = 0.;
	@:noCompletion var __statsState = false;
	@:noCompletion var __UIState = false;

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
			__resetTimer += elapsed;
			if (__resetTimer >= 2)
				FlxG.resetState();
		}
		else if (FlxG.keys.justReleased.R)
			__resetTimer = 0;

		// i love mother 2's battle backgrounds sm
		if (FlxG.keys.justPressed.F1)
			FlxG.openURL("youtu.be/zjQik7uwLIQ");

		// TODO: less bullshit like this
		if (FlxG.keys.justPressed.X)
			__statsState = !__statsState;

		if (FlxG.keys.justPressed.C)
			__UIState = !__UIState;
		
		final _statsPos = __statsState ? FlxG.height - playerStats.height : FlxG.height;
		if (playerStats.y != _statsPos)
			playerStats.y = FlxMath.lerp(playerStats.y, _statsPos, elapsed * 10);

		final _UIPos = __UIState ? 0 : -UIGroup.height;
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

	override public function transitionIn()
	{
		super.transitionIn();
		persistentUpdate = true;
	}

	override function transitionOut(?onExit:()->Void)
	{
		super.transitionOut(onExit);
		persistentUpdate = true;
		player.readInput = false;
	}

	override public function destroy()
	{
		displacement.destroy();
		super.destroy();
	}
}
