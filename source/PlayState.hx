package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxCollision;
import haxe.Timer;

class PlayState extends flixel.FlxState
{
	var player:Player;
	var levelCollision:FlxTypedGroup<FlxSprite>;
	@:noCompletion var _cameraLerp = 0.15;

	override public function create()
	{
		final startTime = Timer.stamp();

		// placeholder
		FlxG.sound.playMusic(Assets.music("to_sunshine_forest"));

		// plain colored bg is boring 🥱
		final backdrop = new flixel.addons.display.FlxBackdrop(Assets.image("placeholder"));
		backdrop.color = 0xFFCFCFCF;
		backdrop.velocity.set(60, 60);
		// backdrop.scrollFactor.set(0.6, 0.6);
		add(backdrop);

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

		for (data in collisionData)
		{
			final WALL = new FlxSprite(data.x, data.y).makeGraphic(data.width, data.height, FlxColor.MAGENTA);
			WALL.immovable = true;
			levelCollision.add(WALL);
		}

		add(levelCollision);

		player = new Player();
		add(player.screenCenter());

		// i hate flixel collision system
		FlxG.worldBounds.set(-1000, -1000, 3000, 3000);
		FlxG.camera.follow(player, TOPDOWN_TIGHT, _cameraLerp);
		FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.right, FlxG.worldBounds.y, FlxG.worldBounds.bottom);

		trace("PlayState created in " + Std.int((Timer.stamp() - startTime) * 1000) + "ms WOOOOOOOW :OO");
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(player, levelCollision);

		if (FlxG.keys.justPressed.ESCAPE)
			openSubState(new PauseSubState());
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		super.openSubState(SubState);
		FlxG.camera.followLerp = 0.0;
	}

	override function closeSubState()
	{
		super.closeSubState();
		FlxG.camera.followLerp = _cameraLerp;
	}
}
