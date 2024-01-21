package;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import haxe.Timer;
#if !flash
import shaders.WaveEffect;
#end

class PlayState extends flixel.addons.transition.FlxTransitionableState // TODO: extend FlxTransitionableState and make it GOOD
{
	@:allow(PauseSubState)
	@:noCompletion static final _cameraLerp = .25;

	public var player:Player;
	public var levelCollision:FlxTypedGroup<FlxSprite>;
	#if !flash
	public var waveEffect:WaveEffect;
	#end

	public var cameraUI:FlxCamera; // TODO: add UI and set transition camera to the UI camera
	public var UIGroup:FlxSpriteGroup;
	public var playerStats:FlxSprite;

	override public function create()
	{
		final startTime = Timer.stamp();

		// placeholder
		#if !flash
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
		{
			// TODO: behave or get banbaned!
			final banban = FlxG.random.bool() ? Assets.worldMusic("to_sunshine_forest") : Assets.battleMusic("makotos_stage_spunky");
			FlxG.sound.playMusic(banban);
		}
		#end

		// plain colored bg is boring 🥱
		final backdrop = new flixel.addons.display.FlxBackdrop(Assets.image("placeholder"));
		backdrop.color = 0xFFCFCFCF;
		backdrop.velocity.set(60, 60);
		// backdrop.scrollFactor.set(0.6, 0.6);
		// backdrop.setGraphicSize(FlxG.width * 0.5);
		// backdrop.updateHitbox();
		backdrop.pixelPerfectRender = backdrop.pixelPerfectPosition = true;
		add(backdrop);

		#if !flash
		waveEffect = new WaveEffect();
		waveEffect.setEffect(DREAMY, HEAT_WAVE);
		waveEffect.amplitude = 0.06;
		waveEffect.frequency = 15;
		waveEffect.speed = 5;
		backdrop.shader = waveEffect.shader;

		FlxG.console.registerObject("waveTest", waveEffect);
		#end

		// basic colision, will redo later
		final collisionData = [
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
		];

		levelCollision = new FlxTypedGroup<FlxSprite>();
		add(levelCollision);

		for (data in collisionData)
		{
			final wall = new FlxSprite(data.x, data.y).makeGraphic(data.width, data.height, FlxColor.MAGENTA);
			wall.immovable = true;
			wall.active = false;
			levelCollision.add(wall);
		}

		player = new Player();
		add(player.screenCenter());

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
		selectArrow.setPosition(_item.x + (_item.width - selectArrow.width) * 0.5, _item.y + _item.height + 5);
		UIGroup.y = -UIGroup.height;

		playerStats = new FlxSprite(0, FlxG.height, Assets.image("player_card"));
		playerStats.cameras = [cameraUI];
		playerStats.y = FlxG.height;
		playerStats.active = false;
		add(playerStats);

		// i hate flixel collision system
		FlxG.worldBounds.set(-1000, -1000, 2500, 2000);
		FlxG.camera.follow(player, LOCKON, _cameraLerp);
		FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.right, FlxG.worldBounds.y, FlxG.worldBounds.bottom);

		super.create();
		trace("PlayState created in " + Std.int((Timer.stamp() - startTime) * 1000) + "ms WOOOOOOOW :OO");
	}

	@:noCompletion var _resetTimer = 0.0;
	@:noCompletion var _statsState = false;
	@:noCompletion var _UIState = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		#if !flash
		waveEffect.update(elapsed);
		#end

		FlxG.collide(player, levelCollision);

		#if debug
		FlxG.watch.addQuick("Player X:", player.x);
		FlxG.watch.addQuick("Player Y:", player.y);

		// TODO: move this to options menu
		// TODO TODO: make main menu
		// TODO TODO TODO: lol))
		#if !flash
		if (FlxG.keys.justPressed.ONE)
			scaleWindow(1);
		else if (FlxG.keys.justPressed.TWO)
			scaleWindow(1.2);
		else if (FlxG.keys.justPressed.THREE)
			scaleWindow(1.4);
		#end
		#end

		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new PauseSubState());
			FlxG.camera.followLerp = 0.0;
			persistentUpdate = false; // fuck
		}

		if (FlxG.keys.pressed.R)
		{
			_resetTimer += elapsed;
			if (_resetTimer >= 2.0)
				FlxG.resetState();
		}
		else if (FlxG.keys.justReleased.R)
			_resetTimer = 0.0;

		// i love mother 2's battle backgrounds sm
		#if !flash
		if (FlxG.keys.justPressed.F1)
			FlxG.openURL("youtu.be/zjQik7uwLIQ");
		#end

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

	#if (debug && !flash)
	// TODO: OPTIONS!!!! (and controls too!!!!!)
	@:noCompletion inline function scaleWindow(Scale:Float)
	{
		final Width = Std.int(FlxG.width * Scale);
		final Height = Std.int(FlxG.height * Scale);
		final Window = openfl.Lib.application.window; // yeah im lazy ass 🥱🥱

		Window.resize(Width, Height);
		Window.move(Std.int((Window.display.bounds.width - Width) * 0.5), Std.int((Window.display.bounds.height - Height) * 0.5));
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
}
